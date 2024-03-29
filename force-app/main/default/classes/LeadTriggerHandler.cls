public class LeadTriggerHandler {
    public static void accountUpdatesOnConversion(List<Lead> leadList){
        Set <Id> setAccountIds = new Set <Id>(); 
        Map<Id,Lead> assignedByManagementLeads = new Map<Id,Lead>();
        for (Lead objLead : leadList) {
            if(objLead.IsConverted){
                setAccountIds.add(objLead.ConvertedAccountId);      
            }
            if(objLead.IsConverted && objLead.Assigned_by_management__c){
                assignedByManagementLeads.put(objLead.ConvertedAccountId,objLead);      
            }
            
            if (setAccountIds.size()>0){                
                List<Account> listAcctForUpdate = new List<Account>();
                for (Account objAccount : [SELECT Id,isconvertedfromlead__c,isassignedbymanagement__c FROM Account WHERE Id IN: setAccountIds]){                    
                    objAccount.isconvertedfromlead__c=True;
                    if(assignedByManagementLeads.get(objAccount.Id)!=NULL){
                        objAccount.isassignedbymanagement__c=True; 
                    }
                    listAcctForUpdate.add(objAccount);
                }
                if (listAcctForUpdate.size()>0){
                    update listAcctForUpdate;
                }
            }
        }
    }
}