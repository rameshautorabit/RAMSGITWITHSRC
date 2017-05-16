({
    branchSelectorPopulator:function(cmp){
        this.actionGenerator(cmp,"c.getRepoDetails","v.repoDetails","Repository details loaded successfully","Failed to load Repository details");   
    },
    
    almSprintPopulator:function(cmp){
        this.actionGenerator(cmp,"c.getAlmDetails","v.sprints","ALM details loaded successfully","Failed to load ALM details");
    },
    
    getAllSprints : function(component){
        var action = component.get("c.getAlmDetails");
        action.setCallback(this, function(response){
            if(component.isValid && response.getState() === "SUCCESS"){
                component.set("v.sprints", response.getReturnValue());
                //alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getSprintUserStories : function(component, selectedSprint){
        var action = component.get("c.getSprintUserStories");
        action.setParams({
            "sprintId": selectedSprint;
        });
        action.setCallback(this, function(response){
            if(component.isValid && response.getState() === "SUCCESS"){
                component.set("v.sprints", response.getReturnValue());
                //alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
    
    fetchUserChangesCaller:function(cmp){
        
    },
    
    actionGenerator:function(cmp,apexCompName,attrName,successMsg,errorMsg){
        var action = cmp.get(apexCompName);
        action.setCallback(this,function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set(attrName, response.getReturnValue());
            }
            if(state=="SUCCESS"){
                toastEvent.setParams({
                    "title":"Success",
                    "message":successMsg
                });
                return response;
            }
            else if(state == "ERROR"){
                toastEvent.setParams({
                    "title":"Error",
                    "message":errorMsg
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
})