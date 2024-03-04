public with sharing class aboutMeCustomPortfolioController {
    @AuraEnabled(cacheable=true scope='global')
    public static List<Portfolio__c> getPortfolios(String portfolioId) {
        return [SELECT Id, Name, Invitation__c,
                 Introduction__c,Introduction_paragraph__c,About_Me_Heading__c,
                 About_Me_paragraph__c,Experiences_Heading__c, Experiences_Paragraph__c
                FROM Portfolio__c 
                WHERE Id = :portfolioId];
    }

    @AuraEnabled(cacheable=true scope='global')
    public static String getContentDocumentIdPortfolio(String portfolioId) {
        ContentDocumentLink docLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :portfolioId LIMIT 1];
        ContentVersion version = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
        return version.Id;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<Certificate__c> getCertificates(String portfolioId) {
        List<Certificate__c> certificates = [SELECT Id, Name, Certificates_reached__c,
                                             (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                             FROM Certificate__c
                                             WHERE Portfolio__c = :portfolioId];
        System.debug('Certificates: ' + certificates);
        return certificates;
    }
    
    @AuraEnabled(cacheable=true scope='global')
    public static List<String> getContentVersionIds(String portfolioId) {
        List<String> contentVersionIds = new List<String>();
        List<Certificate__c> certificates = [SELECT Id FROM Certificate__c WHERE Portfolio__c = :portfolioId];
        for (Certificate__c certificate : certificates) {
            List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :certificate.Id];
            for (ContentDocumentLink docLink : docLinks) {
                List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
                for (ContentVersion version : versions) {
                    contentVersionIds.add(version.Id);
                }
            }
        }
        System.debug('Certificates content Versions: ' + contentVersionIds);
        return contentVersionIds;
    }
}