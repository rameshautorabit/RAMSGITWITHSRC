({
    buttonClick : function(component, event, helper) {
        component.find("replacableDiv").set("v.body", []);

        if(event.getSource().get("v.label") == "Setup"){
            var destination ="markup://c:SetupComponent";
            $A.createComponent(
                destination,
                {
                    
                },
                function(newButton){
                    //Add the new button to the body array
                    if (component.isValid()) {
                        var body = component.find("replacableDiv").get("v.body");
                        body.push(newButton);
                        component.find("replacableDiv").set("v.body", body);
                    }
                }
            );
            
        }else if(event.getSource().get("v.label") == "Commit"){
            
            var destination ="markup://c:CommitComponent";
            $A.createComponent(
                destination,
                {
                    "SalesforceUsername": "prashanth.s@autorabit.com.lightning"
                },
                function(newButton){
                    //Add the new button to the body array
                    if (component.isValid()) {
                        var body = component.find("replacableDiv").get("v.body");
                        body.push(newButton);
                        component.find("replacableDiv").set("v.body", body);
                    }
                }
            );
            
        }else if(event.getSource().get("v.label") == "History"){
            
            var destination ="markup://c:CommitHistoryComponent";
            $A.createComponent(
                destination,
                {
                    "SalesforceUsername": "prashanth.s@autorabit.com.lightning"
                },
                function(newButton){
                    //Add the new button to the body array
                    if (component.isValid()) {
                        var body = component.find("replacableDiv").get("v.body");
                        body.push(newButton);
                        component.find("replacableDiv").set("v.body", body);
                    }
                }
            );            
            
        }
        
    }
    
})