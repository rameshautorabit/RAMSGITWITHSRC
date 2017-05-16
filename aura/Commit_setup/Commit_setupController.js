({
	myAction : function(component, event, helper) {
		
	},
    validateHandler:function(component,event,helper){
        var messages = ['Thank you! Let me shake hands with them.','Coolbeans! I like them and they like you.']
        var i=0;
        var timer = setInterval(function(){
             
            if(i<messages.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":messages(i),
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