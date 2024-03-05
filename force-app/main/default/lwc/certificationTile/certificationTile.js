import { LightningElement, api } from 'lwc';

export default class CertificationTile extends LightningElement {
    @api certification;
    get imageUrl() {
        return '/sfc/servlet.shepherd/version/download/' + this.certification['ContentVersion Id'];
    }
}
