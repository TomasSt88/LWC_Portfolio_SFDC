import { LightningElement, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getCertificatesAndContentVersionIds from '@salesforce/apex/aboutMeCustomPortfolioController.getCertificatesAndContentVersionIds';

export default class CertificationList extends LightningElement {
    @api recordId;
    certifications = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                FILTERSCHANGEMC,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        if (message.type === 'reset') {
            this.certifications = [];
        } else if (message.portfolioId) {
            let portfolioIdStr = message.portfolioId.toString();
            getCertificatesAndContentVersionIds({ portfolioId: portfolioIdStr })
            .then(certificatesResult => {
                this.certifications = certificatesResult;
                console.log('Fetched certificates:', this.certifications);
            })
            .catch(error => {
                console.error('Error fetching certificates:', error);
            });
        }
    }
}