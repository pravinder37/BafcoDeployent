trigger QuotationItemTrigger on Quotation_Item__c (before Insert,before Update,after Insert,after update) {
    if(trigger.isUpdate && trigger.isBefore){
        QuotationItemTriggerHandler.updateChargesIncluded(trigger.new);
    }
    if(trigger.isInsert && trigger.isBefore){
        QuotationItemTriggerHandler.updateChargesIncluded(trigger.new);
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            QuotationItemTriggerHandler.updateQuotationDetails(trigger.new);
        }
        if(trigger.isUpdate){
            QuotationItemTriggerHandler.afterUpdate(trigger.oldMap,trigger.new);
        }
    }
}