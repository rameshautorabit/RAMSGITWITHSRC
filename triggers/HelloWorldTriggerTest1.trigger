trigger HelloWorldTriggerTest1 on Account (before insert) {

    for(Account t1 : Trigger.New) {

        t1.Description = 'Account Description for this HelloWorldTriggerTest1';

    }  

}