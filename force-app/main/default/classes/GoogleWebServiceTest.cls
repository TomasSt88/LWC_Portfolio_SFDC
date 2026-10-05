@IsTest
private class GoogleWebServiceTest {
  private static final String LIBRARY_NAME = 'ScannedImages';

  private class FailingVisionMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(403);
      res.setStatus('Forbidden');
      res.setBody('{"error":{"message":"denied"}}');
      return res;
    }
  }

  @TestSetup
  static void setup() {
    insert new Account(Name = 'Test Account');
    System.runAs(new User(Id = UserInfo.getUserId())) {
      if (
        [SELECT COUNT() FROM ContentWorkspace WHERE Name = :LIBRARY_NAME] == 0
      ) {
        insert new ContentWorkspace(Name = LIBRARY_NAME);
      }
    }
  }

  private static Id createFileOnAccount(Id accountId) {
    ContentVersion version = new ContentVersion(
      Title = 'Scan',
      PathOnClient = 'scan.jpg',
      VersionData = Blob.valueOf('image bytes')
    );
    insert version;
    Id documentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :version.Id
    ]
    .ContentDocumentId;
    insert new ContentDocumentLink(
      ContentDocumentId = documentId,
      LinkedEntityId = accountId,
      ShareType = 'V'
    );
    return documentId;
  }

  @IsTest
  static void analyzeImageReturnsDetectedText() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Id documentId = createFileOnAccount(acc.Id);
    Test.setMock(HttpCalloutMock.class, new GoogleCloudVisionAPIMock());

    Test.startTest();
    String text = GoogleWebService.analyzeImage(documentId);
    Test.stopTest();

    Assert.areEqual(
      'Test Text',
      text,
      'Description of the first annotation should be returned'
    );
  }

  @IsTest
  static void analyzeImageFailsWithoutFile() {
    Test.setMock(HttpCalloutMock.class, new GoogleCloudVisionAPIMock());
    Test.startTest();
    try {
      GoogleWebService.analyzeImage(null);
      Assert.fail('An exception was expected when no file exists');
    } catch (AuraHandledException e) {
      Assert.isTrue(true, 'AuraHandledException thrown for missing file');
    }
    Test.stopTest();
  }

  @IsTest
  static void analyzeImageFailsOnHttpError() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Id documentId = createFileOnAccount(acc.Id);
    Test.setMock(HttpCalloutMock.class, new FailingVisionMock());

    Test.startTest();
    try {
      GoogleWebService.analyzeImage(documentId);
      Assert.fail('An exception was expected on a non-2xx response');
    } catch (AuraHandledException e) {
      Assert.isTrue(true, 'AuraHandledException thrown for HTTP error');
    }
    Test.stopTest();
  }

  @IsTest
  static void extractTextHandlesEmptyAnnotations() {
    Assert.isNull(
      GoogleWebService.extractText('{"responses":[{}]}'),
      'No annotations should yield null'
    );
    Assert.isNull(
      GoogleWebService.extractText('{"responses":[]}'),
      'No responses should yield null'
    );
  }

  @IsTest
  static void saveScannedDocumentCreatesRecordAndMovesFile() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Id documentId = createFileOnAccount(acc.Id);

    Test.startTest();
    Id docId = GoogleWebService.saveScannedDocument(
      acc.Id,
      'Hello',
      documentId
    );
    Test.stopTest();

    Scanned_document__c doc = [
      SELECT Account__c, Extracted_Text__c
      FROM Scanned_document__c
      WHERE Id = :docId
    ];
    Assert.areEqual(acc.Id, doc.Account__c, 'Account should be set');
    Assert.areEqual(
      'Hello',
      doc.Extracted_Text__c,
      'Extracted text should be stored'
    );
    Assert.areEqual(
      1,
      [
        SELECT COUNT()
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :docId AND ContentDocumentId = :documentId
      ],
      'File should be linked to the Scanned Document'
    );
    Assert.areEqual(
      0,
      [
        SELECT COUNT()
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :acc.Id AND ContentDocumentId = :documentId
      ],
      'Temporary link to the Account should be removed'
    );
    Assert.areEqual(
      1,
      [
        SELECT COUNT()
        FROM ContentWorkspaceDoc
        WHERE ContentDocumentId = :documentId
      ],
      'File should be added to the library'
    );
  }

  @IsTest
  static void saveScannedDocumentRejectsMissingInput() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    try {
      GoogleWebService.saveScannedDocument(acc.Id, '', null);
      Assert.fail('An exception was expected for missing input');
    } catch (AuraHandledException e) {
      Assert.areEqual(
        0,
        [SELECT COUNT() FROM Scanned_document__c],
        'Nothing should be inserted'
      );
    }
  }

  @IsTest
  static void removeFileFromAccountDeletesLink() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Id documentId = createFileOnAccount(acc.Id);

    Test.startTest();
    GoogleWebService.removeFileFromAccount(acc.Id, documentId);
    GoogleWebService.removeFileFromAccount(null, null);
    Test.stopTest();

    Assert.areEqual(
      0,
      [
        SELECT COUNT()
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :acc.Id AND ContentDocumentId = :documentId
      ],
      'Link to the Account should be deleted'
    );
  }
}
