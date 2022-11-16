({
	navigateToLC : function(cmp, event, helper) {
		var action = cmp.get("c.getquoteDetails");
        action.setParams({ quoteId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var quoteObj = response.getReturnValue();
                console.log('quoteObj '+JSON.stringify(quoteObj))
                var leadId = quoteObj.leadId;
                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__ImportReviseQuoteTab' 
                    },
                    state: {
                        c__refRecordId: cmp.get("v.recordId"),
                        c__leadId: leadId
                    }
                };
                cmp.set("v.pageReference", pageReference);
                const navService = cmp.find('navService');
                const pageRef = cmp.get('v.pageReference');
                const handleUrl = (url) => {
                    window.open(url);
                };
                const handleError = (error) => {
                    console.log('error '+error);
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