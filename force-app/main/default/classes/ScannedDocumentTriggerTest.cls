@isTest
public class ScannedDocumentTriggerTest {
    @isTest static void testScannedDocumentTrigger() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Scanned_document__c doc = new Scanned_document__c(Account__c = acc.Id);
        insert doc;

        Scanned_document__c insertedDoc = [SELECT Account_link__c FROM Scanned_document__c WHERE Id = :doc.Id];

        System.assertEquals(acc.Id, insertedDoc.Account_link__c);
    }
}
