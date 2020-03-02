trigger EventTrigger on Event__c (before update) {
    String registrationURL = Network.getLoginUrl([SELECT Id from Network].Id).replace('/login', '/s/event?id=');
    for (Event__c event : Trigger.New) {
        if (event.Is_Active__c) {
            event.Registration_URL__c = registrationURL + event.Id;
        }
    }
}