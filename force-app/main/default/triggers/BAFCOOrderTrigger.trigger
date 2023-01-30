trigger BAFCOOrderTrigger on Order__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            BAFCOOrderTriggerHandler.afterAction(trigger.new);
        }
    }
}