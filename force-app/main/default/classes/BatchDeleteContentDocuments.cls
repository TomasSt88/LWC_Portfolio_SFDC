global class BatchDeleteContentDocuments implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspace.Name = \'ScannedImages\' AND ContentDocument.Title LIKE \'%_lastCapturedImage_%\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ContentWorkspaceDoc> scope){
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentWorkspaceDoc cwd : scope) {
            contentDocumentIds.add(cwd.ContentDocumentId);
        }
        List<ContentDocument> contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
        delete contentDocumentsToDelete;
    }

    global void finish(Database.BatchableContext BC){
    }
}