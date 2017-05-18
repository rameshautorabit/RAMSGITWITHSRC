({
	creater : function(cmp) {
		$A.createComponent(
            "ui:button",
            {
                "aura:Id": "findableAuraId",
                "label": "Press Me",
                "press": cmp.getReference("c.handlePress")
            },
            function(newButton){
                //Add the new button to the body array
                if (cmp.isValid()) {
                    alert("Samasas " + newButton);
                    //var testerbody = cmp.find("tester").get("v.body");
                    //alert("testerbody " + testerbody);
                    var body = cmp.get("v.body");
                    body.push("markup://c:Test2");
                    cmp.set("v.body", body);
                }
            }
        );
	}
})