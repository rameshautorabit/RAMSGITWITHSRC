({
    doInit:function(comp,event,handler){
        var messages = ['Fetching','comparing','modifying','packing']
        var i=0;
        var timer = setInterval(function(){
            if(i<messages.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":"Notification",
                    "message":messages[i],
                    "mode":"pester",
                    "type":"success"
                });                
                toastEvent.fire();   
            }
            else{
                clearInterval(timer);
            }
            i++;
        },5200);
        
    },
    showToast:function(message){
        
        
    },
    onClick : function(component, event, helper) {
        var id = event.target.dataset.menuItemId;
        if (id) {
            component.getSuper().navigate(id);
        }
    },
    click : function(component, event, helper) {
        //component.find("divComp");
        $A.util.addClass(component.find("divComp"), 'slds-is-active');
    },
    clickBro : function(component, event, helper) {
        //var array = ["Saab", "Volvo", "BMW"];
        //component.set("v.hosts", array);
        var toast = $A.get("e.force:showToast");
        if (toast){
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": "Success!",
                "message": "The component loaded successfully."
            });
            toast.fire();
        } else {
            //your toast implementation for a standalone app here
        }
    },
   
})