({
    removeAllClasses : function(component) {
        var setupComponent = component.find("setupComponent");
        var commitComponent = component.find("commitComponent");
        var historyComponent = component.find("historyComponent");
        
        $A.util.removeClass(setupComponent, 'hideComponent');
        $A.util.removeClass(setupComponent, 'showComponent');
        
        $A.util.removeClass(commitComponent, 'hideComponent');
        $A.util.removeClass(commitComponent, 'showComponent');
        
        $A.util.removeClass(historyComponent, 'hideComponent');
        $A.util.removeClass(historyComponent, 'showComponent');
        
    },
    initialiseSetupComponent : function(){
        component.find("replacableDiv").set("v.body", []);
        var destination ="markup://c:CommitTestComponent";
        $A.createComponent(
            destination,
            {
                "SalesforceUsername": "findableAuraId"
            },
            function(newButton){
                //Add the new button to the body array
                if (component.isValid()) {
                    var body = component.find("sampath").get("v.body");
                    body.push(newButton);
                    component.find("sampath").set("v.body", body);
                }
            }
        );
        
    },
    initialiseCommitComponent : function(){
        component.find("replacableDiv").set("v.body", []);
        
        
    },
    initialiseCommitHistoryComponent : function(){
        component.find("replacableDiv").set("v.body", []);
        
        
    },
})