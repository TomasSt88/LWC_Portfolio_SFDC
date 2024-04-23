@isTest
private class BatchDeleteContentDocumentsTest {
    @isTest static void testDeleteOrphanedContentDocuments() {
        Test.setMock(HttpCalloutMock.class, new GoogleCloudVisionAPIMock());

        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        Scanned_document__c scannedDocument = new Scanned_document__c(Account__c=testAccount.Id);
        insert scannedDocument;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test_lastCapturedImage_',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink link;
        if (!contentVersions.isEmpty()) {
            link = new ContentDocumentLink(
                ContentDocumentId = contentVersions[0].ContentDocumentId,
                LinkedEntityId = scannedDocument.Id,
                ShareType = 'V'
            );
            insert link;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            ContentWorkspace workspace = new ContentWorkspace(Name='ScannedImages' + DateTime.now().getTime());
            insert workspace;

            ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc(ContentWorkspaceId=workspace.Id, ContentDocumentId=contentVersions[0].ContentDocumentId);
            insert workspaceDoc;
        }

        delete link;

        Test.startTest();
        BatchDeleteContentDocuments batch = new BatchDeleteContentDocuments();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<Id> contentDocumentIds = new List<Id>{contentVersions[0].ContentDocumentId};
        System.assertEquals(0, [SELECT count() FROM ContentDocument WHERE Id IN :contentDocumentIds]);
    }
}