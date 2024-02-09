import { LightningElement } from 'lwc';
import ICONS from '@salesforce/resourceUrl/Icons';

export default class AboutMe extends LightningElement {

    linkedinImageURL = ICONS + '/svg/linkedin.svg';
    gmailImageURL = ICONS + '/svg/gmail.svg';
    trailheadImageURL = ICONS + '/svg//trailhead.svg';
    githubImageURL = ICONS + '/svg/github.svg';
}