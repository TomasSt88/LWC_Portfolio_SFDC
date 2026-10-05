import { LightningElement, api } from "lwc";

export default class CertificationTile extends LightningElement {
  @api certification;

  get imageUrl() {
    const versionId =
      this.certification && this.certification["ContentVersion Id"];
    return versionId
      ? "/sfc/servlet.shepherd/version/download/" + versionId
      : undefined;
  }
}
