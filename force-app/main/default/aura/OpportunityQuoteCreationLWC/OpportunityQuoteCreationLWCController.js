({
	init : function(component, event, helper) {
        let pageReference = component.get("v.pageReference");
        component.set("v.refRecordId", pageReference.state.c__refRecordId);
        if(pageReference.state.c__refBusinessType != undefined){
            component.set("v.refBusinessType", pageReference.state.c__refBusinessType);
        }
    },
    closeQuickActionModal : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
    }
})