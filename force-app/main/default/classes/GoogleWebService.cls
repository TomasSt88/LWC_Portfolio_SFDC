public with sharing class GoogleWebService {
    @AuraEnabled
    public static String analyzeImage(String contentDocumentId) {
        ContentVersion version = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true
            LIMIT 1
        ];

        String base64String = EncodingUtil.base64Encode(version.VersionData);
        Blob imageBlob = EncodingUtil.base64Decode(base64String);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_New');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String body = '{"requests":[{"image":{"content":"' + base64String + '"},"features":[{"type":"TEXT_DETECTION"}]}]}';
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> responses = (List<Object>) responseMap.get('responses');
        Map<String, Object> firstResponse = (Map<String, Object>) responses[0];
        List<Object> textAnnotations = (List<Object>) firstResponse.get('textAnnotations');
        Map<String, Object> firstTextAnnotation = (Map<String, Object>) textAnnotations[0];
        String extractedText = (String) firstTextAnnotation.get('description');

        return extractedText;
    }
    
    @AuraEnabled
    public static void createDocument(String accountId, String extractedText, String contentDocumentId) {
        Scanned_document__c doc = new Scanned_document__c();
        doc.Account__c = accountId;
        doc.Extracted_Text__c = extractedText;
        insert doc;

        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = contentDocumentId;
        link.LinkedEntityId = doc.Id;
        link.ShareType = 'V';
        insert link;

        Id libraryId = [SELECT Id FROM ContentWorkspace WHERE Name = 'ScannedImages' LIMIT 1].Id;
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
        cwd.ContentDocumentId = contentDocumentId;
        cwd.ContentWorkspaceId = libraryId;
        insert cwd;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchedAccount) {
        return [SELECT Id, Name FROM Account where Id=:searchedAccount];
    }

    @AuraEnabled
    public static void removeFileFromAccount(String accountId, String contentDocumentId) {
        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :accountId AND ContentDocumentId = :contentDocumentId
        ];
    
        if (!links.isEmpty()) {
            delete links;
        }
    }
}