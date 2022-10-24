import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import getDocs from "@salesforce/apex/ssc_FaqController.getRelatedDocs";
import getDoc from "@salesforce/apex/ssc_FaqController.getDocURL";
import getVotes from "@salesforce/apex/ssc_FaqController.getArticleVotes";
import getVote from "@salesforce/apex/ssc_FaqController.getUserVote";
import setVote from "@salesforce/apex/ssc_FaqController.setUserVote";

export default class Ssc_Faq_article extends NavigationMixin(LightningElement) {
    @api recordId;
    articleId;
    article;
    files;
    wiredVotesResult;
    votes;
    userVote;

    @wire(getRecord, { recordId: '$recordId', fields: ['Knowledge__kav.Title', 'Knowledge__kav.Details__c', 'Knowledge__kav.LastPublishedDate', 'Knowledge__kav.KnowledgeArticleId'] })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('error',error)
        } else if (data) {
            console.log('data',data)
            this.article = data.fields
            this.articleId = data.fields.KnowledgeArticleId.value;
        }
    }

    @wire(getDocs, { recordId: "$recordId" })
    wiredDocs({ error, data }) {
        if (data) {
            console.log("docs data",data)
            this.files = data;
        } else if (error) {
            console.log("docs error",error)
        }
    };

    @wire(getVotes, { articleId: "$articleId" })
    wiredVotes(wiredVotesResult) {
        this.wiredVotesResult = wiredVotesResult
        const { data, error } = wiredVotesResult
        if (data) {
            console.log("votes data",data)
            this.votes = data
        } else if (error) {
            console.log("votes error",error)
        }
    };

    @wire(getVote, { articleId: "$articleId" })
    wiredUserVotes({ error, data }) {
        if (data) {
            console.log("user vote data",data)
            if(data.length > 0) this.userVote = data[0]
        } else if (error) {
            console.log("user vote error",error)
        }
    };

    async getFile(event) {
        console.log('file', event.target.dataset.id)
        let url = await getDoc({ docId: event.target.dataset.id })
        console.log('url',url)
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": url
            }
        });
    }

    async handleVote(event) {
        if(this.userVote && this.userVote.Type == event.target.dataset.direction) return;
        console.log('vote', event.target.dataset.direction)
        try {
            let vote = {'ParentId' : this.articleId, 'Type': event.target.dataset.direction, 'Id' : this.userVote?.Id}
            const voteResult = await setVote({ userVote: JSON.stringify(vote)})
            this.userVote = voteResult;
            refreshApex(this.wiredVotesResult);
        } catch(e) {
            console.log('vote error', e)
        }
        
    }

    get filespresent() {
        return this.files && this.files.length > 0
    }

    get fileslabel() {
        return 'Files ('+this.files.length+')'
    }

    get upVoteVariant() {
        return this.userVote && this.userVote.Type == 'Up' ? "brand" : "neutral"
    }

    get downVoteVariant() {
        return this.userVote && this.userVote.Type == 'Down' ? "brand" : "neutral"
    }
}