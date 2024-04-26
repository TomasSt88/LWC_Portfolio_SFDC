public class ScannedDocumentDeleteUtils {
    public static List<Id> contentDocumentIds = new List<Id>();
    
    public static void handleBeforeDelete(List<Scanned_document__c> scannedDocumentsList) {
        for (Scanned_document__c scannedDocument : scannedDocumentsList) {
            List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :scannedDocument.Id];
            for (ContentDocumentLink link : links) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
        }            
    }

    public static void handleAfterDelete() {
        if (!contentDocumentIds.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
        }
    }
}