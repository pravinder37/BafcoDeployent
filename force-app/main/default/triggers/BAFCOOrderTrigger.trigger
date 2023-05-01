trigger BAFCOOrderTrigger on Order__c (before Insert,after insert, after update,after delete) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            BAFCOOrderTriggerHandler.beforeAction(trigger.new);
            //BAFCOOrderTriggerHandler.updateOrderName(trigger.new);
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
            BAFCOOrderTriggerHandler.afterAction(trigger.new);
            BAFCOOrderTriggerHandler.updateTargetData(trigger.new);
        }
        if(trigger.isDelete){
        }
    }
}