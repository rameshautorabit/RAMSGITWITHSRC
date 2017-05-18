trigger HelloWorldTriggerTest123 on Account (before insert) {

    for(Account a : Trigger.New) {

        a.Description = 'Account Description for this HelloWorldTriggerTest';

    }  

}