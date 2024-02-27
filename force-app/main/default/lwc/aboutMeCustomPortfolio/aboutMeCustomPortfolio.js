import { LightningElement, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getPortfolio from '@salesforce/apex/aboutMeCustomPortfolioController.getPortfolios';
import getContentDocumentId from '@salesforce/apex/aboutMeCustomPortfolioController.getContentDocumentId';

export default class AboutMeCustomPortfolio extends LightningElement {
    @track portfolioData = { portfolio: null };
    @track aboutMeImageData = { aboutMeImageURL: null };
    @track isLoading = false; // Add a loading state
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
        if (message.type === 'reset') {
            // Clear the data
            this.portfolioData = { portfolio: null };
            this.aboutMeImageData = { aboutMeImageURL: null };
        } else if (message.portfolioId) {
            let portfolioIdStr = message.portfolioId.toString();
    
            Promise.all([
                getPortfolio({ portfolioId: portfolioIdStr }),
                getContentDocumentId({ portfolioId: portfolioIdStr })
            ])
            .then(([portfolioResult, contentDocumentIdResult]) => {
                this.portfolioData.portfolio = portfolioResult[0];
                this.aboutMeImageData.aboutMeImageURL = '/sfc/servlet.shepherd/version/download/' + contentDocumentIdResult;
                this.isLoading = false; // Set loading state to false once data has been loaded
            })
            .catch(error => {
                console.error('Error:', error);
                this.error = 'An error occurred. Please check the portfolio ID and try again.';
                this.isLoading = false; // Set loading state to false even if an error occurs
            });
        }
    }
}
