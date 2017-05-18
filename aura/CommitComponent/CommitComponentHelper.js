({
    branchSelectorPopulator:function(component){
        var action = component.get("c.getRepoDetails");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.repoDetails", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
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
    getUserChanges : function(component){
        var action = component.get("c.getUserChanges");
        action.setCallback(this, function(response){
            if(component.isValid && response.getState() === "SUCCESS"){
                component.set("v.userChangesList", response.getReturnValue());
                //alert(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    actionGenerator:function(cmp,apexCompName,attrName,successMsg,errorMsg){
        var action = cmp.get(apexCompName);
        action.setCallback(this,function(response){
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set(attrName, response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
    },
    
    upsertCommitHistory : function(cmp){
        var action = cmp.get("c.upsertCommitHistoryAp");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":"Move to Commit History",
                    "mode":"pester",
                    "type":"success"
                });                
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
        
    }
    
})