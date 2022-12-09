public class BAFCOQuotationTriggerHandler {
	public static void afterUpdate(List<Quotation__c> newList,Map<Id,Quotation__c> oldMap){
        rollUpTotalAmtToOpty(newList,oldMap);
    }
    public static void rollUpTotalAmtToOpty(List<Quotation__c> newList,Map<Id,Quotation__c> oldMap){
        Map<Id,Decimal> optyIdToAmount = new Map<Id,Decimal>();
        Set<Id> optyIds = new Set<Id>();
        List<Opportunity> optyList = new List<Opportunity>();
        for(Quotation__c quoteObj : newList){
            if(quoteObj.Total__c != null && quoteObj.Total__c != oldMap.get(quoteObj.Id).Total__c)
            optyIds.add(quoteObj.Opportunity__c);
        }
        for(Quotation__c quoteObj : [Select id,Amount__c,Opportunity__c from Quotation__c where opportunity__c in: optyIds order by createddate desc]){
            if(!optyIdToAmount.containsKey(quoteObj.Opportunity__c)){
                optyIdToAmount.put(quoteObj.Opportunity__c,quoteObj.Amount__c);
            }
        }
        for(Opportunity opty :[Select id,Amount from opportunity where id in: optyIdToAmount.keyset()]){
            opty.Amount = optyIdToAmount.get(opty.Id);
            optyList.add(opty);
        }
        if(optyList.size() > 0) update optyList;
    }
}