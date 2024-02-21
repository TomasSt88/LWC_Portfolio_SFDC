import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class CertificateTile extends NavigationMixin(LightningElement) {
    @api certificate;
    formFactor = FORM_FACTOR;

    handleCertificateSelected() {
        if (FORM_FACTOR === 'Small') {
            // In Phones, navigate to certificate record page directly
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.certificate.Id,
                    objectApiName: 'Certificate__c',
                    actionName: 'view'
                }
            });
        } else {
            // In other devices, send message to other cmps on the page
            const selectedEvent = new CustomEvent('selected', {
                detail: this.certificate.Id
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    get backgroundImageStyle() {
        return `background-image:url(${this.certificate.Thumbnail__c})`;
    }
}
