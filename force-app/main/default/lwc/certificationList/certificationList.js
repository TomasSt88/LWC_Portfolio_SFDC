import { LightningElement, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getCertificates from '@salesforce/apex/aboutMeCustomPortfolioController.getCertificates';

export default class CertificationList extends LightningElement {
    @api recordId;
    certificatesData = { portfolio: null };
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
        console.log('Received message:', message);
        
        if (message.type === 'reset') {
            this.certificatesData = { portfolio: null };
        } else if (message.portfolioId) {
            let portfolioIdStr = message.portfolioId.toString();
            console.log('Fetching portfolio with ID:', portfolioIdStr);
            
            getCertificates({ portfolioId: portfolioIdStr })
            .then(certificatesResult => {
                this.certifications = certificatesResult; // Changed this line
                console.log('Fetched certificates:', this.certifications);
            })
            .catch(error => {
                console.error('Error fetching certificates:', error);
            });
        }
    }
}
