({
    doInit : function(component,event,helper){
        helper.branchSelectorPopulator(component);
        helper.getAllSprints(component);
    },
    
    branchChangeEvent : function(component,event,helper){
        var selectedBranch = component.find("branchSelector").get("v.value");
    },
    
    sprintSelectorEvent : function(component,event,helper){
        var selectedSprint = component.find("sprintSelector").get("v.id");
        helper.getSprintUserStories(component, selectedSprint);
    },
    
    fetchClickEvent:function(component,event,helper){
        var selectedBranch = component.find("branchSelector").get("v.value");
        if(selectedBranch == "Select branch"){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title":"Notification",
                "message":"Please select a branch"
            });
            toastEvent.fire();
        }else{
            helper.fetchUserChangesCaller(component);
        }
    }
})