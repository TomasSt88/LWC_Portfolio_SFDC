import { LightningElement, api } from 'lwc';

export default class CertificationTile extends LightningElement {
    @api certification;
    
    connectedCallback() {
        console.log('Certification Tiles Data:', this.certification);
    }

    // @api
    // set certification(value) {
    //     this._certification = value;
    //     console.log('Certification Tiles Data:', this._certification);
    // }
    
    // get certification() {
    //     return this._certification;
    // }
}
