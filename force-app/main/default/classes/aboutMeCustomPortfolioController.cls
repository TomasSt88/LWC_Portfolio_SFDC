public with sharing class aboutMeCustomPortfolioController {
  @AuraEnabled(cacheable=true scope='global')
  public static List<Portfolio__c> getPortfolios(String portfolioId) {
    return [
      SELECT
        Id,
        Name,
        Invitation__c,
        Introduction__c,
        Introduction_paragraph__c,
        About_Me_Heading__c,
        About_Me_paragraph__c,
        Experiences_Heading__c,
        Experiences_Paragraph__c
      FROM Portfolio__c
      WHERE Id = :portfolioId
    ];
  }

  @AuraEnabled(cacheable=true scope='global')
  public static String getContentDocumentIdPortfolio(String portfolioId) {
    List<ContentDocumentLink> docLinks = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :portfolioId
      LIMIT 1
    ];
    if (docLinks.isEmpty()) {
      return null;
    }
    List<ContentVersion> versions = [
      SELECT Id
      FROM ContentVersion
      WHERE
        ContentDocumentId = :docLinks[0].ContentDocumentId
        AND IsLatest = TRUE
      LIMIT 1
    ];
    return versions.isEmpty() ? null : versions[0].Id;
  }

  @AuraEnabled(cacheable=true scope='global')
  public static List<Map<String, Object>> getCertificatesAndContentVersionIds(
    String portfolioId
  ) {
    List<Certificate__c> certificates = [
      SELECT
        Id,
        Name,
        Certificates_reached__c,
        (SELECT ContentDocumentId FROM ContentDocumentLinks)
      FROM Certificate__c
      WHERE Portfolio__c = :portfolioId
    ];

    // Collect every linked file first so ContentVersion is queried once, not per certificate.
    Map<Id, Id> certificateByDocumentId = new Map<Id, Id>();
    for (Certificate__c certificate : certificates) {
      for (ContentDocumentLink docLink : certificate.ContentDocumentLinks) {
        certificateByDocumentId.put(docLink.ContentDocumentId, certificate.Id);
      }
    }

    Map<Id, Id> latestVersionByCertificateId = new Map<Id, Id>();
    if (!certificateByDocumentId.isEmpty()) {
      for (ContentVersion version : [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE
          ContentDocumentId IN :certificateByDocumentId.keySet()
          AND IsLatest = TRUE
      ]) {
        latestVersionByCertificateId.put(
          certificateByDocumentId.get(version.ContentDocumentId),
          version.Id
        );
      }
    }

    List<Map<String, Object>> certificatesList = new List<Map<String, Object>>();
    for (Certificate__c certificate : certificates) {
      certificatesList.add(
        new Map<String, Object>{
          'Id' => certificate.Id,
          'Name' => certificate.Name,
          'Certificates_reached__c' => certificate.Certificates_reached__c,
          'ContentVersion Id' => latestVersionByCertificateId.get(
            certificate.Id
          )
        }
      );
    }
    return certificatesList;
  }
}
