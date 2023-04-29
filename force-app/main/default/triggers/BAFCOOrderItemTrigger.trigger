trigger BAFCOOrderItemTrigger on Order_Item__c (after insert,after update,after delete,before insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            BAFCOOrderItemTriggerHandler.onAfterInsert(trigger.new);
        }
        
         if(trigger.isUpdate){
             BAFCOOrderItemTriggerHandler.onAfterUpdate(trigger.oldMap,trigger.new);
         }
        if(trigger.isDelete){
        }
    }
    if(trigger.isBefore){
        if(trigger.isInsert){
            BAFCOOrderItemTriggerHandler.onBeforeInsert(trigger.new);
        }
    }
}