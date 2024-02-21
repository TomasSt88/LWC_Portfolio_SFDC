public with sharing class CertificateController {
    @AuraEnabled(cacheable=true scope='global')
    public static List<Certificate__c> getCertificates(String certificateId) {
        System.debug('Portfolio Id ' + certificateId);
        return [SELECT Id, Name, Certificates_reached__c FROM Certificate__c WHERE Id = :certificateId];
    }

    private static final Integer DEFAULT_PAGE_SIZE = 9;

    /**
     * Endpoint that retrieves a paged and filtered list of properties
     * @param searchKey String used for searching on property title, city and tags
     * @param pageSize Number of properties per page
     * @param pageNumber Page number
     * @return PagedResult object holding the paged and filtered list of properties
     */
    @AuraEnabled(cacheable=true scope='global')
    public static PagedResult getPagedCerrificatesList(
        String searchKey,
        Integer pageSize,
        Integer pageNumber
    ) {
        // Normalize inputs
        Integer safePageSize = (pageSize == null
            ? DEFAULT_PAGE_SIZE
            : pageSize);
        Integer safePageNumber = (pageNumber == null ? 1 : pageNumber);

        String searchPattern = '%' + searchKey + '%';
        Integer offset = (safePageNumber - 1) * safePageSize;

        PagedResult result = new PagedResult();
        result.pageSize = safePageSize;
        result.pageNumber = safePageNumber;
        result.totalItemCount = [
            SELECT COUNT()
            FROM Portfolio__c
            WHERE
                (Name LIKE :searchPattern)
        ];
        result.records = [
            SELECT
                Id,
                Name
            FROM Portfolio__c
            WHERE
                (Name LIKE :searchPattern)
            WITH USER_MODE
            LIMIT :safePageSize
            OFFSET :offset
        ];
        system.debug('result ' + result);
        return result;
    }

    /**
     * Endpoint that retrieves pictures associated with a property
     * @param propertyId Property Id
     * @return List of ContentVersion holding the pictures
     */
    @AuraEnabled(cacheable=true scope='global')
    public static List<ContentVersion> getPictures(Id propertyId) {
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :propertyId
                AND ContentDocument.FileType IN ('PNG', 'JPG', 'GIF')
            WITH USER_MODE
        ];

        if (links.isEmpty()) {
            return null;
        }

        Set<Id> contentIds = new Set<Id>();

        for (ContentDocumentLink link : links) {
            contentIds.add(link.ContentDocumentId);
        }

        return [
            SELECT Id, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentIds AND IsLatest = TRUE
            WITH USER_MODE
            ORDER BY CreatedDate
        ];
    }
}