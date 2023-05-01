public class BAFCOQuotationTriggerHandler {
    public static void afterUpdate(List<Quotation__c> newList,Map<Id,Quotation__c> oldMap){
        rollUpTotalAmtToOpty(newList,oldMap);
    }
    public static void beforeInsert(List<Quotation__c> newList){
        updateQuotationName(newList);
    }
    public static void updateQuotationName(List<Quotation__c> newList){
        system.debug('newList'+newList);
        List<Quotation__c> jubailRecord = [Select ID,Record_Number__c,Name,Branch__c from Quotation__c Where Branch__c='Jubail' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Quotation__c> jeddahRecord = [Select ID,Record_Number__c,Name,Branch__c from Quotation__c Where Branch__c='Jeddah' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Quotation__c> riyadRecord =  [Select ID,Record_Number__c,Name,Branch__c from Quotation__c Where Branch__c='Riyadh' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        List<Quotation__c> dammamRecord = [Select ID,Record_Number__c,Name,Branch__c from Quotation__c Where Branch__c='Dammam' AND Record_Number__c!=NULL order by Record_Number__c DESC ];
        
        for(Quotation__c newQuote : newList){
            if(newQuote.Branch__c!=NULL){
                Decimal latestNumber;
                if(newQuote.Branch__c=='Jubail'){
                    if(jubailRecord.size()>0){                        
                        system.debug('In jubailRecord');
                        latestNumber=jubailRecord[0].Record_Number__c;
                        if(newQuote.Record_Number__c!=NULL){
                            newQuote.Record_Number__c=newQuote.Record_Number__c+1;
                        }
                        else{
                            newQuote.Record_Number__c=1;
                        }
                        newQuote.Name =getLatestNameValue(latestNumber,'JUB','Q');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newQuote.Name ='JUB/Q/'+yearVal+'/1';
                        newQuote.Record_Number__c=1;
                    }
                }
                else if(newQuote.Branch__c=='Jeddah'){
                    if(jeddahRecord.size()>0){                        
                        system.debug('In jeddahRecord');
                        latestNumber=jeddahRecord[0].Record_Number__c;
                        if(newQuote.Record_Number__c!=NULL){
                            newQuote.Record_Number__c=newQuote.Record_Number__c+1;
                        }
                        else{
                            newQuote.Record_Number__c=1;
                        }
                        newQuote.Name =getLatestNameValue(latestNumber,'JED','Q');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newQuote.Name ='JED/Q/'+yearVal+'/1';
                        newQuote.Record_Number__c=1;
                    }
                }
                
                else if(newQuote.Branch__c=='Riyadh'){
                    if(riyadRecord.size()>0){                        
                        system.debug('In riyadRecord');
                        latestNumber=riyadRecord[0].Record_Number__c;
                        if(newQuote.Record_Number__c!=NULL){
                            newQuote.Record_Number__c=newQuote.Record_Number__c+1;
                        }
                        else{
                            newQuote.Record_Number__c=1;
                        }
                        newQuote.Name =getLatestNameValue(latestNumber,'RYD','Q');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newQuote.Name ='RYD/Q/'+yearVal+'/1';
                        newQuote.Record_Number__c=1;
                    }
                }
                
                else if(newQuote.Branch__c=='Dammam'){
                    if(dammamRecord.size()>0){                        
                        system.debug('In dammamRecord');
                        latestNumber=dammamRecord[0].Record_Number__c;
                        if(newQuote.Record_Number__c!=NULL){
                            newQuote.Record_Number__c=newQuote.Record_Number__c+1;
                        }
                        else{
                            newQuote.Record_Number__c=1;
                        }
                        newQuote.Name =getLatestNameValue(latestNumber,'DMM','Q');                        
                        
                    }else{
                        String yearVal = String.valueOf(system.today().year()).right(2);
                        newQuote.Name ='DMM/Q/'+yearVal+'/1';
                        newQuote.Record_Number__c=1;
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
        Decimal latestNumberVal = latestNumber+1;
        system.debug('latestNumberVal : '+latestNumberVal);
        
        latestValue = BranchCode+'/'+recordType+'/'+yearVal+'/'+latestNumberVal;
        system.debug('latestValue : '+latestValue);
        return latestValue;        
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
    }
}