trigger ScannedDocumentTrigger on Scanned_document__c (before delete, after delete) {
    if (Trigger.isBefore) {
        ScannedDocumentDeleteUtils.handleBeforeDelete(Trigger.old);
    } else if (Trigger.isAfter) {
        ScannedDocumentDeleteUtils.handleAfterDelete();
    }
}