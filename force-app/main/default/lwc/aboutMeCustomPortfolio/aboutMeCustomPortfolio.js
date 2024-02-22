import { LightningElement, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getPortfolio from '@salesforce/apex/aboutMeCustomPortfolioController.getPortfolios';
import getContentDocumentId from '@salesforce/apex/aboutMeCustomPortfolioController.getContentDocumentId';

export default class AboutMeCustomPortfolio extends LightningElement {
    @track portfolioData = { portfolio: null };
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
            if (message.portfolioId) {
                let portfolioIdStr = message.portfolioId.toString(); // Using toString() method
                // let portfolioIdStr = String(message.portfolioId); // Using String() function
                                
                getPortfolio({ portfolioId: portfolioIdStr })
                .then(result => {
                    this.portfolioData.portfolio = result[0]; // Set portfolio to the first item in the result list
                    console.log("Portfolio ", this.portfolioData.portfolio); // Log the portfolio object
                })
                .catch(error => {
                    console.error('Error fetching portfolios:', error);
                    this.error = 'An error occurred while fetching portfolios. Please try again.';
                });
            
                getContentDocumentId({ portfolioId: portfolioIdStr })
                .then(result => {
                    this.contentDocumentId = result; // Set contentDocumentId to the result
                    this.aboutMeImageURL = '/sfc/servlet.shepherd/version/download/' + this.contentDocumentId;
                    console.log("Content Document ID ", this.contentDocumentId); // Log the Content Document ID
                })
                .catch(error => {
                    console.error('Error fetching Content Document ID:', error);
                    this.error = 'An error occurred while fetching Content Document ID. Please try again.';
                });
            }
        }
}
