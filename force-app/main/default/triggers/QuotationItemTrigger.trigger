trigger QuotationItemTrigger on Quotation_Item__c (before Insert,before Update) {
    if(trigger.isUpdate && trigger.isBefore){
        QuotationItemTriggerHandler.updateChargesIncluded(trigger.new);
    }
    if(trigger.isInsert && trigger.isBefore){
        QuotationItemTriggerHandler.updateChargesIncluded(trigger.new);
    }
}