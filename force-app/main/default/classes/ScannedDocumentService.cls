public with sharing class ScannedDocumentService {
    public static void handleBeforeInsertUpdate(List<Scanned_document__c> docs) {
        for (Scanned_document__c doc : docs) {
            if (doc.Account_link__c == null && doc.Account__c != null) {
                doc.Account_link__c = doc.Account__c;
            }
        }
    }
}