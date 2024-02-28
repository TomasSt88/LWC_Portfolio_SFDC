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
        List<Certificate__c> certificates = [SELECT Id, Name, Certificates_reached__c
                                             FROM Certificate__c
                                             WHERE Portfolio__c = :portfolioId];
        System.debug('Certificates: ' + certificates);
        return certificates;
    }
    
    @AuraEnabled(cacheable=true scope='global')
    public static Map<Id, Id> getContentDocumentIdCertificates(List<Id> certificateIds) {
        Map<Id, Id> certificateContentVersions = new Map<Id, Id>();
        for (Id certificateId : certificateIds) {
            try {
                ContentDocumentLink docLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :certificateId LIMIT 1];
                ContentVersion version = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
                System.debug('ContentVersion for ' + certificateId + ': ' + version.Id);
                certificateContentVersions.put(certificateId, version.Id);
            } catch (Exception e) {
                System.debug('No ContentVersion found for ' + certificateId);
            }
        }
        System.debug('ContentVersion for ' + certificateContentVersions);
        return certificateContentVersions;
    }
}
