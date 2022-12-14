({
	openVFPage : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let selected = component.get("v.value");
         console.log(JSON.stringify(selected));
        let showCharges = false;
        let showShippLine = false;
       	if(selected.includes('showShippLine')) showShippLine = true;
        if(selected.includes('showCharges')) showCharges = true;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/apex/BAFCOGeneratePdf?showShippLine="+showShippLine+'&showCharges='+showCharges+'&recordId='+recordId
        });
        urlEvent.fire(); 
	}
})