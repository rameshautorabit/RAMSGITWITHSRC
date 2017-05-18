({
	getCommitHistoryCallout : function(cmp) {
        //alert("helper");
		var action = cmp.get("c.getCommitHistory");
        action.setCallback(this,function(response){
            var state = response.getState();
            //var toastEvent = $A.get("e.force:showToast");
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.commiHistoryList", response.getReturnValue());
                //alert(cmp.get("v.commiHistoryList").length);
                if(cmp.get("v.commiHistoryList").length > 0){
                    cmp.set("v.isCommitHistoryAvailable", true);
                    //alert("asd");
                }
            }
            /*if(state == "ERROR"){
                toastEvent.setParams({
                    "title":"Error",
                    "message":"Something went wrong while loading the repo details"
                });
                toastEvent.fire();
            }*/
        });
        $A.enqueueAction(action);   
	}
})