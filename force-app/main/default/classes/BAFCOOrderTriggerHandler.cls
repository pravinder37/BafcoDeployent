public class BAFCOOrderTriggerHandler {
    public static void afterAction(List<Order__c> orderList){
        set<ID> orderIDSet = new Set<ID>();
        List<ID> orderIDList = new List<ID>();
        for(Order__c ord:orderList){
            orderIDSet.add(ord.ID);
        }
        orderIDList.addAll(orderIDSet);
        BAFCOSendOrdersAPI.sendOrderData(orderIDList);        
    }
}