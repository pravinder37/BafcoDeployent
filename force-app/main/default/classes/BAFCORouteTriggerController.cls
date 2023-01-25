public class BAFCORouteTriggerController {
    public static void updateNameOnOpty(List<Route__c> routeList){
        Set<Id> optyId = new Set<Id>();
        Map<Id,String> optyIdToRouteName = new Map<Id,String>();
        for(Route__c routeObj : routeList){
           optyId.add(routeObj.Opportunity_Enquiry__c);
        }
        if(optyId.size() > 0){
            List<Opportunity> optyList = new List<Opportunity>();
            for(Route__c routeObj : [Select id,name,Opportunity_Enquiry__c from Route__c where Opportunity_Enquiry__c in :optyId ]){
                String details = '';
                if(!optyIdToRouteName.containsKey(routeObj.Opportunity_Enquiry__c)){
                   optyIdToRouteName.put(routeObj.Opportunity_Enquiry__c,details);
                }
                else{
                    details = optyIdToRouteName.get(routeObj.Opportunity_Enquiry__c);
                    details += '\n'+ routeObj.Name ;
                    optyIdToRouteName.put(routeObj.Opportunity_Enquiry__c,details);
                }
                
            }
            for(Opportunity opty : [Select id from Opportunity where id in:optyId]){
                Opportunity obj = new Opportunity();
                Obj.Id = opty.id;
                obj.routes__c = optyIdToRouteName.get(opty.id);
                optyList.add(obj);
            }
            update optyList;
        }
    }
}