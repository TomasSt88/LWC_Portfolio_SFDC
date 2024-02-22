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
    public static String getContentDocumentId(String portfolioId) {
        ContentDocumentLink docLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :portfolioId LIMIT 1];
        ContentVersion version = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
        return version.Id;
    }
}
