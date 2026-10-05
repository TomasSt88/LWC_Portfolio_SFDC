/**
 * Sends an uploaded image to Google Cloud Vision (TEXT_DETECTION) through the
 * Google_New named credential and stores the extracted text on a Scanned Document.
 */
public with sharing class GoogleWebService {
  private static final String LIBRARY_NAME = 'ScannedImages';

  @AuraEnabled
  public static String analyzeImage(String contentDocumentId) {
    List<ContentVersion> versions = [
      SELECT VersionData
      FROM ContentVersion
      WHERE ContentDocumentId = :contentDocumentId AND IsLatest = TRUE
      LIMIT 1
    ];
    if (versions.isEmpty()) {
      throw new AuraHandledException(
        'No file found. Please upload an image first.'
      );
    }

    Map<String, Object> requestBody = new Map<String, Object>{
      'requests' => new List<Object>{
        new Map<String, Object>{
          'image' => new Map<String, Object>{
            'content' => EncodingUtil.base64Encode(versions[0].VersionData)
          },
          'features' => new List<Object>{
            new Map<String, Object>{ 'type' => 'TEXT_DETECTION' }
          }
        }
      }
    };

    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:Google_New');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setBody(JSON.serialize(requestBody));

    HttpResponse res;
    try {
      res = new Http().send(req);
    } catch (System.CalloutException e) {
      throw new AuraHandledException(
        'Image analysis service is unavailable: ' + e.getMessage()
      );
    }
    if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
      throw new AuraHandledException(
        'Image analysis failed with status ' +
          res.getStatusCode() +
          ' ' +
          res.getStatus()
      );
    }
    return extractText(res.getBody());
  }

  @TestVisible
  private static String extractText(String responseBody) {
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      responseBody
    );
    List<Object> responses = (List<Object>) responseMap.get('responses');
    if (responses == null || responses.isEmpty()) {
      return null;
    }
    Map<String, Object> firstResponse = (Map<String, Object>) responses[0];
    List<Object> textAnnotations = (List<Object>) firstResponse.get(
      'textAnnotations'
    );
    if (textAnnotations == null || textAnnotations.isEmpty()) {
      return null;
    }
    Map<String, Object> firstTextAnnotation = (Map<String, Object>) textAnnotations[0];
    return (String) firstTextAnnotation.get('description');
  }

  /**
   * Creates the Scanned Document, links the file to it, adds the file to the
   * ScannedImages library and removes the temporary link to the Account.
   * Runs in one transaction so a failure leaves no partial data behind.
   */
  @AuraEnabled
  public static Id saveScannedDocument(
    Id accountId,
    String extractedText,
    Id contentDocumentId
  ) {
    if (
      accountId == null ||
      contentDocumentId == null ||
      String.isBlank(extractedText)
    ) {
      throw new AuraHandledException(
        'Account, file and extracted text are required.'
      );
    }
    List<ContentWorkspace> libraries = [
      SELECT Id
      FROM ContentWorkspace
      WHERE Name = :LIBRARY_NAME
      LIMIT 1
    ];
    if (libraries.isEmpty()) {
      throw new AuraHandledException(
        'Content library "' + LIBRARY_NAME + '" does not exist.'
      );
    }

    Savepoint sp = Database.setSavepoint();
    try {
      Scanned_document__c doc = new Scanned_document__c(
        Account__c = accountId,
        Extracted_Text__c = extractedText
      );
      insert doc;

      insert new ContentDocumentLink(
        ContentDocumentId = contentDocumentId,
        LinkedEntityId = doc.Id,
        ShareType = 'V'
      );
      insert new ContentWorkspaceDoc(
        ContentDocumentId = contentDocumentId,
        ContentWorkspaceId = libraries[0].Id
      );
      unlinkFromAccount(accountId, contentDocumentId);
      return doc.Id;
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(
        'Saving the scanned document failed: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static void removeFileFromAccount(Id accountId, Id contentDocumentId) {
    if (accountId == null || contentDocumentId == null) {
      return;
    }
    unlinkFromAccount(accountId, contentDocumentId);
  }

  private static void unlinkFromAccount(Id accountId, Id contentDocumentId) {
    List<ContentDocumentLink> links = [
      SELECT Id
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :accountId
        AND ContentDocumentId = :contentDocumentId
    ];
    if (!links.isEmpty()) {
      delete links;
    }
  }
}
