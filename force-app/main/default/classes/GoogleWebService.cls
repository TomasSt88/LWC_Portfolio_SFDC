public with sharing class GoogleWebService {
    // @AuraEnabled
    // public static String analyzeImage(String imageUrl) {
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:Google_New');
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type', 'application/json');

    //     String body = '{"requests":[{"image":{"source":{"imageUri":"' + imageUrl + '"}},"features":[{"type":"TEXT_DETECTION"}]}]}';
    //     req.setBody(body);

    //     Http http = new Http();
    //     HttpResponse res = http.send(req);
    //     return res.getBody();
    // }

    @AuraEnabled
    public static String analyzeImage(String base64String) {
        // Convert the base64 string to a Blob
        Blob imageBlob = EncodingUtil.base64Decode(base64String);
    
        // Create a new HttpRequest
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_New');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
    
        // Set the body of the request
        String body = '{"requests":[{"image":{"content":"' + base64String + '"},"features":[{"type":"TEXT_DETECTION"}]}]}';
        req.setBody(body);
    
        // Send the request and return the response body
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();
    }
    

}