({
    doInit : function(component,event,helper){
        helper.branchSelectorPopulator(component);
        helper.getAllSprints(component);
    },
    
    branchChangeEvent : function(component,event,helper){
        var selectedBranch = component.find("sprintSelector").get("v.value");
    },
    
    sprintSelectorEvent : function(component,event,helper){
        
        var scmType = component.find("sprintSelector").get("v.value");
        switch(scmType){
            case "2016.09b-Sample Team": {
                component.set("v.userStories", [" "]);
                break;
            }
            case "2016.10bcde": {
                component.set("v.userStories", ["Version Control Enhancement"]);
                break;
            }
            case "2016.10abcd": {
                component.set("v.userStories", ["Deployment Enhancement", "Dataloader Enhancement"]);
                break;
            }
            case "2016.10def": {
                component.set("v.userStories", ["Support Ticket Enhancement"]);
                break;
            }
            default: {
                component.set("v.userStories", []);
            }
        }
        
        //var selectedSprint = component.find("sprintSelector").get("v.text");
        //alert(selectedSprint);
        //helper.getSprintUserStories(component, selectedSprint);
    },
     fetchChangesHandler:function(component,event,helper){
        var messages = ['Roger! Establishing connection','Retrival Request initiated','Fetch operation in progress','Please wait...']
        var i=0;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":"Notification",
            "message":messages[i],
            "mode":"pester",
            "type":"success"
        });
        i++;
        toastEvent.fire();
        var timer = setInterval(function(){
            if(i<messages.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":messages[i],
                    "mode":"pester",
                    "type":"success"
                });                
                toastEvent.fire();   
            }
            else{
                clearInterval(timer);
                helper.getUserChanges(component);
            }
            i++;
        },5200); 
    },
    
    commitFetcher : function(component, event, helper){
        var messages = ['Compiling selected Apex components','Running Test classes...','1/2 methods passed','2/2 methods passed','Gathering code coverage', 'Code Coverage is 90%', 'Starting Commit operation', 'Commit succesful please wait', 'Revision No.: f9fb186']
        var i=0;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":"Notification",
            "message":messages[i],
            "mode":"pester",
            "type":"success"
        });
        i++;
        toastEvent.fire();
        var timer = setInterval(function(){
            if(i<messages.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":messages[i],
                    "mode":"pester",
                    "type":"success"
                });                
                toastEvent.fire();   
            }
            else{
                clearInterval(timer);
                helper.upsertCommitHistory(component);
            }
            i++;
        },5200); 
    }
})