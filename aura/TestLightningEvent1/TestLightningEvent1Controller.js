({
    buttonClicker : function(component, event, helper) {
        alert("Button got clicked");
        
        var searchCompleteEvent = $A.getEvt(“c:TestLightningEvent”);
        
        searchCompleteEvent.setParams({
            contacts: "asas"
        }).fire();
        
    }
})