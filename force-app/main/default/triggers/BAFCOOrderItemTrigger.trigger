trigger BAFCOOrderItemTrigger on Order_Item__c (after insert,after update,after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            BAFCOOrderItemTriggerHandler.onAfterInsert(trigger.new);
        }
         if(trigger.isUpdate){
             BAFCOOrderItemTriggerHandler.onAfterUpdate(trigger.new);
         }
        if(trigger.isDelete){
        }
    }
}