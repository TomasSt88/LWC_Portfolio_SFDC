import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class CertificationList extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Portfolio__c.Certifications__r'] })
    portfolio;

    get certifications() {
        return this.portfolio.data ? this.portfolio.data.Certifications__r : [];
    }
}
