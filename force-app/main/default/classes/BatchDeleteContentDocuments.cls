global class BatchDeleteContentDocuments implements Database.Batchable<sObject> {
    global Integer recordsDeleted = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Get the IDs of the ContentDocuments in the 'ScannedImages' workspace
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentWorkspaceDoc doc : [SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name = 'ScannedImages']) {
            contentDocumentIds.add(doc.ContentDocumentId);
        }
        System.debug('Content Document IDs: ' + contentDocumentIds.size());

        // Get the IDs of the ContentDocuments linked to Scanned_document__c records
        List<Id> linkedContentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Scanned_document__c)]) {
            linkedContentDocumentIds.add(link.ContentDocumentId);
        }
        System.debug('Linked Content Document IDs: ' + linkedContentDocumentIds.size());

        // Filter the ContentDocuments to get the ones that are not linked to Scanned_document__c records
        String query = 'SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds AND Id NOT IN :linkedContentDocumentIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ContentDocument> scope){
        recordsDeleted += scope.size();
        try {
            delete scope;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Deleted records: ' + recordsDeleted);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'tomas.stranak1@gmail.com'});
        mail.setSubject('Batch Job Completed');
        mail.setPlainTextBody('The BatchDeleteContentDocuments batch job has completed. ' + recordsDeleted + ' records were deleted.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
