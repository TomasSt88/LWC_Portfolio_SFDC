public class ScannedDocumentAfterDelete {
    public static void handleTrigger(Map<Id, Scanned_document__c> oldMap) {
        List<Id> documentIds = new List<Id>(oldMap.keySet());

        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :documentIds
        ];
        System.debug('links ' + links);
        if (!links.isEmpty()) {
            delete links;
        }
    }
}
