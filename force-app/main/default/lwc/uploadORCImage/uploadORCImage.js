import { LightningElement, track, api, wire } from 'lwc';
import analyzeImage from '@salesforce/apex/GoogleWebService.analyzeImage';
import createDocument from '@salesforce/apex/GoogleWebService.createDocument';
import getAccounts from '@salesforce/apex/GoogleWebService.getAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

export default class MyComponent extends LightningElement {
    @api recordId;
    @track imageUrl;
    @track extractedText;
    @track accountOptions = [];
    contentDocumentId;
    accountId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountId = this.recordId;
        } else if (error) {
            console.error(error);
        }
    }


    @wire(getAccounts)
    accounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(account => {
                return { label: account.Name, value: account.Id };
            });
            this.accountOptions.unshift({ label: '--None--', value: '' });
        } else if (error) {
            console.error(error);
        }
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value;
    }


    allowDrop(dragEvent) {
        dragEvent.preventDefault();
    }

    handleDrop(dropEvent) {
        dropEvent.preventDefault();
        let files = dropEvent.dataTransfer.files;
        if (files.length > 0) {
            let reader = new FileReader();
            reader.onload = (loadEvent) => {
                this.imageUrl = loadEvent.target.result;
            };
            reader.readAsDataURL(files[0]);
        }
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.contentDocumentId = uploadedFiles[0].documentId;
        this.imageUrl = '/sfc/servlet.shepherd/document/download/' + this.contentDocumentId;
    }

    analyzeImage() {
        analyzeImage({ contentDocumentId: this.contentDocumentId })
            .then(result => {
                this.extractedText = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    saveDocument() {
        createDocument({ accountId: this.recordId, extractedText: this.extractedText, contentDocumentId: this.contentDocumentId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Extracted Text has been saved successfully.',
                        variant: 'success',
                        mode: 'dismissable',
                        duration: 3000
                    })
                );
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong: ' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    clear() {
        this.imageUrl = '';
        this.extractedText = '';
    }
}
