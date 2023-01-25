public class BAFCOImportSearchController {
    @AuraEnabled
    public static List<order_item__c> getImportItem(String agentId, String fromVesselETD, String toVesselETD){
        List<Order_item__c> itemList =  new List<Order_item__c>();
        if(fromVesselETD == null && toVesselETD == null){
            if(agentId != ''){
                itemList = [Select quantity__c,Order__r.Account_Order__c,Agent__r.name,Shipping_Line__r.Name,Vessel_ETD__c,Port_of_Discharge_Order__r.Name,Port_of_Loading_Order__r.Name,Order__r.Quotation__r.Name,Order__r.Name,Name,Total_Order__c,buying_rate__c from order_item__c where Order__r.Account_Order__c =: agentId and Order__r.recordtype.name ='Import' order by order__r.Order_Validity__c desc];
            }
        }
        else{
            if(agentId != ''){
                itemList = [Select quantity__c,Order__r.Account_Order__c,Agent__r.name,Shipping_Line__r.Name,Vessel_ETD__c,Port_of_Discharge_Order__r.Name,Port_of_Loading_Order__r.Name,Order__r.Quotation__r.Name,Order__r.Name,Name,Total_Order__c,buying_rate__c from order_item__c where Order__r.Account_Order__c =: agentId AND Vessel_ETD__c >=: Date.valueOf(fromVesselETD) AND Vessel_ETD__c <=: Date.valueOf(toVesselETD)  and Order__r.recordtype.name ='Import' order by order__r.Order_Validity__c desc];
            }
            else{
                itemList = [Select quantity__c,Order__r.Account_Order__c,Agent__r.name,Shipping_Line__r.Name,Vessel_ETD__c,Port_of_Discharge_Order__r.Name,Port_of_Loading_Order__r.Name,Order__r.Quotation__r.Name,Order__r.Name,Name,Total_Order__c,buying_rate__c from order_item__c where Vessel_ETD__c >=: Date.valueOf(fromVesselETD) AND Vessel_ETD__c <=: Date.valueOf(toVesselETD)  and Order__r.recordtype.name ='Import' order by order__r.Order_Validity__c desc];

            }
        }
        return itemList;
    }
    @AuraEnabled
    public static order_item__c updateQuoteItem(Decimal buyingRate, Decimal sellingRate, String recordId){
        order_item__c item = new order_item__c();
        item.Id = recordId;
        item.Buying_Rate__c = buyingRate;
        item.Total_Order__c = sellingRate;
        update item ;
        return item;
    }
}