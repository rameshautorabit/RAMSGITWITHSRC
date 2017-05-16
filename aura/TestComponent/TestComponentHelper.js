({
	callOut : function(component) {
		var action = component.get("c.sampleTestCallout");
        
        action.setCallback(this, function(response){
           
            if (component.isValid() && response.getState() == "SUCCESS") {
               
                alert("Response from java class: " + response.getState());
                alert("Return from Server" + response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})