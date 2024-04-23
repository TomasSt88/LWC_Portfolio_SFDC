public class ScannedDocumentDeleteUtils {
    public static List<Id> contentDocumentIds = new List<Id>();

    public static void handleBeforeDelete(List<Scanned_document__c> scannedDpcumentsList) {
        for (Scanned_document__c scannedDpcument : scannedDpcumentsList) {
            List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :scannedDpcument.Id];
            for (ContentDocumentLink link : links) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
        }            
        System.debug('handleBeforeDelete executed');
    }

    public static void handleAfterDelete() {
        if (!contentDocumentIds.isEmpty()) {
            delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
        }
        System.debug('handleAfterDelete executed');
    }
}