import { LightningElement } from 'lwc';
import cartMsgChannel from '@salesforce/messageChannel/B2BCart__c';
import {subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import  B2B_Cart_Locked_Message from '@salesforce/label/c.B2B_Cart_Locked_Message';
import  B2B_Cart_Warning_Message from '@salesforce/label/c.B2B_Cart_Warning_Message';

export default class B2bCartBanner extends LightningElement {
    labels = {
        B2B_Cart_Locked_Message,
        B2B_Cart_Warning_Message
    }

    disableCartAction;
    syncMsg;
    subscription = null;
    context = createMessageContext();

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.context,
            cartMsgChannel,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if(message.isCartAvailable) {
            if(!message.isCartActive) {
                this.disableCartAction = true;
            } else {
                this.disableCartAction = false;
            }

            if(message.isSynced) {
                this.syncMsg = false;
            } else {
                this.syncMsg = true;
            }
            
        } else {
            this.disableCartAction = false;
            this.syncMsg = false;
        }
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
        releaseMessageContext(this.context);
    }
}