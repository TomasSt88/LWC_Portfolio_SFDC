global class BatchDeleteContentDocuments implements Database.Batchable<sObject> {
    global Integer recordsDeleted = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocument doc : [ SELECT Id 
                                     FROM ContentDocument 
                                     WHERE ContentAssetId = NULL 
                                     AND Id NOT IN (
                                         SELECT ContentDocumentId 
                                         FROM ContentWorkspaceDoc) 
                                    ]
        ) {
            contentDocumentIds.add(doc.Id);
        }
        System.debug('Content Document IDs: ' + contentDocumentIds.size() + ' ist of ID ' + contentDocumentIds );

        List<Id> linkedContentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM User)]) {
            linkedContentDocumentIds.add(link.ContentDocumentId);
        }
        System.debug('Linked Content Document IDs: ' + linkedContentDocumentIds.size() + ' list of ID ' + linkedContentDocumentIds  );

        String query = 'SELECT Id FROM ContentDocument WHERE Id IN (\'' + String.join(contentDocumentIds, '\',\'') + '\') AND Id NOT IN (\'' + String.join(linkedContentDocumentIds, '\',\'') + '\')';
        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ContentDocument> scope){
        recordsDeleted += scope.size();
        System.debug('recordsDeleted ' + recordsDeleted);
        try {
            System.debug('scope ' + scope);
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