import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const PACCLOOKUP = ['Lead.Source_Account__c'];

export default class accountPopulateLookup extends LightningElement {
    @api recordId; // This represents the ID of the current record
    // Define the fields you want to retrieve from the current record
    @wire(getRecord, { recordId: '$recordId', fields: PACCLOOKUP })
    record;

    get lookupDefaultValue() {
        return this.record.data ? this.record.data.fields.Source_Account__c.value : null;
    }
}