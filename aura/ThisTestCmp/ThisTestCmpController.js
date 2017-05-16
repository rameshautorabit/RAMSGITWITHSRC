({
    gotoURL : function(component, event, helper) {
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
    emptyCon : function(component, event, helper) {
        
        component.find("sampath").set("v.body", []);
        alert("Empty");
    },
})