({
    doInit : function(component, event, helper) {
        helper.getSetupInformation(component);
    },
    
    checker : function(component, event, helper) {
        alert("alert from setup component");
    },
    
    scmTypeChangeEvent : function(component, event, helper) {
        var scmType = component.find("scmTypeSelector").get("v.value");
        switch(scmType){
            case "GIT": {
                component.set("v.hosts", ["Bitbucket", "GitHub", "GitLab", "OnPrem", "AWS CodeCommit"]);
                break;
            }
            case "SVN": {
                component.set("v.hosts", ["SVN Repo1"]);
                break;
            }
            default: {
                component.set("v.hosts", []);
            }
        }
    },
     validateHandler:function(component,event,helper){
        var messages = ['Thank you! Let me shake hands with them. Please wait','Coolbeans! I like them and Bitbucket like you.']
        var i=0;
         var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
             "title":"Notification",
             "message":messages[0],
             "type":"success"
         });                
         toastEvent.fire();
         i++;
        var timer = setInterval(function(){
             
            if(i<messages.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":messages[i],
                    "type":"success"
                });                
                toastEvent.fire(); 
            }
            else{
                clearInterval(timer);
            }
            i++;
        },5200);
        
    }
})