/**
 * Deletes orphaned ContentDocument records: files that are not CMS assets,
 * are not stored in a Content library, and are not linked to any User.
 * Implements Database.Stateful so the counters survive across chunks.
 */
public with sharing class BatchDeleteContentDocuments implements Database.Batchable<SObject>, Database.Stateful {
  @TestVisible
  private Integer recordsDeleted = 0;
  @TestVisible
  private Integer recordsFailed = 0;

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id
        FROM ContentDocument
        WHERE
          ContentAssetId = NULL
          AND Id NOT IN (SELECT ContentDocumentId FROM ContentWorkspaceDoc)
      ]
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<ContentDocument> scope
  ) {
    // Documents linked to a User are kept. Filtering per chunk keeps the
    // query bound-variable based instead of concatenating Ids into a string.
    Set<Id> userLinkedDocumentIds = new Set<Id>();
    for (ContentDocumentLink link : [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE
        ContentDocumentId IN :scope
        AND LinkedEntityId IN (SELECT Id FROM User)
    ]) {
      userLinkedDocumentIds.add(link.ContentDocumentId);
    }

    List<ContentDocument> toDelete = new List<ContentDocument>();
    for (ContentDocument doc : scope) {
      if (!userLinkedDocumentIds.contains(doc.Id)) {
        toDelete.add(doc);
      }
    }
    if (toDelete.isEmpty()) {
      return;
    }

    for (Database.DeleteResult result : Database.delete(toDelete, false)) {
      if (result.isSuccess()) {
        recordsDeleted++;
      } else {
        recordsFailed++;
        System.debug(
          LoggingLevel.ERROR,
          'ContentDocument delete failed: ' + result.getErrors()
        );
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    List<AsyncApexJob> jobs = [
      SELECT CreatedBy.Email
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
      LIMIT 1
    ];
    if (jobs.isEmpty() || String.isBlank(jobs[0].CreatedBy.Email)) {
      return;
    }

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ jobs[0].CreatedBy.Email });
    mail.setSubject('BatchDeleteContentDocuments completed');
    mail.setPlainTextBody(
      'The BatchDeleteContentDocuments batch job has completed. ' +
        recordsDeleted +
        ' records were deleted, ' +
        recordsFailed +
        ' failed.'
    );
    if (!Test.isRunningTest()) {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}
