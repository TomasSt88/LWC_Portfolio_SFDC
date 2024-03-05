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
    public static List<Map<String, Object>> getCertificatesAndContentVersionIds(String portfolioId) {
        List<Map<String, Object>> certificatesList = new List<Map<String, Object>>();
        List<Certificate__c> certificates = [SELECT Id, Name, Certificates_reached__c,
                                             (SELECT ContentDocumentId FROM ContentDocumentLinks)
                                             FROM Certificate__c
                                             WHERE Portfolio__c = :portfolioId];
        for (Certificate__c certificate : certificates) {
            Map<String, Object> certificateMap = new Map<String, Object>();
            certificateMap.put('Id', certificate.Id);
            certificateMap.put('Name', certificate.Name);
            certificateMap.put('Certificates_reached__c', certificate.Certificates_reached__c);
            List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :certificate.Id];
            for (ContentDocumentLink docLink : docLinks) {
                List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
                for (ContentVersion version : versions) {
                    certificateMap.put('ContentVersion Id', version.Id);
                }
            }
            certificatesList.add(certificateMap);
        }
        return certificatesList;
    }
}