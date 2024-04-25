@isTest 
private class BatchDeleteContentDocumentsTest {
    @testSetup 
    static void setup() {
        // Setup
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        System.debug('Test Account: ' + testAccount);
    
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test_lastCapturedImage_',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        System.debug('Content Version: ' + contentVersion);
    
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        System.debug('Content Document ID: ' + contentDocumentId);
    
        System.runAs(new User(Id = UserInfo.getUserId())) {
            String workspaceName = 'ScannedImages';
            ContentWorkspace workspace;
            
            List<ContentWorkspace> existingWorkspaces = [SELECT Id FROM ContentWorkspace WHERE Name = :workspaceName];
            if (existingWorkspaces.isEmpty()) {
                workspace = new ContentWorkspace(Name=workspaceName);
                insert workspace;
            } else {
                workspace = existingWorkspaces[0];
            }
            System.debug('Content Document workspace: ' + workspace);
    
            ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc(ContentWorkspaceId=workspace.Id, ContentDocumentId=contentDocumentId);
            insert workspaceDoc;
            System.debug('Content Document workspaceDoc: ' + workspaceDoc);
        }
    }

    @isTest 
    static void testBatchDeleteContentDocuments() {
        List<ContentDocument> initialContentDocuments = [SELECT Id FROM ContentDocument];
        System.assertNotEquals(0, initialContentDocuments.size(), 'There should be at least one ContentDocument record for the test.');
        System.debug('Initial Content Documents: ' + initialContentDocuments);

        Test.startTest();
        BatchDeleteContentDocuments batch = new BatchDeleteContentDocuments();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        System.assertEquals(0, contentDocuments.size(), 'All ContentDocument records should have been deleted.');
        System.debug('Content Documents after batch execution: ' + contentDocuments);

        // Integer expectedRecordsDeleted = contentDocumentIds.size() - linkedContentDocumentIds.size();
        // System.assertEquals(expectedRecordsDeleted, batch.recordsDeleted, 'All records that meet the criteria should have been deleted.');
    }
} 
