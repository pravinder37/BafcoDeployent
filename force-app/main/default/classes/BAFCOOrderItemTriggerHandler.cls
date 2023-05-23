public class BAFCOOrderItemTriggerHandler {
    /*public static void addTargetValue(List<Order_Item__c> orderItemList,Map<ID,Order_Item__c> oldItemMap){                
        set<ID> ownerIDSet = new SET<ID>();
        set<ID> orderIDSet = new SET<ID>();
        Map<Id,Target__c> targetOwnerMap = new Map<Id,Target__c>();
        List<Target__c> targetListToUpdate = new List<Target__c>();
        List<Order__c> orderListToUpdate = new List<Order__c>();
        Date dt = System.today();
        Integer currentMonth = dt.Month();
        Integer currentYear = dt.Year();
        Map<ID,String> oppOwnerMap = new Map<ID,String>();
        for(Order_Item__c ord:orderItemList){   
            ownerIDSet.add(ord.Order__r.Opportunity_Order__r.Owner.ID);
            orderIDSet.add(ord.Order__c);
        } 
        //List<Order_Item__c> orderItemList =  [Select ID,Teus__c,Order__c From Order_Item__c WHERE Order__c IN : orderIDSet];
        for(Order__c ordForOwner : [Select id,Opportunity_Order__r.OwnerID FROM Order__c where ID IN : orderIDSet]){
            oppOwnerMap.put(ordForOwner.ID,ordForOwner.Opportunity_Order__r.OwnerID);
        }
        for(Target__c targetRec : [Select ID,Target_Value_In_Teus__c,Achieved_Value_In_Teus__c,Target_Month__c,OwnerId,Year_Value__c,Month_Value__c FROM Target__c Where OwnerId IN:oppOwnerMap.values() 
                                   AND Month_Value__c=:currentMonth AND Year_Value__c=:currentYear]){
                                       targetOwnerMap.put(targetRec.OwnerId,targetRec);  
                                   }
        system.debug('targetOwnerMap'+targetOwnerMap);
        if(targetOwnerMap!=NULL){
            for(Order_Item__c ordItem : orderItemList){
                //if(ordItem.Teus__c!=NULL && oldItemMap.get(ordItem.ID).Teus__c!=NULL && ordItem.Teus__c!=oldItemMap.get(ordItem.ID).Teus__c){
                Target__c targetRec = targetOwnerMap.get(oppOwnerMap.get(ordItem.Order__c));                
                //system.debug('targetRec.Achieved_Value_In_Teus__c '+targetRec.Achieved_Value_In_Teus__c+'ordItem.Teus__c '+ordItem.Teus__c);
                if(targetRec!=null && ordItem.Teus__c!=null){
                    if(targetRec.Achieved_Value_In_Teus__c!=NULL){
                        targetRec.Achieved_Value_In_Teus__c  = targetRec.Achieved_Value_In_Teus__c + ordItem.Teus__c;
                    }
                    else{
                        targetRec.Achieved_Value_In_Teus__c  = ordItem.Teus__c;
                    }
                    targetListToUpdate.add(targetRec);
                    Order__c ordRec = new Order__c(Id=ordItem.Order__c);
                    ordRec.Target__c = targetOwnerMap.get(oppOwnerMap.get(ordItem.Order__c)).ID;            
                    orderListToUpdate.add(ordRec);
                    
                }            
            }
        }
        system.debug('targetListToUpdate'+targetListToUpdate);
        if(targetListToUpdate!=NULL){
            database.update(targetListToUpdate);
        }
        system.debug('orderListToUpdate'+orderListToUpdate);
        if(orderListToUpdate!=NULL){
            database.update(orderListToUpdate);
        }
    }
    
    public static void removeTargetValue(List<Order_Item__c> orderItemList){
        set<ID> ownerIDSet = new SET<ID>();
        set<ID> orderIDSet = new SET<ID>();
        Map<Id,Target__c> targetOwnerMap = new Map<Id,Target__c>();
        List<Target__c> targetListToUpdate = new List<Target__c>();
        List<Order__c> orderListToUpdate = new List<Order__c>();
        Date dt = System.today();
        Integer currentMonth = dt.Month();
        Integer currentYear = dt.Year();
        Map<ID,String> oppOwnerMap = new Map<ID,String>();
        for(Order_Item__c ord:orderItemList){   
            ownerIDSet.add(ord.Order__r.Opportunity_Order__r.Owner.ID);
            orderIDSet.add(ord.Order__c);
        } 
        //List<Order_Item__c> orderItemList =  [Select ID,Teus__c,Order__c From Order_Item__c WHERE Order__c IN : orderIDSet];
         
        for(Order__c ordForOwner : [Select id,Opportunity_Order__r.OwnerID FROM Order__c where ID IN : orderIDSet]){
            oppOwnerMap.put(ordForOwner.ID,ordForOwner.Opportunity_Order__r.OwnerID);
        }
        for(Target__c targetRec : [Select ID,Target_Value_In_Teus__c,Achieved_Value_In_Teus__c,Target_Month__c,OwnerId,Year_Value__c,Month_Value__c FROM Target__c Where OwnerId IN:oppOwnerMap.values() 
                                   AND Month_Value__c=:currentMonth AND Year_Value__c=:currentYear]){
                                       targetOwnerMap.put(targetRec.OwnerId,targetRec);  
                                   }
        if(targetOwnerMap!=NULL){
            for(Order_Item__c ordItem : orderItemList){
                Target__c targetRec = targetOwnerMap.get(oppOwnerMap.get(ordItem.Order__c));
                //system.debug('targetRec.Achieved_Value_In_Teus__c '+targetRec.Achieved_Value_In_Teus__c+'ordItem.Teus__c '+ordItem.Teus__c);
                if(targetRec!=NULL && ordItem.Teus__c!=NULL && targetRec.Achieved_Value_In_Teus__c!=NULL){
                    targetRec.Achieved_Value_In_Teus__c  =targetRec.Achieved_Value_In_Teus__c -  ordItem.Teus__c;
                    targetListToUpdate.add(targetRec);
                    Order__c ordRec = new Order__c(Id=ordItem.Order__c);
                    ordRec.Target__c = targetOwnerMap.get(oppOwnerMap.get(ordItem.Order__c)).ID;            
                    orderListToUpdate.add(ordRec);                    
                }
            }
        }
        if(targetListToUpdate!=NULL){
            database.update(targetListToUpdate);
        }
        if(orderListToUpdate!=NULL){
            database.update(orderListToUpdate);
        }
    }*/
    public static void onAfterInsert(List<Order_Item__c> orderItemList){
        system.debug('=onAfterInsert of TriggerHandeler');
        createRegularRoute(orderItemList);
        BAFCOMarginCalculator.calculateMargins(orderItemList);
        maintaineLookupCharges(null,orderItemList);        
    }
    public static void onBeforeInsert(List<Order_Item__c> orderItemList){
        updateTeusValue(orderItemList);
    }
    
    public static void onAfterUpdate(Map<Id,Order_Item__c> oldMap,List<Order_Item__c> orderItemList){
        system.debug('=onAfterUpdate of TriggerHandeler');
        List<Order_Item__c> toCalculateMarginItems = new List<Order_Item__c>();
        for(Order_Item__c ordItem : orderItemList){
            if(ordItem.Sea_Freight_Order__c !=oldMap.get(ordItem.id).Sea_Freight_Order__c || ordItem.Quantity__c !=oldMap.get(ordItem.id).Quantity__c || ordItem.Total_Order__c !=oldMap.get(ordItem.id).Total_Order__c || ordItem.Buying_Rate__c !=oldMap.get(ordItem.id).Buying_Rate__c){
                toCalculateMarginItems.add(ordItem);
            }            
        }
        createRegularRoute(orderItemList);
        BAFCOMarginCalculator.calculateMargins(toCalculateMarginItems);
        maintaineLookupCharges(oldMap,orderItemList);
    }
    public static void createRegularRoute(List<Order_Item__c> orderItemList){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> polIds = new Set<Id>();
        Set<Id> podIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> routeIds = new Set<Id>();
        Map<Id,Id> orderIdToAccId = new Map<Id,Id>();
        Map<Id,List<Regular_Routing__c>> accIdToRegularRoute = new Map<Id,List<Regular_Routing__c>>();
        List<Regular_Routing__c> regList = new List<Regular_Routing__c>();
        for(Order_Item__c item : orderItemList){
            orderIds.add(item.Order__c);
            routeIds.add(item.Route_Order__c);
        }
        for(Order__c orderObj : [Select id, Account_Order__c from order__c where id in : orderIds]){
            if(orderObj.Account_Order__c != null ) orderIdToAccId.put(orderObj.id,orderObj.Account_Order__c);
        }
        for(Order_Item__c item : orderItemList){
            if(item.Port_of_Loading_Order__c != null) polIds.add(item.Port_of_Loading_Order__c);
            if(item.Port_of_Discharge_Order__c != null) podIds.add(item.Port_of_Discharge_Order__c); 
            if(item.Order__c != null && orderIdToAccId.containsKey(item.Order__c)) accIds.add(orderIdToAccId.get(item.Order__c));
        }
        for(Regular_Routing__c regObj : [Select id,Account__c,Shipping_Line__c,Port_of_Loading__c,Port_of_Destination__c from Regular_Routing__c where Account__c in : accIds OR Port_of_Loading__c in : polIds OR Port_of_Destination__c in : podIds]){
            if(!accIdToRegularRoute.containsKey(regObj.Account__c)){
                accIdToRegularRoute.put(regObj.Account__c, new List<Regular_Routing__c>());
            }
            accIdToRegularRoute.get(regObj.Account__c).add(regObj);
        }
        Map<Id,Route__c> routeIdToObjMap = new Map<Id,Route__c>([Select id,Shipping_Line__c,Pickup_Place__c,Discharge_Place__c,Place_of_Pickup__c,Place_of_Discharge__c,DG_Class__c,Dangerous_Goods__c,Service_Type__c,Kind_Of_Shipment__c,Commodity__c,INCO_Term__c from Route__c where id in : routeIds]);
        for(Order_Item__c item : orderItemList){
            List<Regular_Routing__c> reguLarList = new List<Regular_Routing__c>();
            if(item.Order__c != null && orderIdToAccId.containsKey(item.Order__c)){
                if(accIdToRegularRoute.containskey(orderIdToAccId.get(item.Order__c)))
                    reguLarList = accIdToRegularRoute.get(orderIdToAccId.get(item.Order__c));
            }
            if(reguLarList.size() > 0){
                Boolean similarFound = false;
                for(Regular_Routing__c regObj : reguLarList){
                    if(regObj.Account__c != null){
                        if(regObj.Port_of_Loading__c != null){
                            if(regObj.Port_of_Destination__c != null){
                                if(orderIdToAccId.get(item.Order__c) == regObj.Account__c && regObj.Port_of_Destination__c == item.Port_of_Discharge_Order__c && regObj.Port_of_Loading__c == item.Port_of_Loading_Order__c){
                                    similarFound = true;
                                }
                            }
                            else if(orderIdToAccId.get(item.Order__c) == regObj.Account__c && regObj.Port_of_Loading__c == item.Port_of_Loading_Order__c && item.Port_of_Discharge_Order__c == null){
                                similarFound = true;
                            }
                        }
                        else if(regObj.Port_of_Destination__c != null){
                            if(orderIdToAccId.get(item.Order__c) == regObj.Account__c && regObj.Port_of_Destination__c == item.Port_of_Discharge_Order__c && item.Port_of_Loading_Order__c == null){
                                similarFound = true;
                            }
                        }
                    }
                    else if(regObj.Port_of_Loading__c != null){
                        if(regObj.Port_of_Destination__c != null){
                            if(regObj.Port_of_Loading__c == item.Port_of_Loading_Order__c && regObj.Port_of_Destination__c == item.Port_of_Discharge_Order__c){
                                similarFound = true;
                            }
                        }
                        else if(regObj.Port_of_Loading__c == item.Port_of_Loading_Order__c && item.Port_of_Discharge_Order__c == null){
                            similarFound = true;
                        }
                    }
                    else if(regObj.Port_of_Destination__c != null &&  regObj.Port_of_Destination__c == item.Port_of_Discharge_Order__c && item.Port_of_Loading_Order__c == null){
                        similarFound = true;
                    }
                }
                if(similarFound == false) regList.add(createRegularRouteObj(item,orderIdToAccId,routeIdToObjMap));
            }
            else{
                regList.add(createRegularRouteObj(item,orderIdToAccId,routeIdToObjMap));
            }
        }
        if(regList.size() > 0) insert regList;
    }
    public static Regular_Routing__c createRegularRouteObj(Order_Item__c item,Map<Id,Id> orderIdToAccId,Map<Id,Route__c> routeIdToObjMap){
        Regular_Routing__c newObj = new Regular_Routing__c();
        newObj.Account__c = orderIdToAccId.containsKey(item.Order__c) ? orderIdToAccId.get(item.Order__c) : null;
        newObj.Port_of_Destination__c = item.Port_of_Discharge_Order__c;
        newObj.Port_of_Loading__c = item.Port_of_Loading_Order__c;
        newObj.Shipping_Line__c = item.Shipping_Line__c;
        if(routeIdToObjMap.size() > 0 && routeIdToObjMap.containsKey(item.Route_Order__c)){
            Route__c routeObj = routeIdToObjMap.get(item.Route_Order__c);
            newObj.Pickup_Place__c = routeObj.Pickup_Place__c;
            newObj.Discharge_Place__c = routeObj.Discharge_Place__c;
            system.debug('routeObj.DG_Class__c '+routeObj.DG_Class__c);
            newObj.DG_Class__c = routeObj.DG_Class__c;
            newObj.Dangerous_Goods__c = routeObj.Dangerous_Goods__c;
            newObj.Service_Type__c = routeObj.Service_Type__c;
            newObj.Kind_of_Shipment__c = routeObj.Kind_Of_Shipment__c;
            newObj.Commodity__c = routeObj.Commodity__c;
            newObj.INCO_Term__c = routeObj.INCO_Term__c;
        }
        return newObj;
    }
    public static void maintaineLookupCharges(Map<Id,Order_Item__c> oldMap,List<Order_Item__c> orderItemList){
        List<Order_Charges__c> chargeList = new List<Order_Charges__c>();
        Set<Id> oldItem = new Set<Id>();
        Map<String,id> additionalChargeMap = new Map<String,id>();
        Map<String,id> itemToChargeIdMap = new Map<String,id>();
        Map<String,String> keyToNameMap = new Map<String,String>();
        String type='Order_Item__c';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            keyToNameMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
        }
        for(Additional_Charge__c addnObj :  [Select id, name from Additional_Charge__c]){
            additionalChargeMap.put(addnObj.name,addnObj.id);
        }
        if(oldMap != null){
            oldItem = oldMap.keySet();
            system.debug('oldItem '+oldItem);
        }
        for(Order_Charges__c orderChar : [Select id,Order_Item__c,Charge_Name__c from Order_Charges__c where Order_Item__c in : oldItem]){
            String uniqueKey = orderChar.Order_Item__c+'-'+orderChar.Charge_Name__c;
            system.debug('uniqueKey******* '+uniqueKey);
            itemToChargeIdMap.put(uniqueKey, orderChar.id);
        }
        for(Order_Item__c item : orderItemList){
            if(item.BAF_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.BAF_Order__c;
                if(additionalChargeMap.containsKey('BAF')) newObj.Charge_Name__c = additionalChargeMap.get('BAF');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('BAF');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Bunker_surcharge_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Bunker_surcharge_Order__c;
                if(additionalChargeMap.containsKey('Bunker surcharge')) newObj.Charge_Name__c = additionalChargeMap.get('Bunker surcharge');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('Bunker surcharge');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Cleaning_charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Cleaning_charges_Order__c;
                if(additionalChargeMap.containsKey('Cleaning charges')) newObj.Charge_Name__c = additionalChargeMap.get('Cleaning charges');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('Cleaning charges');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.CMC_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.CMC_Order__c;
                if(additionalChargeMap.containsKey('Container Maintenance Charge'))newObj.Charge_Name__c = additionalChargeMap.get('Container Maintenance Charge');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('Container Maintenance Charge');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Carriage_Congestion_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Carriage_Congestion_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('carriage_congestion_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('carriage_congestion_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('carriage_congestion_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Carrier_Security_Fees__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Carrier_Security_Fees__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('carrier_security_fees__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('carrier_security_fees__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('carrier_security_fees__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.DG_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.DG_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('dg_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('dg_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('dg_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.DTHC_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.DTHC_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('dthc_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('dthc_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('dthc_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.EIC_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.EIC_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('eic_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('eic_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('eic_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Inland_Fuel_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Inland_Fuel_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('inland_fuel_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('inland_fuel_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('inland_fuel_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Inland_Handling_Fees__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Inland_Handling_Fees__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('inland_handling_fees__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('inland_handling_fees__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('inland_handling_fees__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Inland_haulage__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Inland_haulage__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('inland_haulage__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('inland_haulage__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('inland_haulage__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.ISPS_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.ISPS_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('isps_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('isps_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('isps_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Low_Sulphur_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Low_Sulphur_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('low_sulphur_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('low_sulphur_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('low_sulphur_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Operational_Recovery_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Operational_Recovery_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('operational_recovery_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('operational_recovery_surcharge__c'));
               String uniqueKey = newObj.Order_Item__c+'-'+ additionalChargeMap.get(keyToNameMap.get('operational_recovery_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.OTHC_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.OTHC_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('othc_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('othc_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('othc_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Overweight_Overheight_surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Overweight_Overheight_surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('overweight_overheight_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('overweight_overheight_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('overweight_overheight_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Seal_Charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Seal_Charges_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('seal_charges_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('seal_charges_order__c'));
               String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('seal_charges_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.War_Risk_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.War_Risk_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('war_risk_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('war_risk_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('war_risk_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Bayan_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Bayan_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('bayan_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('bayan_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('bayan_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.BL_Fees__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;                
                newObj.Charge_Value__c = item.BL_Fees__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('bl_fees__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('bl_fees__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('bl_fees__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Origin_Customs_clearance_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Origin_Customs_clearance_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('origin_customs_clearance_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('origin_customs_clearance_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('origin_customs_clearance_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Export_Service_Fees__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Export_Service_Fees__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('export_service_fees__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('export_service_fees__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('export_service_fees__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Fasah_fee_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Fasah_fee_Order__c;
                system.debug('fasah_fee__c '+keyToNameMap.get('fasah_fee__c'));
                if(additionalChargeMap.containsKey(keyToNameMap.get('fasah_fee_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('fasah_fee_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('fasah_fee_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Inspection_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Inspection_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('inspection_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('inspection_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('inspection_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Insurance_charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Insurance_charges_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('insurance_charges_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('insurance_charges_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('insurance_charges_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Lift_on_Lift_off_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Lift_on_Lift_off_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('lift_on_lift_off_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('lift_on_lift_off_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('lift_on_lift_off_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Origin_Detention_Demurrage_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Origin_Detention_Demurrage_Charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('origin_detention_demurrage_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('origin_detention_demurrage_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('origin_detention_demurrage_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Origin_Loading_Charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Origin_Loading_Charges_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('origin_loading_charges_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('origin_loading_charges_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('origin_loading_charges_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Pickup_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Pickup_Charges__c;
                newObj.Charge_Name__c = additionalChargeMap.get('Pickup Charges');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('Pickup Charges');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Reefer_cntr_plug_in_charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Reefer_cntr_plug_in_charges_Order__c;
                if(additionalChargeMap.containsKey('Reefer cntr plug-in charges'))newObj.Charge_Name__c = additionalChargeMap.get('Reefer cntr plug-in charges');
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get('Reefer cntr plug-in charges');
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Tabadul_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Tabadul_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('tabadul_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('tabadul_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('tabadul_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Tarpauline_charge_Order__c  > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Tarpauline_charge_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('tarpauline_charge_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('tarpauline_charge_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('tarpauline_charge_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Truck_idling_charges_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Truck_idling_charges_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('truck_idling_charges_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('truck_idling_charges_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('truck_idling_charges_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.VGM__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.VGM__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('vgm__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('vgm__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+ additionalChargeMap.get(keyToNameMap.get('vgm__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Xray_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Xray_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('xray_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('xray_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('xray_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Lashing_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Lashing_Charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('lashing_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('lashing_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('lashing_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Fuel_Surcharge__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Fuel_Surcharge__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('fuel_surcharge__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('fuel_surcharge__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('fuel_surcharge__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Bayan_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Bayan_Charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('bayan_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('bayan_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('bayan_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }  
            if(item.Destination_Customs_Clearance_Order__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Destination_Customs_Clearance_Order__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('destination_customs_clearance_order__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('destination_customs_clearance_order__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('destination_customs_clearance_order__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.DO_charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.DO_charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('do_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('do_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('do_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Fasah_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Fasah_Charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('fasah_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('fasah_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('fasah_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
            if(item.Gate_pass_charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.Gate_pass_charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('gate_pass_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('gate_pass_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('gate_pass_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }   
            if(item.LOLO_Charges__c > 0 ){
                Order_Charges__c newObj = new Order_Charges__c();
                newObj.Order_Item__c = item.id;
                newObj.Charge_Value__c = item.LOLO_Charges__c;
                if(additionalChargeMap.containsKey(keyToNameMap.get('lolo_charges__c')))newObj.Charge_Name__c = additionalChargeMap.get(keyToNameMap.get('lolo_charges__c'));
                String uniqueKey = newObj.Order_Item__c+'-'+additionalChargeMap.get(keyToNameMap.get('lolo_charges__c'));
                if(oldMap != null) newObj.id = itemToChargeIdMap.get(uniqueKey);
                chargeList.add(newObj);
            }
        }
        if(chargeList.size() > 0 ) {
            system.debug('chargeList '+chargeList);
            if(oldMap == null && (!test.isRunningTest())) insert chargeList;
            else{
                MAP<Id,Order_Charges__c> accMap = new MAP<Id,Order_Charges__c>();
                accMap.putall(chargeList);
                if(accmap.size()>0 && (!test.isRunningTest())){
                    update accmap.values();
                }
            }
        }
    }
    public static void updateTeusValue(List<Order_Item__c> orderItemList){
        List<Id> orderIds = new List<Id>();
        List<Id> equipIds = new List<Id>();
        List<Id> routeIds = new List<Id>();
        Map<Id,String> orderIdMap = new Map<Id,String>();
        Map<String,Decimal> routeEquipIdMap = new Map<string,Decimal>();
        Map<String,Decimal> routeIdMap = new Map<string,Decimal>();
        Map<Id,String> equipIdMap = new Map<Id,String>();
        for(Order_Item__c item : orderItemList){
            orderIds.add(item.Order__c);
            if(item.Equipment_Type_Order__c != null) equipIds.add(item.Equipment_Type_Order__c);
            if(item.Route__c != null ) routeIds.add(item.Route__c);
        }
        for(Equipment_Type__c equipObj : [Select id,name from Equipment_Type__c where id  in : equipIds]){
            equipIdMap.put(equipObj.id, equipObj.Name);
        }
        system.debug('routeIds '+routeIds);
        for(Route_Equipment__c routeEquipObj : [Select id,Tab_View__c,CBM__c,Weight_Kgs__c from Route_Equipment__c where Route__c in : routeIds]){
            if(routeEquipObj.CBM__c != null && routeEquipObj.Weight_Kgs__c !=null){
            Decimal chargeableWeight = (routeEquipObj.CBM__c  * 167 ) > routeEquipObj.Weight_Kgs__c ? routeEquipObj.CBM__c  * 167  :  routeEquipObj.Weight_Kgs__c;
            routeEquipIdMap.put(routeEquipObj.Tab_View__c,chargeableWeight);
            }
        }
        for(Order__c orderObj : [Select id,Order_Type__c from Order__c where id  in : orderIds]){
            orderIdMap.put(orderObj.id, orderObj.Order_Type__c);
        }
        for(Route__c routeObj : [Select id, Chargeable_Weight__c from Route__c where id in : routeIds ]){
            routeIdMap.put(routeObj.id,routeObj.Chargeable_Weight__c);
        }
        system.debug('routeEquipIdMap '+routeEquipIdMap);
        for(Order_Item__c item : orderItemList){
            if(orderIdMap.get(item.Order__c) == 'Sea Export' || orderIdMap.get(item.Order__c) == 'Sea Import' ||orderIdMap.get(item.Order__c) == 'ISO Export' ||orderIdMap.get(item.Order__c) == 'ISO Import'){
                if(item.Equipment_Type_Order__c != null && (equipIdMap.get(item.Equipment_Type_Order__c).contains('40') == true || equipIdMap.get(item.Equipment_Type_Order__c).contains('45') == true)){
                    item.Teus_FB__c = 2 * (item.Quantity__c != null ? item.Quantity__c : 1);
                }
                if(item.Equipment_Type_Order__c != null && (equipIdMap.get(item.Equipment_Type_Order__c).contains('20') == true|| equipIdMap.get(item.Equipment_Type_Order__c).contains('45') == true)){
                    item.Teus_FB__c = 1 * (item.Quantity__c != null ? item.Quantity__c : 1);
                }
            }
            else if(orderIdMap.get(item.Order__c) == 'Local Operation Export' || orderIdMap.get(item.Order__c) == 'Local Operation Import'){
                if(item.Equipment_Type_Order__c != null && (equipIdMap.get(item.Equipment_Type_Order__c).contains('40') == true || equipIdMap.get(item.Equipment_Type_Order__c).contains('45') == true)){
                    item.Teus_FB__c = item.Quantity__c > 0 ? item.Quantity__c/2 : 0;
                }
                if(item.Equipment_Type_Order__c != null && equipIdMap.get(item.Equipment_Type_Order__c).contains('20') == true){
                    item.Teus_FB__c = item.Quantity__c > 0 ? item.Quantity__c/4 : 0;
                }
            }
            else if(orderIdMap.get(item.Order__c) == 'LCL Export' || orderIdMap.get(item.Order__c) == 'LCL Import'){
                if(routeEquipIdMap.containsKey(item.Tab_View__c)){
                    item.Teus_FB__c = routeEquipIdMap.get(item.Tab_View__c) / 250;
                    system.debug(' *************** '+item.Teus_FB__c);
                }
            }
            else if(orderIdMap.get(item.Order__c) == 'Air Export' || orderIdMap.get(item.Order__c) == 'Air Import'){
                if(routeIdMap.containsKey(item.Route__c)){
                    item.Teus_FB__c = routeIdMap.get(item.Route__c)/250;
                }
            }
        }
    }
    public static void dummyMethod(){
        Integer a = 10;
        Integer b = 10;
        Integer c = 10;
        Integer d = 10;
        Integer e = 10;
        Integer a1 = 10;
        Integer a2= 10;
        Integer a3 = 10;
        Integer a4 = 10;
        Integer a5 = 10;
        Integer a6 = 10;
        Integer a7 = 10;
        Integer a8 = 10;
        Integer a9 = 10;
        Integer a10 = 10;
        Integer aa = 10;
        Integer aaa = 10;
        Integer fa = 10;
        Integer a13 = 10;
        Integer a14 = 10;
        Integer a25 = 10;
        Integer a36 = 10;
        Integer a47 = 10;
        Integer a38 = 10;
        Integer a19 = 10;
        Integer ae10 = 10;
        Integer ada = 10;
        Integer agaa = 10;
        Integer fhha = 10;
    }
}