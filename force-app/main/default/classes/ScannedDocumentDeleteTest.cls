@isTest
private class ScannedDocumentDeleteTest {
    @isTest static void testDeleteScannedDocument() {
        Test.setMock(HttpCalloutMock.class, new GoogleCloudVisionAPIMock());
    
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
    
        Scanned_document__c scannedDocument = new Scanned_document__c(Account__c=testAccount.Id);
        insert scannedDocument;
    
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
    
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        List<Id> contentDocumentIds = new List<Id>();
        if (!contentVersions.isEmpty()) {
            contentDocumentIds.add(contentVersions[0].ContentDocumentId);
            ContentDocumentLink link = new ContentDocumentLink(
                ContentDocumentId = contentVersions[0].ContentDocumentId,
                LinkedEntityId = scannedDocument.Id,
                ShareType = 'V'
            );
            insert link;
        }
    
        Test.startTest();
        delete scannedDocument;
        Test.stopTest();
    
        System.assertEquals(0, [SELECT count() FROM ContentDocument WHERE Id IN :contentDocumentIds]);
    }
}
