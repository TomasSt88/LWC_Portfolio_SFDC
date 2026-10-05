import { createElement } from "lwc";
import AccountPopulateLookup from "c/accountPopulateLookup";

describe("c-account-populate-lookup", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders the edit form for the current record", () => {
    const element = createElement("c-account-populate-lookup", {
      is: AccountPopulateLookup
    });
    element.recordId = "00Q000000000001";
    document.body.appendChild(element);
    const form = element.shadowRoot.querySelector("lightning-record-edit-form");
    expect(form.recordId).toBe("00Q000000000001");
  });
});
