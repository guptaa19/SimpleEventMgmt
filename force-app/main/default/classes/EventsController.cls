public with sharing class EventsController {

    @AuraEnabled(Cacheable=true)
    public static String getBannerImage(String eventId) {
        return [SELECT Id, Banner_Image__c FROM Event__c WHERE Id =: eventId].Banner_Image__c;
    }

    @AuraEnabled(Cacheable=true)
    public static List<TicketType> getTicketTypes(String eventId) {
        List<Ticket_Type__c> ticketTypes = [SELECT Id, Name, Description__c, Sale_Price__c, Quantity_Remaining__c FROM Ticket_Type__c WHERE Event__c = :eventId AND Is_Active__c = true];
        List<TicketType> wrappers = new List<TicketType>();
        for (Ticket_Type__c tt : ticketTypes) {
            TicketType wrapper = new TicketType();
            wrapper.name = tt.Name;
            wrapper.description = tt.Description__c;
            wrapper.salePrice = tt.Sale_Price__c;
            wrapper.quantity = tt.Quantity_Remaining__c;
            wrapper.id = tt.Id;
            wrapper.options = getOptions(Integer.valueOf(tt.Quantity_Remaining__c));
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    public static List<Option> getOptions(Integer quantity) {
        List<Option> options = new List<Option>();
        for (Integer i=1; i<=quantity; i++) {
            options.add(new Option(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    @AuraEnabled
    public static Boolean createAttendee(String attendeeDetails) {
        Boolean isSuccess = false;
        Attendee att = (Attendee) JSON.deserialize(attendeeDetails, Attendee.Class);
        Attendee__c attRecord = new Attendee__c();
        attRecord.Name = att.name;
        attRecord.Event__c = att.eventId;
        attRecord.Ticket_Type__c = att.ticketTypeId;
        attRecord.Email__c = att.email;
        attRecord.Number_of_Tickets__c = Integer.valueOf(att.numberOfTickets);
        Ticket_Type__c tt = [SELECT Id, Quantity_Sold__c FROM Ticket_Type__c WHERE Id=:att.ticketTypeId];
        if (tt.Quantity_Sold__c == null) {
            tt.Quantity_Sold__c = 0;
        }
        tt.Quantity_Sold__c += Integer.valueOf(att.numberOfTickets);
        try {
            Database.insert(attRecord);
            Database.upsert(tt);
            isSuccess = true;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return isSuccess;
    }

    public class TicketType {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Decimal salePrice;
        @AuraEnabled
        public Decimal quantity;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public List<Option> options;

    }

    public class Option {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public Option (String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class Attendee {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String eventId;
        @AuraEnabled
        public String ticketTypeId;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public Decimal numberOfTickets;
    }


}
