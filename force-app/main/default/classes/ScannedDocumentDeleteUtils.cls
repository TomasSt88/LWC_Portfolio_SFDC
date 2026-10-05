/**
 * Handler for ScannedDocumentTrigger. Captures the files linked to the
 * Scanned Documents before they are deleted (the links disappear with the
 * parent) and removes the underlying ContentDocuments after the delete.
 */
public with sharing class ScannedDocumentDeleteUtils {
  @TestVisible
  private static Set<Id> contentDocumentIds = new Set<Id>();

  public static void handleBeforeDelete(
    List<Scanned_document__c> scannedDocuments
  ) {
    for (ContentDocumentLink link : [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :scannedDocuments
    ]) {
      contentDocumentIds.add(link.ContentDocumentId);
    }
  }

  public static void handleAfterDelete() {
    if (contentDocumentIds.isEmpty()) {
      return;
    }
    List<ContentDocument> docs = [
      SELECT Id
      FROM ContentDocument
      WHERE Id IN :contentDocumentIds
    ];
    // Reset before DML so a re-entrant trigger in the same transaction starts clean.
    contentDocumentIds = new Set<Id>();
    if (!docs.isEmpty()) {
      delete docs;
    }
  }
}
