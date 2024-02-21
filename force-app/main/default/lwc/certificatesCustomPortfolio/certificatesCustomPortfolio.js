import { LightningElement, wire } from 'lwc';
import {
    publish,
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';
import getPagedCerrificatesList from '@salesforce/apex/CertificateController.getPagedCerrificatesList';

const PAGE_SIZE = 9;

export default class certificatesCustomPortfolio extends LightningElement {
    pageNumber = 1;
    pageSize = PAGE_SIZE;

    searchKey = '';

    @wire(MessageContext)
    messageContext;

    @wire(getPagedCerrificatesList, {
        searchKey: '$searchKey',
        pageSize: '$pageSize',
        pageNumber: '$pageNumber'
    })
    properties;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            FILTERSCHANGEMC,
            (message) => {
                this.handleFilterChange(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleFilterChange(filters) {
        this.searchKey = filters.searchKey;
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }

    handleCertificateSelected(event) {
        const message = { propertyId: event.detail };
        publish(this.messageContext, PROPERTYSELECTEDMC, message);
    }
}