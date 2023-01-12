({
	navigateToLC : function(cmp, event, helper) {
        var action = cmp.get("c.getOptyBusinessType");
        action.setParams({ optyId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                let businessType = response.getReturnValue();
                var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__OpportunityQuoteCreationLWC' 
            },
            state: {
                c__refRecordId: cmp.get("v.recordId"),
                c__refBusinessType: businessType
            }
        };
        cmp.set("v.pageReference", pageReference);
        const navService = cmp.find('navService');
        const pageRef = cmp.get('v.pageReference');
        const handleUrl = (url) => {
            window.open(url,'_self');
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageRef).then(handleUrl, handleError);
            $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})