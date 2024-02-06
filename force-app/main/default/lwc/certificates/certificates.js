import { LightningElement } from 'lwc';
import IMAGES from '@salesforce/resourceUrl/Images'

export default class SkillCards extends LightningElement {
    appBuilderImageURL = IMAGES + '/PlatAppBuild_s.png';
    SFPlatDevIImageURL = IMAGES + '/SFPlatDevI_s.png';
    JSDevIImageURL = IMAGES + '/JSDevI_s.png';
    SFPlatDevIIImageURL = IMAGES + '/SFPlatDevII_s.png';
    SFAI_AssocImageURL = IMAGES + '/SFAI_Assoc_s.png';
}