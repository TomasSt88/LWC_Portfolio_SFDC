@isTest 
private class ScannedDocumentAfterDeleteTest {
    // @isTest 
    // static void testGoogleAPIAndDocumentDeletion() {
    //     // Set the mock callout mode
    //     Test.setMock(HttpCalloutMock.class, new GoogleCloudVisionAPIMock());

    //     Account testAccount = new Account(Name='Test Account');
    //     insert testAccount;

    //     Scanned_document__c testDocument = new Scanned_document__c(Account__c=testAccount.Id);
    //     insert testDocument;

    //     ContentVersion testContent = new ContentVersion(
    //         Title='Test Content',
    //         PathOnClient='Test.jpg',
    //         VersionData=Blob.valueOf('Test Content'),
    //         IsMajorVersion=true
    //     );
    //     insert testContent;

    //     Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContent.Id].ContentDocumentId;

    //     ContentDocumentLink testLink = new ContentDocumentLink(
    //         ContentDocumentId=contentDocumentId,
    //         LinkedEntityId=testDocument.Id,
    //         ShareType='V'
    //     );
    //     insert testLink;

    //     Test.startTest();
    //     String result = GoogleWebService.analyzeImage(contentDocumentId);
    //     System.assertNotEquals(null, result, 'The result should not be null.');
    //     System.assertEquals('Test Text', result, 'The result does not match the expected value.');
    //     delete testDocument;
    //     Test.stopTest();

    //     List<ContentDocument> remainingDocuments = [
    //         SELECT Id
    //         FROM ContentDocument
    //         WHERE Id = :contentDocumentId
    //     ];
    //     System.assertEquals(0, remainingDocuments.size(), 'The related ContentDocument record was not deleted.');
    // }
    
    @isTest static void testDeleteScannedDocument() {

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

        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = scannedDocument.Id,
            ShareType = 'V'
        );
        insert link;

        System.assertEquals(1, [SELECT count() FROM ContentDocument]);

        delete scannedDocument;
        System.debug('@@@ scannedDocument' + scannedDocument);

        System.assertEquals(0, [SELECT count() FROM ContentDocument]);
    }
}