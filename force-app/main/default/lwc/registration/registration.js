import { LightningElement, track, wire } from 'lwc';
import getTicketTypes from '@salesforce/apex/EventsController.getTicketTypes';
import createAttendee from '@salesforce/apex/EventsController.createAttendee';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Registration extends LightningElement {

    @track
    eventId;
    @track
    ticketType;
    @track
    error;
    @track
    attendee = {};
    @track
    showModal;
    @track
    isLoading;

    connectedCallback() {
        let urlString = new URL(window.location.href).searchParams;
        this.eventId = urlString.get('id'); 
        this.attendee = {};
    }

    @wire(getTicketTypes, {eventId : '$eventId'})
    wiredTicketTypes({ error, data }) {
        if (data) {
            this.ticketType = data[0];
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.ticketType = undefined;
        }
    }

    handleClick() {
        if (!this.attendee.numberOfTickets || this.attendee.numberOfTickets < 1) {
            this.showNotification('Ticket Quantity', 'Please select a quantity', 'error');
            return;
        }
        this.showModal = true;
    }

    handleChange(event) {
        this.attendee[event.target.dataset.field] = (Array.isArray(event.detail.value)) ? event.detail.value[0] : event.detail.value;
    }
    hideModal() {
        this.showModal = false;
    }
    register() {
        this.isLoading = true;
        this.attendee.eventId = this.eventId;
        this.attendee.ticketTypeId = this.ticketType.id;
        createAttendee(
            {
                attendeeDetails : JSON.stringify(this.attendee)
            }
        ).then(result => {
            this.isLoading = false;
            this.hideModal();
            this.attendee = {};
            this.showNotification('Congratulations!', 'You are registered.', 'success');
        })
        .catch(error => {
            this.showNotification('Error while registration', error.message, 'error');
        })
    }

    showNotification( title,  message,  variant ) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}