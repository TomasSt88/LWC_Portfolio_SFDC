trigger ScannedDocumentTrigger on Scanned_document__c (before insert, before update) {
    ScannedDocumentService.handleBeforeInsertUpdate(Trigger.new);
}