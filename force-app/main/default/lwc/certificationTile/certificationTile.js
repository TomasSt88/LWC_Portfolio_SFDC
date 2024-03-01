import { LightningElement, api } from 'lwc';

export default class CertificationTile extends LightningElement {
    @api
    get certification() {
        return this._certification;
    }
    set certification(value) {
        this._certification = value;
        this.processCertification();
    }
    
    processCertification() {
        console.log('Certification Tiles Data:', this._certification);
        // additional processing here
    }

    // In CertificationTile component
    connectedCallback() {
        console.log('CertificationTile connected');
    }

    renderedCallback() {
        console.log('CertificationTile rendered');
    }

}