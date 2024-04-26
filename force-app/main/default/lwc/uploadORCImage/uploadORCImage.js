import { LightningElement, track, api, wire } from 'lwc';
import analyzeImage from '@salesforce/apex/GoogleWebService.analyzeImage';
import createDocument from '@salesforce/apex/GoogleWebService.createDocument';
import removeFileFromAccount from '@salesforce/apex/GoogleWebService.removeFileFromAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class uploadORCImage extends LightningElement {
    @api recordId;
    @track imageUrl;
    @track extractedText;
    contentDocumentId;
    accountId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Id']})
    wiredDocument({ error, data }) {
        if (data) {
           this.accountId = getFieldValue(data, 'Account.Id');
           // this.accountId = data.fields.Id.value; // alternative solution, in this case is getFieldValue not needed
            if (this.accountId) {
                this.template.querySelector('lightning-input-field').value = this.accountId;
            }
        } else if (error) {
            console.error(error);
        }
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value;
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
        const uploadedFiles = event.detail.files;
        this.contentDocumentId = uploadedFiles[0].documentId;
        this.imageUrl = '/sfc/servlet.shepherd/document/download/' + this.contentDocumentId;
    }

    analyzeImage() {
        analyzeImage({ contentDocumentId: this.contentDocumentId })
            .then(result => {
                if (result) {
                    this.extractedText = result;
                    this.adjustTextareaHeight();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'No Text Found',
                            message: 'No text could be extracted from the image.',
                            variant: 'info'
                        })
                    );
                }
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
    saveDocument() {
        if (this.accountId) {
            createDocument({ accountId: this.accountId.toString(), extractedText: this.extractedText, contentDocumentId: this.contentDocumentId })
            removeFileFromAccount({ accountId: this.accountId.toString(), contentDocumentId: this.contentDocumentId })
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
                    window.location.reload();
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
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No Account selected.',
                    variant: 'error'
                })
            );
        }
    }
    
    clear() {
        this.imageUrl = '';
        this.extractedText = '';
    
        removeFileFromAccount({ accountId: this.accountId.toString(), contentDocumentId: this.contentDocumentId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File has been removed from the Account successfully.',
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
                        message: 'Something went wrong while removing the file from the Account: ' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }   
    
    adjustTextareaHeight() {
        const textarea = this.template.querySelector('textarea');
        const text = this.extractedText || '';
        const numberOfLines = Math.min(Math.floor(text.length / 10), 30);
        textarea.style.height = `${numberOfLines * 1.2}em`;
    }
}