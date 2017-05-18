trigger HelloWorldTriggerTestn2 on Account (before insert) {

    for(Account t2 : Trigger.New) {

        t2.Description = 'Account Description for this HelloWorldTriggerTest1';

    }  

}