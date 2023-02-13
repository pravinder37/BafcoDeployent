public class BAFCOOrderTriggerHandler {
    public static void beforeAction(List<Order__c> orderList){
        system.debug('orderList'+orderList);
        set<Id> orderIDSet = new set<Id>();
        set<Id> opportunityIDSet = new set<Id>();
        Map<ID,String> oppOwnerMap = new Map<ID,String>();
        Map<Id,Id> targetOwnerMap = new Map<Id,Id>();
        for(Order__c ordRec:orderList){
            opportunityIDSet.add(ordRec.Opportunity_Order__c);
        }
        system.debug('opportunityIDSet'+opportunityIDSet);
        for(Opportunity oppOwners : [Select Id,OwnerID FROM Opportunity where ID IN : opportunityIDSet]){
            oppOwnerMap.put(oppOwners.ID,oppOwners.OwnerID);
        }
        system.debug('oppOwnerMap'+oppOwnerMap);
        Date dt = System.today();
        Integer currentMonth = dt.Month();
        Integer currentYear = dt.Year();
        
        for(Target__c targetRec : [Select ID,Target_Value_In_Teus__c,Achieved_Value_In_Teus__c,Target_Month__c,OwnerId,Year_Value__c,Month_Value__c FROM Target__c 
                                   Where OwnerId IN:oppOwnerMap.values()
                                   AND Month_Value__c=:currentMonth AND Year_Value__c=:currentYear]){
                                       targetOwnerMap.put(targetRec.OwnerId,targetRec.Id);  
                                   }
        system.debug('targetOwnerMap'+targetOwnerMap);
        for(Order__c ordRec:orderList){
            ordRec.Target__c = targetOwnerMap.get(oppOwnerMap.get(ordRec.Opportunity_Order__c));  
        }
        system.debug('orderList'+orderList);
        
    }
    public static void afterAction(List<Order__c> orderList){
        set<ID> orderIDSet = new Set<ID>();
        List<ID> orderIDList = new List<ID>();
        for(Order__c ord:orderList){
            orderIDSet.add(ord.ID);
        }
        orderIDList.addAll(orderIDSet);
        BAFCOSendOrdersAPI.sendOrderData(orderIDList);        
    }
    
    public static void updateTargetData(List<Order__c> orderList){
        Set<ID> orderIDSet = new Set<ID>();
        Set<ID> targetIdSet = new Set<ID>();
        Map<ID,Decimal> targetValueMap = new Map<ID, Decimal>();
        List<Target__c> targetsListToUpdate = new List<Target__c>();
        for(Order__c ord:orderList){
            orderIDSet.add(ord.ID);
            targetIdSet.add(ord.Target__c);
        }
        AggregateResult[] groupedResult = [Select Target__c, Sum(Total_Teus__c) FROM Order__c 
                                           WHERE Target__c!=NULL AND Target__c IN: targetIdSet AND Status__c!='Cancelled' 
                                           Group by Target__c];
        for(AggregateResult ar:groupedResult){
            targetValueMap.put((Id)ar.get('Target__c'),(decimal)ar.get('expr0'));
        }
        system.debug('targetValueMap'+targetValueMap);
        for(Target__c trg:[Select ID,Target_Value_In_Teus__c,Achieved_Value_In_Teus__c,Target_Month__c,OwnerId,Year_Value__c,Month_Value__c 
                           FROM Target__c 
                           Where Id IN:targetValueMap.Keyset()]){
                               if(targetValueMap.get(trg.Id)!=NULL){
                                   trg.Achieved_Value_In_Teus__c = targetValueMap.get(trg.Id);
                                   targetsListToUpdate.add(trg);
                               }
                           }
        if(targetsListToUpdate!=NULL){
            database.update(targetsListToUpdate);
        }
    }
}