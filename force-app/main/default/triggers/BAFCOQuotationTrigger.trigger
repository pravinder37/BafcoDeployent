trigger BAFCOQuotationTrigger on Quotation__c (after update) {
    if(trigger.isAfter){
        if(trigger.isupdate){
            BAFCOQuotationTriggerHandler.afterUpdate(trigger.new,Trigger.oldMap);
        }
    }
}