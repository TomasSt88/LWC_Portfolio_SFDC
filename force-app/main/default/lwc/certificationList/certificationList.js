import { LightningElement, api, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getCertificates from '@salesforce/apex/aboutMeCustomPortfolioController.getCertificates';

export default class CertificationList extends LightningElement {
    @api recordId;
    certificatesData = { portfolio: null };
    certifications = [];
    subscription = null;

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
            
            Promise.all([
                getCertificates({ portfolioId: portfolioIdStr }),
            ])
            .then(certificatesResult => {
                this.certificatesData.portfolio = certificatesResult[0];
                this.certifications = certificatesResult[0]; // Update certifications
                console.log('Fetched certificates:', certificatesResult);
            })
            .catch(error => {
                console.error('Error fetching portfolio:', error); 
            });
        }
    }
}
