import { LightningElement, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import getPortfolios from '@salesforce/apex/aboutMeCustomPortfolioController.getPortfolios';
import IMAGES from '@salesforce/resourceUrl/Images';

export default class AboutMeCustomPortfolio extends LightningElement {
    aboutMeImageURL = IMAGES + '/about-me.png';

    @track portfolio;
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
                                
                getPortfolios({ portfolioId: portfolioIdStr })
                .then(result => {
                    this.portfolio = result[0]; // Set portfolio to the first item in the result list
                    console.log("Portfolio ", this.portfolio); // Log the portfolio object
                })
                .catch(error => {
                    console.error('Error fetching portfolios:', error);
                    this.error = 'An error occurred while fetching portfolios. Please try again.';
                });
            }
        }
}
