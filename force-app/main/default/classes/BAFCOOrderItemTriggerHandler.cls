public class BAFCOOrderItemTriggerHandler {
    public static void addTargetValue(List<Order_Item__c> orderItemList){
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
                if(targetRec!=null && ordItem.Teus__c!=null && targetRec.Achieved_Value_In_Teus__c!=null){
                    targetRec.Achieved_Value_In_Teus__c  = targetRec.Achieved_Value_In_Teus__c + ordItem.Teus__c;
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
    }
    public static void onAfterInsert(List<Order_Item__c> orderItemList){
        createRegularRoute(orderItemList);
    }
    public static void createRegularRoute(List<Order_Item__c> orderItemList){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> polIds = new Set<Id>();
        Set<Id> podIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id,Id> orderIdToAccId = new Map<Id,Id>();
        Map<Id,List<Regular_Routing__c>> accIdToRegularRoute = new Map<Id,List<Regular_Routing__c>>();
        List<Regular_Routing__c> regList = new List<Regular_Routing__c>();
        for(Order_Item__c item : orderItemList){
            orderIds.add(item.Order__c);
        }
        for(Order__c orderObj : [Select id, Account_Order__c from order__c where id in : orderIds]){
            if(orderObj.Account_Order__c != null ) orderIdToAccId.put(orderObj.id,orderObj.Account_Order__c);
        }
        for(Order_Item__c item : orderItemList){
            if(item.Port_of_Loading_Order__c != null) polIds.add(item.Port_of_Loading_Order__c);
            if(item.Port_of_Discharge_Order__c != null) podIds.add(item.Port_of_Discharge_Order__c); 
            if(item.Order__c != null && orderIdToAccId.containsKey(item.Order__c)) accIds.add(orderIdToAccId.get(item.Order__c));
        }
        for(Regular_Routing__c regObj : [Select id,Account__c,Port_of_Loading__c,Port_of_Destination__c from Regular_Routing__c where Account__c in : accIds OR Port_of_Loading__c in : polIds OR Port_of_Destination__c in : podIds]){
            if(!accIdToRegularRoute.containsKey(regObj.Account__c)){
                accIdToRegularRoute.put(regObj.Account__c, new List<Regular_Routing__c>());
            }
            accIdToRegularRoute.get(regObj.Account__c).add(regObj);
        }
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
                if(similarFound == false) regList.add(createRegularRouteObj(item,orderIdToAccId));
            }
            else{
                regList.add(createRegularRouteObj(item,orderIdToAccId));
            }
        }
        if(regList.size() > 0) insert regList;
    }
    public static Regular_Routing__c createRegularRouteObj(Order_Item__c item,Map<Id,Id> orderIdToAccId){
        Regular_Routing__c newObj = new Regular_Routing__c();
        newObj.Account__c = orderIdToAccId.containsKey(item.Order__c) ? orderIdToAccId.get(item.Order__c) : null;
        newObj.Port_of_Destination__c = item.Port_of_Discharge_Order__c;
        newObj.Port_of_Loading__c = item.Port_of_Loading_Order__c;
        newObj.Shipping_Line__c = item.Shipping_Line__c;
        newObj.Pickup_Place__c = item.Pickup_Place__c;
        newObj.Place_of_Discharge__c = item.Place_of_Discharge__c;
        return newObj;
    }
}