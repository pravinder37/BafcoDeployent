@RestResource(urlMapping='/OrderUpdate/UpdateETDValue/*')
global class BAFCOUpdatETDOnOrderAPI{    
    @HttpPost
    global static ETDResponseBodyWrapper doPost(){
        ETDResponseBodyWrapper responseWrapper = new ETDResponseBodyWrapper();
        String UpdatedOrderNumber;
        try{
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            List<Order_Item__c> OrderItemList = new List<Order_Item__c>();
            ETDRequestBodyWrapper reqWrapper = (ETDRequestBodyWrapper) JSON.deserialize(requestBody, ETDRequestBodyWrapper.class);
            Order__c Order = [Select Id FROM Order__c WHERE Name = :reqWrapper.OrderNumber Limit 1];
            if(Order != null){
                OrderItemList = [Select Id , Vessel_ETD__c FROM Order_Item__c WHERE Order__c =: Order.Id];
                Set<Id> accountIds = new Set<Id>();
                for(Order_Item__c OrderItem : OrderItemList){
                    OrderItem.Vessel_ETD__c=reqWrapper.VesselETD;
                }
                database.update(OrderItemList);                        
            }
            
            if(!OrderItemList.IsEmpty()){
                responseWrapper.StatusCode = '200';
                responseWrapper.Message = 'Status Code :200 -- Order Details Updated Successfully for :'+reqWrapper.OrderNumber;
            }else{
                responseWrapper.message = 'No Order Information found with respect to provided Number :'+reqWrapper.OrderNumber;
            }
            
            
        }catch(Exception e){
            responseWrapper.message = 'Exception :'+e.getMessage()+' '+e.getLineNumber();
        }
        return responseWrapper;
    }
    
    global class ETDResponseBodyWrapper{
        public String Message {get;set;}
        public String StatusCode {get;set;}
    }
    
    global class ETDRequestBodyWrapper{
        public String OrderNumber {get;set;}
        public Date VesselETD {get;set;}        
    }
}