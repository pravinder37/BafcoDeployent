public class BAFCOMarginCalculator {
    public static void calculateMargins(List<Order_Item__c> orderItemList){
        system.debug('=orderItemList '+orderItemList.size());
        for(Order_Item__c ordItem:orderItemList){
            calculateCustomerMargin(ordItem);
            calculateRouteMargin(ordItem);
            calculateRouteCustomerMargin(ordItem);
        }
    }    
    
    public static void calculateCustomerMargin(Order_Item__c ordItemValue){
        Decimal profitTeusSum=0;
        Decimal TeusSum=0;
        Set<ID> orderIDSet = new Set<ID>();
        Set<ID> customerIDSet = new Set<ID>();
        Map<ID,ID> customerItemMap = new Map<ID,ID>();
        Map<ID,Decimal> customerMarginMap = new Map<ID,Decimal>();
        
        String customerID = [SELECT id,Account_Order__r.id FROM Order__c WHERE id =:ordItemValue.Order__c Limit 1].Account_Order__r.id;
        
        Account customerRec = [Select id,Average_Margin__c from Account Where Id=:customerID];
        
        List<Order_Item__c> toProcessItemList = [Select ID,Order__r.Account_Order__c,Profit__c,Order__r.Account_Order__r.Average_Margin__c,BSLS_ID__c,Teus__c
                                                 FROM Order_Item__c 
                                                 WHERE Order__r.Account_Order__c =:customerID];
        
        system.debug('toProcessItemList'+toProcessItemList);
        system.debug('toProcessItemList Size'+toProcessItemList.size());
        Decimal finalMarginValue;
        for(Order_Item__c ordItem:toProcessItemList){            
            if(ordItem.Profit__c!=NULL && ordItem.Teus__c!=NULL){
                profitTeusSum=profitTeusSum+(ordItem.Profit__c*ordItem.Teus__c);
                TeusSum=TeusSum+ordItem.Teus__c;
            }
        }
        
        system.debug('==profitTeusSum '+profitTeusSum);
        system.debug('==TeusSum '+TeusSum);
        if(profitTeusSum!=0 || TeusSum!=0){
            Decimal averageMargin = profitTeusSum/TeusSum;
            system.debug('=averageMargin '+averageMargin);
            if(customerRec.Average_Margin__c == NULL){
                finalMarginValue = 0 + averageMargin;
            }
            else{
                if(customerRec.Average_Margin__c!=finalMarginValue){
                    finalMarginValue = averageMargin;
                }
            }
            system.debug('=finalMarginValue'+finalMarginValue);
            customerRec.Average_Margin__c = finalMarginValue;
            
            if(customerRec!=NULL){
                database.update(customerRec);
            }
        }    
    }
    
    public static void calculateRouteMargin(Order_Item__c ordItemValue){
        RecordType RouteMarginRecordType = [SELECT Id, SobjectType, DeveloperName, Name FROM RecordType Where SobjectType='Route_Profit_Margin__c' And DeveloperName = 'Port_Pair' Limit 1];
        Decimal profitTeusSum=0;
        Decimal TeusSum=0;
        Order_Item__c orderItemDetails = [SELECT id,Order__r.Account_Order__r.Name,Order__r.Account_Order__r.id,Port_of_Loading_Order__r.Name,Port_of_Discharge_Order__r.Name
                                          FROM Order_Item__c 
                                          WHERE id=:ordItemValue.ID];
        
        
        List<Route_Profit_Margin__c> routeMargingList = [Select id,Margin__c from Route_Profit_Margin__c Where Port_of_Loading__c=:ordItemValue.Port_of_Loading_Order__c AND Port_of_Discharge__c=:ordItemValue.Port_of_Discharge_Order__c Limit 1];
        Route_Profit_Margin__c routeRecordToUpdate;
        
        if(routeMargingList==NULL || routeMargingList.size()<1){
            Route_Profit_Margin__c newRouteRecord = new Route_Profit_Margin__c();
            newRouteRecord.Margin__c=0;
            newRouteRecord.Port_of_Loading__c=ordItemValue.Port_of_Loading_Order__c;
            newRouteRecord.Port_of_Discharge__c=ordItemValue.Port_of_Discharge_Order__c;
            //newRouteRecord.Order_Item__c=ordItemValue.Id;
            //newRouteRecord.Customer__c = orderItemDetails.Order__r.Account_Order__r.ID;
            //newRouteRecord.Name=orderItemDetails.Order__r.Account_Order__r.Name+' || '+orderItemDetails.Port_of_Loading_Order__r.Name+' || '+orderItemDetails.Port_of_Discharge_Order__r.Name;
            newRouteRecord.Name=orderItemDetails.Port_of_Loading_Order__r.Name+' || '+orderItemDetails.Port_of_Discharge_Order__r.Name;
            newRouteRecord.RecordTypeId=RouteMarginRecordType.Id;
            database.insert(newRouteRecord);
            routeRecordToUpdate=newRouteRecord;
        }
        else{
            routeRecordToUpdate=routeMargingList[0];
        }
        if(ordItemValue.Route_Profit_Margin__c==NULL && !System.isFuture() && !System.isBatch()){
            updateRouteOnItem(ordItemValue.id,routeRecordToUpdate.Id,False);  
        }
        
        
        List<Order_Item__c> toProcessItemList = [Select ID,Port_of_Discharge_Order__c,Port_of_Loading_Order__c,Profit__c,Teus__c
                                                 FROM Order_Item__c 
                                                 WHERE Port_of_Loading_Order__c=:ordItemValue.Port_of_Loading_Order__c AND Port_of_Discharge_Order__c=:ordItemValue.Port_of_Discharge_Order__c];
        
        system.debug('toProcessItemList'+toProcessItemList);
        system.debug('toProcessItemList Size'+toProcessItemList.size());
        Decimal finalMarginValue;
        
        for(Order_Item__c ordItem:toProcessItemList){            
            if(ordItem.Profit__c!=NULL && ordItem.Teus__c!=NULL){
                profitTeusSum=profitTeusSum+(ordItem.Profit__c*ordItem.Teus__c);
                TeusSum=TeusSum+ordItem.Teus__c;
            }
        }
        
        system.debug('==profitTeusSum '+profitTeusSum);
        system.debug('==TeusSum '+TeusSum);
        if(profitTeusSum!=0 || TeusSum!=0){
            Decimal averageMargin = profitTeusSum/TeusSum;
            system.debug('=averageMargin '+averageMargin);
            if(routeRecordToUpdate.Margin__c == NULL){
                finalMarginValue = 0 + averageMargin;
            }
            else{
                if(routeRecordToUpdate.Margin__c!=finalMarginValue){
                    finalMarginValue = averageMargin;
                }
            }
            system.debug('=finalMarginValue'+finalMarginValue);
            routeRecordToUpdate.Margin__c = finalMarginValue;
            
            if(routeRecordToUpdate!=NULL){
                database.update(routeRecordToUpdate);
            }
        }    
    }
    
    public static void calculateRouteCustomerMargin(Order_Item__c ordItemValue){
        RecordType RouteCustomerMarginRecordType = [SELECT Id, SobjectType, DeveloperName, Name FROM RecordType Where SobjectType='Route_Profit_Margin__c' And DeveloperName = 'Customer_Port_Pair' Limit 1];
        Decimal profitTeusSum=0;
        Decimal TeusSum=0;
        Order_Item__c orderItemDetails = [SELECT id,Order__r.Account_Order__r.Name,Order__r.Account_Order__r.id,Port_of_Loading_Order__r.Name,Port_of_Discharge_Order__r.Name
                                          FROM Order_Item__c 
                                          WHERE id=:ordItemValue.ID];
        
        
        List<Route_Profit_Margin__c> routeMargingList = [Select ID,Margin__c 
                                                         from Route_Profit_Margin__c 
                                                         Where Port_of_Loading__c=:ordItemValue.Port_of_Loading_Order__c 
                                                         AND Port_of_Discharge__c=:ordItemValue.Port_of_Discharge_Order__c 
                                                         AND Customer__c=:orderItemDetails.Order__r.Account_Order__c Limit 1];
        Route_Profit_Margin__c routeRecordToUpdate;
        
        if(routeMargingList==NULL || routeMargingList.size()<1){
            Route_Profit_Margin__c newRouteRecord = new Route_Profit_Margin__c();
            newRouteRecord.Margin__c=0;
            newRouteRecord.Port_of_Loading__c=ordItemValue.Port_of_Loading_Order__c;
            newRouteRecord.Port_of_Discharge__c=ordItemValue.Port_of_Discharge_Order__c;
            newRouteRecord.Customer__c = orderItemDetails.Order__r.Account_Order__r.ID;
            newRouteRecord.Name=orderItemDetails.Order__r.Account_Order__r.Name+' || '+orderItemDetails.Port_of_Loading_Order__r.Name+' || '+orderItemDetails.Port_of_Discharge_Order__r.Name;
            newRouteRecord.RecordTypeId=RouteCustomerMarginRecordType.Id;
            database.insert(newRouteRecord);
            routeRecordToUpdate=newRouteRecord;
        }
        else{
            routeRecordToUpdate=routeMargingList[0];
        }
        if(ordItemValue.Customer_Port_Pair_Margin__c==NULL && !System.isFuture() && !System.isBatch()){
            updateRouteOnItem(ordItemValue.id,routeRecordToUpdate.Id,True);  
        }
        
        
        List<Order_Item__c> toProcessItemList = [Select ID,Port_of_Discharge_Order__c,Port_of_Loading_Order__c,Profit__c,Teus__c
                                                 FROM Order_Item__c 
                                                 WHERE Port_of_Loading_Order__c=:ordItemValue.Port_of_Loading_Order__c 
                                                 AND Port_of_Discharge_Order__c=:ordItemValue.Port_of_Discharge_Order__c
                                                 AND Order__r.Account_Order__c=:orderItemDetails.Order__r.Account_Order__c ];
        
        system.debug('toProcessItemList'+toProcessItemList);
        system.debug('toProcessItemList Size'+toProcessItemList.size());
        Decimal finalMarginValue;
        
        for(Order_Item__c ordItem:toProcessItemList){            
            if(ordItem.Profit__c!=NULL && ordItem.Teus__c!=NULL){
                profitTeusSum=profitTeusSum+(ordItem.Profit__c*ordItem.Teus__c);
                TeusSum=TeusSum+ordItem.Teus__c;
            }
        }
        
        system.debug('==profitTeusSum '+profitTeusSum);
        system.debug('==TeusSum '+TeusSum);
        if(profitTeusSum!=0 || TeusSum!=0){
            Decimal averageMargin = profitTeusSum/TeusSum;
            system.debug('=averageMargin '+averageMargin);
            if(routeRecordToUpdate.Margin__c == NULL){
                finalMarginValue = 0 + averageMargin;
            }
            else{
                if(routeRecordToUpdate.Margin__c!=finalMarginValue){
                    finalMarginValue = averageMargin;
                }
            }
            system.debug('=finalMarginValue'+finalMarginValue);
            routeRecordToUpdate.Margin__c = finalMarginValue;
            
            if(routeRecordToUpdate!=NULL){
                database.update(routeRecordToUpdate);
            }
        }    
    }
    
    @future
    public static void updateRouteOnItem(ID orderItemID,ID routeMargingID,Boolean isCustomerRoutePair){
        system.debug('');
        Order_Item__c updateItemValue= new Order_Item__c();
        if(isCustomerRoutePair){
            updateItemValue = new Order_Item__c(id=orderItemID,Customer_Port_Pair_Margin__c=routeMargingID);
        }
        else {
            updateItemValue = new Order_Item__c(id=orderItemID,Route_Profit_Margin__c=routeMargingID);
        }
        if(!test.isRunningTest()) database.update(updateItemValue);        
    }
}