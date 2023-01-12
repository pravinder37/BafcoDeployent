({
	openVFPage : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let selected = component.get("v.value");
         console.log(JSON.stringify(selected));
        let device = $A.get("$Browser.formFactor");
        component.set("v.device", device);
        let showCharges = false;
        let showShippLine = false;
       	if(selected.includes('showShippLine')) showShippLine = true;
        if(selected.includes('showCharges')) showCharges = true;
        let urlEvent = $A.get("e.force:navigateToURL");
        if(device == 'PHONE'){
            urlEvent.setParams({
            "url":"/apex/BAFCOQuotePDFMobile?showShippLine="+showShippLine+'&showCharges='+showCharges+'&recordId='+recordId+'&device='+device
        	});
        }
        else{
            urlEvent.setParams({
                "url":"/apex/BAFCOGeneratePdf?showShippLine="+showShippLine+'&showCharges='+showCharges+'&recordId='+recordId+'&device='+device
            });
        }
        urlEvent.fire(); 
	}
})