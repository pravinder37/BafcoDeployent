public class BAFCORouteEquipmentTriggerController {
    public static final Id RMS_EXPORT_RECORDTYPE_Id = Schema.SObjectType.RMS__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id RMS_IMPORT_RECORDTYPE_Id = Schema.SObjectType.RMS__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    public static void insertRouteProcumnet(List<Route_Equipment__c> newList){
        Set<Id> routeIds = new Set<Id>();
        Set<Id> loadingPortIds = new Set<Id>();
        Set<Id> destinationPortIds = new Set<Id>();
        Set<Id> shippingLineIds = new Set<Id>();
        Set<Id> equipmentIds = new Set<Id>();
        List<Rate_Procurement__c> ratePocumentList = new List<Rate_Procurement__c>();
        for(Route_Equipment__c routequip: newList){
            if(routequip.Equipment_Type__c != null) {
                routeIds.add(routequip.Route__c);
                if(routequip.Equipment_Type__c != null ) equipmentIds.add(routequip.Equipment_Type__c);
            }
        }
        for(Route__c routeObj : [Select id, Port_of_Destination__c,Port_of_loading__c,Shipping_Line__c from Route__c where id in : routeIds]){
            if(routeObj.Port_of_loading__c != null ) loadingPortIds.add(routeObj.Port_of_loading__c);
            if(routeObj.Port_of_Destination__c != null ) destinationPortIds.add(routeObj.Port_of_Destination__c);
            if(routeObj.Shipping_Line__c != null ) shippingLineIds.add(routeObj.Shipping_Line__c);
        }
        for(Rms__c rmsobj : [Select Agent__c,id,RecordTypeId,Port_Of_Loading__c,Port_Of_Discharge__c,Shipping_Line__c,Equipment_Type__c from Rms__c 
                             where Port_Of_Loading__c in : loadingPortIds AND Port_Of_Discharge__c in :  destinationPortIds
                             AND Shipping_Line__c in : shippingLineIds and Equipment_Type__c in : equipmentIds
                            ]){
                                List<Rate_Procurement__c> procumentList  = new  List<Rate_Procurement__c>();
                                if(rmsObj.RecordTypeId == RMS_EXPORT_RECORDTYPE_Id){
                                    procumentList = [Select id from Rate_Procurement__c where 
                                                     Port_of_Loading__c =:rmsobj.Port_Of_Loading__c AND 
                                                     Port_of_Discharge__c =:rmsObj.Port_Of_Discharge__c AND 
                                                     Shipping_Line__c =: rmsObj.Shipping_Line__c AND 
                                                     Equipment_Type__c =: rmsObj.Equipment_Type__c limit 1];
                                }
                                else if(rmsObj.RecordTypeId == RMS_IMPORT_RECORDTYPE_Id){
                                    procumentList = [Select id from Rate_Procurement__c where 
                                                     Port_of_Loading__c =:rmsobj.Port_Of_Loading__c AND 
                                                     Port_of_Discharge__c =:rmsObj.Port_Of_Discharge__c AND 
                                                     Shipping_Line__c =: rmsObj.Shipping_Line__c AND 
                                                     Agent__c =:rmsObj.Agent__c AND 
                                                     Equipment_Type__c =: rmsObj.Equipment_Type__c limit 1];
                                }
                                if(procumentList.size() > 0){
                                    Id ReceivedRecordtypeId = Schema.SObjectType.Rate_Procurement__c.getRecordTypeInfosByName()
                                        .get('Received')
                                        .getRecordTypeId();
                                    Rate_Procurement__c proobj = procumentList[0];
                                    proobj.RMS__c = rmsObj.id;
                                    proobj.RecordTypeId = ReceivedRecordtypeId;
                                    ratePocumentList.add(proobj);
                                }
                            }
        if(ratePocumentList.size()>0) update ratePocumentList;
    }
}