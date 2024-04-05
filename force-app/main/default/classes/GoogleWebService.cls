public with sharing class GoogleWebService {
    @AuraEnabled
    public static String analyzeImage(String base64String) {
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
}