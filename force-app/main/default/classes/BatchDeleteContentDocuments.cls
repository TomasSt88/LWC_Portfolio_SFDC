global class BatchDeleteContentDocuments implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name = \'ScannedImages\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ContentWorkspaceDoc> scope){
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentWorkspaceDoc cwd : scope) {
            contentDocumentIds.add(cwd.ContentDocumentId);
        }

        List<ContentDocument> contentDocumentsToDelete = new List<ContentDocument>();
        for (ContentDocument cd : [SELECT Id, (SELECT Id FROM ContentDocumentLinks) FROM ContentDocument WHERE Id IN :contentDocumentIds]) {
            if (cd.ContentDocumentLinks.isEmpty()) {
                contentDocumentsToDelete.add(cd);
            }
        }

        delete contentDocumentsToDelete;
    }

    global void finish(Database.BatchableContext BC){
        List<ContentDocument> updatedRecords = [SELECT Id, Title FROM ContentDocument WHERE LastModifiedDate >= :System.now().addMinutes(-10)];
        System.debug('Updated records: ' + updatedRecords);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'tomas.stranak1@gmail.com'});
        mail.setSubject('Batch Job Completed');
        mail.setPlainTextBody('The BatchDeleteContentDocuments batch job has completed. ' + updatedRecords.size() + ' records were updated.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}