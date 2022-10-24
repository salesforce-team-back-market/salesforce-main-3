import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getMessages from "@salesforce/apex/ssc_CaseController.getCaseMessages";
import saveComment from "@salesforce/apex/ssc_CaseController.addComment";
import saveFilesComment from "@salesforce/apex/ssc_CaseController.addFileComment";

import label_addComment from '@salesforce/label/c.ssc_CaseFeed_addComment';
import label_addFile from '@salesforce/label/c.ssc_CaseFeed_addFile';
import label_save from '@salesforce/label/c.ssc_CaseFeed_save';
import label_showMore from '@salesforce/label/c.ssc_CaseFeed_showMore';
import label_error from '@salesforce/label/c.ssc_CaseFeed_error';


export default class Ssc_CaseFeed extends LightningElement {
    @api recordId;
    displayedMessages = [];
    messages = [];
    hasMore = false;
    commentText;
    saveDisabled = false;

    _ = {
        label_addComment,
        label_addFile,
        label_save,
        label_showMore,
        label_error
    }


    connectedCallback() {
        this.getData()
    }

    async getData() {
        try {
            let data = await getMessages({ recordId: this.recordId })
            this.messages = data.map((m,i) => {
                m.createdDateTime = new Date(m.createdDateTime);
                m.isEmail = m.messageType == 'mail'
                return m;
            })

            if(this.messages.length > 6) {
                this.hasMore = true
                this.displayedMessages = this.messages.slice(0, 6);
            } else {
                this.displayedMessages = this.messages
            }
        } catch(e) {
            console.log('getData','error', e)
            this.showToastMessage(label_error, e, 'error')
        }
    }

    handleExpand(event) {
        this.messages = this.messages.map(m => {
            if(m.id == event.target.dataset.messageId) m.isExpanded = !m.isExpanded
            return m;
        })
    }

    handleShowMore() {
        this.displayedMessages = this.messages;
        this.hasMore = false;
    }

    async handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if(!uploadedFiles || uploadedFiles.length == 0) return;
        console.log('files: ',uploadedFiles.map(v => { return v.name}).join(', '));

        try {
            await saveFilesComment({ recordId: this.recordId, fileNames: uploadedFiles.map(v => { return v.name}).join(', ')})
            eval("$A.get('e.force:refreshView').fire();");
        } catch(e) {
            this.showToastMessage(label_error, e, 'error')
            console.log('handleNewComment','error', e)
        }
    }

    async handleNewComment() {
        const input = this.template.querySelector('lightning-textarea');
        if(!input.value) return;
        
        try {
            this.saveDisabled = true;
            await saveComment({ recordId: this.recordId, comment: input.value})
            this.getData()
            input.value = '';
            this.saveDisabled = false;
        } catch(e) {
            this.showToastMessage(label_error, e, 'error')
            console.log('handleNewComment','error', e)
        }

    }

    showToastMessage(title, message, variant, sticky){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: (sticky) ? 'sticky' : 'dismissible'
            })
        );
    }
}