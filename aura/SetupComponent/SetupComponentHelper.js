({
    getSetupInformation : function(component) {
        var action = component.get("c.getSalesForceInformation");
        action.setCallback(this, function(response){
            if(component.isValid && response.getState() === "SUCCESS"){
                
                var obj = JSON.parse(response.getReturnValue());
                component.set("v.setupInfo.Username__c", obj[0].Username__c);
                component.set("v.setupInfo.Security_Token__c", obj[0].Security_Token__c);
                component.set("v.setupInfo.Password__c", obj[0].Password__c);
                component.set("v.setupInfo.Id", obj[0].Id);
                component.set("v.setupInfo.Password__c", obj[0].Password__c);
                
                component.set("v.vcsInfo.Id", obj[0].setup_vcs__r.records[0].Id);
                component.set("v.vcsInfo.Repository_Name__c", obj[0].setup_vcs__r.records[0].Repository_Name__c);
                component.set("v.vcsInfo.Password__c", obj[0].setup_vcs__r.records[0].Password__c);
                component.set("v.vcsInfo.remoteurl__c", obj[0].setup_vcs__r.records[0].remoteurl__c);
                component.set("v.vcsInfo.Repo_Username__c", obj[0].setup_vcs__r.records[0].Repo_Username__c);
                
                //alert("Repository_Name__c " + obj[0].setup_vcs__r.records[0].Repository_Name__c);
                
                //obj.employees[1].firstName
                
                //component.set("v.mapper", response.getReturnValue());
                //var myMap = cmp.get("v.mapper");
                //alert(myMap['Security_Token__c']);
                
                //console.log("mapper Username__c: " component.get("v.mapper")['id']);
                
                //alert("Response from APex " + response.getReturnValue());
                //component.set("v.setupInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})