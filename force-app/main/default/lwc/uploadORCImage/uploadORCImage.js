import { LightningElement, api, wire } from "lwc";
import analyzeImage from "@salesforce/apex/GoogleWebService.analyzeImage";
import saveScannedDocument from "@salesforce/apex/GoogleWebService.saveScannedDocument";
import removeFileFromAccount from "@salesforce/apex/GoogleWebService.removeFileFromAccount";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class UploadORCImage extends LightningElement {
  @api recordId;
  imageUrl;
  extractedText;
  contentDocumentId;
  accountId;

  @wire(getRecord, { recordId: "$recordId", fields: ["Account.Id"] })
  wiredDocument({ error, data }) {
    if (data) {
      this.accountId = getFieldValue(data, "Account.Id");
    } else if (error) {
      this.showToast("Error", this.errorMessage(error), "error");
    }
  }

  handleAccountChange(event) {
    this.accountId = event.detail.value;
  }

  handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    if (!uploadedFiles || uploadedFiles.length === 0) {
      return;
    }
    this.contentDocumentId = uploadedFiles[0].documentId;
    this.imageUrl =
      "/sfc/servlet.shepherd/document/download/" + this.contentDocumentId;
  }

  async analyzeImage() {
    if (!this.contentDocumentId) {
      this.showToast("No file", "Please upload an image first.", "error");
      return;
    }
    try {
      const result = await analyzeImage({
        contentDocumentId: this.contentDocumentId
      });
      if (result) {
        this.extractedText = result;
        this.adjustTextareaHeight();
      } else {
        this.showToast(
          "No Text Found",
          "No text could be extracted from the image.",
          "info"
        );
      }
    } catch (error) {
      this.showToast("Error", this.errorMessage(error), "error");
    }
  }

  async saveDocument() {
    if (!this.accountId) {
      this.showToast("Error", "No Account selected.", "error");
      return;
    }
    if (!this.extractedText || !this.contentDocumentId) {
      this.showToast(
        "Error",
        "Extracted Text and attached Content Document fields can not be empty.",
        "error"
      );
      return;
    }
    try {
      // One server call creates the record, links and moves the file, and
      // removes the temporary Account link in a single transaction.
      await saveScannedDocument({
        accountId: this.accountId,
        extractedText: this.extractedText,
        contentDocumentId: this.contentDocumentId
      });
      this.showToast(
        "Success",
        "Extracted Text has been saved successfully.",
        "success"
      );
      this.resetState();
    } catch (error) {
      this.showToast("Error", this.errorMessage(error), "error");
    }
  }

  async clear() {
    const { accountId, contentDocumentId } = this;
    this.resetState();
    if (!accountId || !contentDocumentId) {
      return;
    }
    try {
      await removeFileFromAccount({ accountId, contentDocumentId });
      this.showToast(
        "Success",
        "File has been removed from the Account successfully.",
        "success"
      );
    } catch (error) {
      this.showToast("Error", this.errorMessage(error), "error");
    }
  }

  resetState() {
    this.imageUrl = "";
    this.extractedText = "";
    this.contentDocumentId = undefined;
    this.adjustTextareaHeight();
  }

  adjustTextareaHeight() {
    const textarea = this.template.querySelector("textarea");
    if (!textarea) {
      return;
    }
    const text = this.extractedText || "";
    const numberOfLines = Math.min(Math.floor(text.length / 10), 30);
    textarea.style.height = `${numberOfLines * 1.2}em`;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant,
        mode: variant === "error" ? "sticky" : "dismissable"
      })
    );
  }

  errorMessage(error) {
    if (error && error.body) {
      if (Array.isArray(error.body)) {
        return error.body.map((e) => e.message).join(", ");
      }
      if (error.body.message) {
        return error.body.message;
      }
    }
    return (error && error.message) || "Unknown error";
  }
}
