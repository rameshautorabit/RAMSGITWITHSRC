({
	 createInputText : function(cmp, textLabel) {
        var componentConfig = {
            "componentDef": "markup://ui:inputText",
            "attributes": {
                "values": { label:textLabel, size:10, default:"enter text" }
            }
        };

        $A.createComponent(
            this,
            function(newInputText){
                var divComponent = cmp.find("ElementHere");
                var divBody = divComponent.get("v.body");
                divBody.push(newInputText);
                divComponent.set("v.body", divBody);
            },
            componentConfig
        );
    }
})