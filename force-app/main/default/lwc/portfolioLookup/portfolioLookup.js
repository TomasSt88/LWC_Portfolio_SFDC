import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';

const DELAY = 350;

export default class portfolioLookup extends LightningElement {
    portfolioId = '';

    @wire(MessageContext)
    messageContext;

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.fireChangeEvent();
        console.log("portfolio handleReset" + this.portfolioId);
    }

    handlePortfolioIdChange(event) {
        this.portfolioId = event.detail.value;
        this.fireChangeEvent();
        console.log("portfolio handlePortfolioIdChange" + this.portfolioId);
    }

    fireChangeEvent() {
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            const filters = {
                portfolioId: this.portfolioId
            };
            publish(this.messageContext, FILTERSCHANGEMC, filters);
        }, DELAY);
        console.log("portfolio Fire Change event" + this.portfolioId);
    }
}

