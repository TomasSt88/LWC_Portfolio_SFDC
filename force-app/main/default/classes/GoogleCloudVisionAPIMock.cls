@isTest
global class GoogleCloudVisionAPIMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"textAnnotations":[{"description":"Test Text"}]}]}');
        res.setStatusCode(200);
        return res;
    }
}