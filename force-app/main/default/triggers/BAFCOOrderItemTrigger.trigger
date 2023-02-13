trigger BAFCOOrderItemTrigger on Order_Item__c (after insert,after update,after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate){
			//BAFCOOrderItemTriggerHandler.addTargetValue(trigger.new,trigger.oldMap);
            BAFCOOrderItemTriggerHandler.onAfterInsert(trigger.new);
        }
        if(trigger.isDelete){
			//BAFCOOrderItemTriggerHandler.removeTargetValue(trigger.old);
        }
    }
}