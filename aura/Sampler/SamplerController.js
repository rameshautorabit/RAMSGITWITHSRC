({
    some : function(component, event, helper){
        alert("asdkjyasd->" + component.find("asas").get("v.body") + " <-asdasd " + component.getGlobalId());
        /*var test = component.find("asas");
        test.set("v.body", "<h1>asdfsadf</h1>");*/
        
        helper.createInputText(component, "Testing 123");
        
        alert("null");
    },
    handlePress : function(cmp) {
        console.log("button pressed");
    }
})