import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';

import getTopicInfo from "@salesforce/apex/ssc_FaqController.getTopic";
import label_views from '@salesforce/label/c.ssc_Faq_Views';

export default class Ssc_Faq_topic extends NavigationMixin(LightningElement) {
    @api topicId;
    topic;

    @wire(getTopicInfo, { topicId: "$topicId" })wiredTopicInfos({ error, data }) {
        console.log("topicId",this.topicId)
        if (data) {
            console.log("data",data)
            this.topic = data
        } else if (error) {
            console.log("error",error)
        }
    };

    viewTopic(event) {
        console.log('viewTopic',event.target.dataset.url);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view',
            },
        })
    }

    viewArticle(event) {
        console.log('viewArticle',event.target.dataset.url);
        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: event.target.dataset.url,
            },
        })
    }

    get views() {
        return label_views;
    }
}