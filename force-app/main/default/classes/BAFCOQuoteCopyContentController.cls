public without sharing class BAFCOQuoteCopyContentController {
    @AuraEnabled 
    public static List<QuoteLineList>  getQuoteDataOnLoad(String quoteId){
        List<QuoteLineList> quoteItemList = new List<QuoteLineList>();
        List<Quotation_Item__c> quoteList = [Select id,Quotation__r.Exclusions__c,Quotation__r.Inclusions__c,Quotation__r.Terms_and_Conditions__c,Total__c,Quotation__r.Recordtype.Name,Port_of_Loading__r.Name,Port_of_Discharge__r.Name,Equipment_Type__r.Name from Quotation_Item__c where quotation__c =: quoteId];
        if(quoteList.size() > 0){
            for(Quotation_Item__c item : quoteList){
                QuoteLineList dto = new QuoteLineList();
                dto.loadingPort = item.Port_of_Loading__c != null ? item.Port_of_Loading__r.Name : '';
                dto.dischargePort = item.Port_of_Discharge__c != null ? item.Port_of_Discharge__r.Name : '';
                dto.equipmentType = item.Equipment_Type__c != null ? item.Equipment_Type__r.Name : '';
                dto.total = item.Total__c;
                dto.recordtypeName = item.Quotation__r.Recordtype.Name;
                if(item.Quotation__r.Recordtype.Name == 'Export'){
                    List<String> inclusionList = item.Quotation__r.Inclusions__c != null ? item.Quotation__r.Inclusions__c.split(';;') : null; 
                    if(inclusionList != null && inclusionList.size() > 0){
                        dto.header = inclusionList[0] != null ? inclusionList[0] : null;
                        if(inclusionList.size() >1){
                            dto.headerList = inclusionList[1].split(';');
                        }
                    }
                    List<String> exclusionList =item.Quotation__r.Exclusions__c != null ? item.Quotation__r.Exclusions__c.split(';;') : null; 
                    if(exclusionList != null && exclusionList.size() > 0){
                        dto.exportHeader = exclusionList[0] != null ? exclusionList[0] : null;
                        if(exclusionList.size() >1){
                            dto.exportHeaderList = exclusionList[1].split(';');
                        }
                    }
                }
                else if(item.Quotation__r.Recordtype.Name == 'Import'){
                    List<String> termsList =item.Quotation__r.Terms_and_Conditions__c != null ? item.Quotation__r.Terms_and_Conditions__c.split(';;') : null; 
                    if(termsList != null && termsList.size() > 0){
                        dto.header = termsList[0] != null ? termsList[0] : null;
                        if(termsList.size() >1){
                            dto.headerList = termsList[1].split(';');
                        }
                    }
                }
                quoteItemList.add(dto);
            }
        }
        return quoteItemList;
    }
    public class QuoteLineList{
        @AuraEnabled public String loadingPort{get;set;}
        @AuraEnabled public String dischargePort{get;set;}
        @AuraEnabled public String equipmentType{get;set;}
        @AuraEnabled public Decimal total{get;set;}
        @AuraEnabled public String recordtypeName{get;set;}
        @AuraEnabled public String header{get;set;}
        @AuraEnabled public List<String> headerList{get;set;}
        @AuraEnabled public String exportHeader{get;set;}
        @AuraEnabled public List<String> exportHeaderList{get;set;}
    }
}