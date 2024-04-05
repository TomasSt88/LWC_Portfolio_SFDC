import { LightningElement, track } from 'lwc';
import analyzeImage from '@salesforce/apex/GoogleWebService.analyzeImage';

export default class MyComponent extends LightningElement {
    @track imageUrl;
    @track extractedText;

    allowDrop(dragEvent) {
        dragEvent.preventDefault();
    }

    handleDrop(dropEvent) {
        dropEvent.preventDefault();
        let files = dropEvent.dataTransfer.files;
        if (files.length > 0) {
            let reader = new FileReader();
            reader.onload = (loadEvent) => {
                let base64String = loadEvent.target.result.split(',')[1];
                this.imageUrl = loadEvent.target.result;
                analyzeImage({ base64String: base64String })
                    .then(result => {
                        this.extractedText = result;
                    })
                    .catch(error => {
                        console.error(error);
                    });
            };
            reader.readAsDataURL(files[0]);
        }
    }

    analyzeImage() {
        let base64String = this.imageUrl.split(',')[1];
        analyzeImage({ base64String: base64String })
            .then(result => {
                this.extractedText = result;
            })
            .catch(error => {
                console.error(error);
            });
    }
}
