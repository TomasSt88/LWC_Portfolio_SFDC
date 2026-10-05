import { createElement } from "lwc";
import CertificationTile from "c/certificationTile";

describe("c-certification-tile", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders nothing without a certification", () => {
    const element = createElement("c-certification-tile", {
      is: CertificationTile
    });
    document.body.appendChild(element);
    expect(element.shadowRoot.querySelector("lightning-card")).toBeNull();
  });

  it("renders name, status and image for a certification", () => {
    const element = createElement("c-certification-tile", {
      is: CertificationTile
    });
    element.certification = {
      Id: "a01",
      Name: "Platform Developer I",
      Certificates_reached__c: "Reached",
      "ContentVersion Id": "068XXX"
    };
    document.body.appendChild(element);
    const img = element.shadowRoot.querySelector("img");
    expect(img.src).toContain("/sfc/servlet.shepherd/version/download/068XXX");
    expect(
      element.shadowRoot.querySelector(".slds-text-heading_small").textContent
    ).toBe("Platform Developer I");
  });
});
