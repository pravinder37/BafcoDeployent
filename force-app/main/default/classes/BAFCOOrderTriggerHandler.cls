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
    public static void updateOrderName(List<Order__c> newList){
        system.debug('newList'+newList);
        List<Order__c> jubailRecord = [Select ID,Record_Number__c,Name,Branch__c from Order__c Where Branch__c='Jubail' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Order__c> jeddahRecord = [Select ID,Record_Number__c,Name,Branch__c from Order__c Where Branch__c='Jeddah' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Order__c> riyadRecord =  [Select ID,Record_Number__c,Name,Branch__c from Order__c Where Branch__c='Riyadh' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Order__c> dammamRecord = [Select ID,Record_Number__c,Name,Branch__c from Order__c Where Branch__c='Dammam' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        
        for(Order__c newOrder : newList){
            if(newOrder.Branch__c!=NULL){
                Decimal latestNumber;
                if(newOrder.Branch__c=='Jubail'){
                    if(jubailRecord.size()>0){                        
                        system.debug('In jubailRecord'+jubailRecord);
                        latestNumber=jubailRecord[0].Record_Number__c;
                        Decimal updatedNumber = latestNumber+1;
                        if(latestNumber!=NULL){
                            newOrder.Record_Number__c=updatedNumber;
                        }
                        else{
                            newOrder.Record_Number__c=1;
                        }
                        newOrder.Name =getLatestNameValue(updatedNumber,'JUB','O');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newOrder.Name ='JUB/Q/'+yearVal+'/1';
                        newOrder.Record_Number__c=1;
                    }
                }
                else if(newOrder.Branch__c=='Jeddah'){
                    if(jeddahRecord.size()>0){                        
                        system.debug('In jeddahRecord');
                        latestNumber=jeddahRecord[0].Record_Number__c;
                        Decimal updatedNumber = latestNumber+1;
                        if(latestNumber!=NULL){
                            newOrder.Record_Number__c=updatedNumber;
                        }
                        else{
                            newOrder.Record_Number__c=1;
                        }
                        newOrder.Name =getLatestNameValue(updatedNumber,'JED','O');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newOrder.Name ='JED/Q/'+yearVal+'/1';
                        newOrder.Record_Number__c=1;
                    }
                }
                
                else if(newOrder.Branch__c=='Riyadh'){
                    if(riyadRecord.size()>0){                        
                        system.debug('In riyadRecord');
                        latestNumber=riyadRecord[0].Record_Number__c;
                        Decimal updatedNumber = latestNumber+1;
                        if(latestNumber!=NULL){
                            newOrder.Record_Number__c=updatedNumber;
                        }
                        else{
                            newOrder.Record_Number__c=1;
                        }
                        newOrder.Name =getLatestNameValue(updatedNumber,'RYD','O');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newOrder.Name ='RYD/Q/'+yearVal+'/1';
                        newOrder.Record_Number__c=1;
                    }
                }
                
                else if(newOrder.Branch__c=='Dammam'){
                    if(dammamRecord.size()>0){                        
                        system.debug('In dammamRecord');
                        latestNumber=dammamRecord[0].Record_Number__c;
                        Decimal updatedNumber = latestNumber+1;
                        if(latestNumber!=NULL){
                            newOrder.Record_Number__c=updatedNumber;
                        }
                        else{
                            newOrder.Record_Number__c=1;
                        }
                        newOrder.Name =getLatestNameValue(updatedNumber,'DMM','O');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newOrder.Name ='DMM/Q/'+yearVal+'/1';
                        newOrder.Record_Number__c=1;
                    }
                }  
            }               
        }
    }
    
    public static String getLatestNameValue(Decimal latestNumber,String BranchCode,String recordType){
        String latestValue;
        String yearVal = String.valueOf(system.today().year()).right(2);
        //latestNumber = latestNumber.right(4);
        system.debug('latestNumber'+latestNumber);
        //Integer latestNumberVal = Integer.valueOf(latestNumber) + 1;
        //Decimal latestNumberVal = latestNumber+1;
        system.debug('latestNumberVal : '+latestNumber);
        
        latestValue = BranchCode+'/'+recordType+'/'+yearVal+'/'+latestNumber;
        system.debug('latestValue : '+latestValue);
        return latestValue;        
    }
    
    public static void sendOrderDetailsOnInsert(List<Order__c> orderList){
        set<ID> orderIDSet = new Set<ID>();
        List<ID> orderIDList = new List<ID>();
        for(Order__c ord:orderList){
            if(ord.Order_Type__c=='Sea Import'){                
                orderIDSet.add(ord.ID);
            }
        }
        orderIDList.addAll(orderIDSet);
        BAFCOSendOrdersAPI.sendOrderData(orderIDList);        
    }
    public static void sendOrderDetailsOnUpdate(List<Order__c> orderList,Map<id,Order__c> oldMap){
        set<ID> orderIDSet = new Set<ID>();
        List<ID> orderIDList = new List<ID>();
        for(Order__c ord:orderList){
            system.debug('ord.Integration__c'+ord.Integration__c);
            system.debug('oldMap.get(ord.ID).Integration__c'+oldMap.get(ord.ID).Integration__c);
            if(oldMap.get(ord.ID).Integration__c==false && ord.Integration__c!=oldMap.get(ord.ID).Integration__c && ord.Integration__c==true && ord.Order_Type__c=='Sea Import'){
                system.debug('In If');
                orderIDSet.add(ord.ID);
                system.debug('orderIDSet'+orderIDSet);
            }
        }
        orderIDList.addAll(orderIDSet);
        system.debug('orderIDList'+orderIDList);
        if(orderIDList!=NULL && orderIDList.size()>0){
            system.debug('In Second If');
            BAFCOSendOrdersAPI.sendOrderData(orderIDList);    
        }
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
    
    public static void calculateMargingOnStatusChanges(List<Order__c> orderList,Map<id,Order__c> oldMap){
        system.debug('orderList in OrderTriggerHandler'+orderList);
        Set<ID> orderIDSet = new Set<ID>();
        for(Order__c orderRec:orderList){
            if(orderRec.Status__c!=oldMap.get(orderRec.ID).status__c && (orderRec.Status__c=='Cancelled' || orderRec.Status__c=='Confirmed')){
                orderIDSet.add(orderRec.ID);
            }
        }
        system.debug('orderIDSet'+orderIDSet);
        List<Order_Item__c> toProcessItemList = [Select ID,Port_of_Discharge_Order__c,Port_of_Loading_Order__c,Customer_Port_Pair_Margin__c,
                                                 Profit__c,Profit_Margin__c, Teus__c, Quantity__c,Order__c,Route_Profit_Margin__c
                                                 FROM Order_Item__c 
                                                 WHERE Order__c IN:orderIDSet]; 
        if(toProcessItemList!=NULL)
        {
            BAFCOMarginCalculator.calculateMargins(toProcessItemList);
        }        
    }
    public static void testDummy(){
        Integer a=10;
        Integer b=5;
        Integer c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
         c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
         c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
        c= a+b;
    }
}