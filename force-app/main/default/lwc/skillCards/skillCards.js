import { LightningElement } from 'lwc';
import IMAGES from '@salesforce/resourceUrl/Images'

export default class SkillCards extends LightningElement {
    configImageURL = IMAGES + '/config.png';
    backendImageURL = IMAGES + '/backend.png';
    frontendImageURL = IMAGES + '/frontend.png';
    dataImageURL = IMAGES + '/data.png';
    softwaregImageURL = IMAGES + '/software.png';
    softskillsImageURL = IMAGES + '/softskills.png';
}