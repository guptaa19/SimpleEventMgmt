import { LightningElement, track, wire } from 'lwc';
import getBannerImage from '@salesforce/apex/EventsController.getBannerImage';

export default class Hero extends LightningElement {

    @track
    resourceUrl;
    @track
    eventId;
    @track
    error;


    connectedCallback() {
        let urlString = new URL(window.location.href).searchParams;
        this.eventId = urlString.get('id'); 
    }

    @wire(getBannerImage, {eventId : '$eventId'})
    wiredImage({ error, data }) {
        if (data) {
            this.resourceUrl = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.resourceUrl = undefined;
        }
    }
    


}