trigger BAFCORouteEquipmentTrigger on Route_Equipment__c (after insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            BAFCORouteEquipmentTriggerController.insertRouteProcumnet(trigger.new);
        }
    }
}