import { LightningElement, api } from 'lwc';
import getContentVersionIds from '@salesforce/apex/aboutMeCustomPortfolioController.getContentVersionIds';

export default class CertificationTile extends LightningElement {
    @api certification;
    imageUrl;

    connectedCallback() {
        this.fetchImageUrl();
    }

    fetchImageUrl() {
        getContentVersionIds({ portfolioId: this.certification.Id })
        .then(contentDocumentIdResult => {
            this.imageUrl = '/sfc/servlet.shepherd/version/download/' + contentDocumentIdResult;
        })
        .catch(error => {
            console.error('Error fetching ContentDocumentId:', error);
        });
    }
}
