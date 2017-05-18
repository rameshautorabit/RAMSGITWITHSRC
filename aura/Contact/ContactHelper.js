({
	getContacts : function(cmp) {
		var action = cmp.get("c.getContacts");
        action.setCallback(this,function(response){
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
             if (cmp.isValid() && state === "SUCCESS") {
	                cmp.set("v.contacts", response.getReturnValue());
	         }
            if(state=="SUCCESS"){
                toastEvent.setParams({
                    "title":"Success",
                    "message":"Contacts loaded successfully"
                });
                return response;
            }
            else if(state == "ERROR"){
                toastEvent.setParams({
                    "title":"Error",
                    "message":"Something went wrong while loading the contacts"
                });
            }
            toastEvent.fire();
            
        });
        $A.enqueueAction(action);
	}
})