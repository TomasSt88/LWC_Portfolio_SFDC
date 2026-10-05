trigger ScannedDocumentTrigger on Scanned_document__c(
  before delete,
  after delete
) {
  if (Trigger.isDelete && Trigger.isBefore) {
    ScannedDocumentDeleteUtils.handleBeforeDelete(Trigger.old);
  } else if (Trigger.isDelete && Trigger.isAfter) {
    ScannedDocumentDeleteUtils.handleAfterDelete();
  }
}
