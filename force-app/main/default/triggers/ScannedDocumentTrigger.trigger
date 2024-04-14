trigger ScannedDocumentTrigger on Scanned_document__c (after delete) {
    ScannedDocumentAfterDelete.handleTrigger(Trigger.oldMap);
}