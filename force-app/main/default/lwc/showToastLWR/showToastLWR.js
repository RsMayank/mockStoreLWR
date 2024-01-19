import { LightningElement, api } from 'lwc';
import B2B_Close from '@salesforce/label/c.B2B_Close';

export default class ShowToastLWR extends LightningElement {

    type;
    message;
    showToastBar = false;
    autoCloseTime = 5000;

    labels = {
        B2B_Close
    };

    @api
    showToast(message, type) {
        this.type = type;
        this.message = message;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
    }

    get getIconName() {
        return 'utility:' + this.type;
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}