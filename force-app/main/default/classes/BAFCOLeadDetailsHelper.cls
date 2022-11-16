public class BAFCOLeadDetailsHelper {
    public static List<Lead__c> getLeadDetails(String leadId){         
        return [Select id,Name,Status__c,CreatedDate, Modes__c, Business_Type__c,owner.name From Lead__c Where id =: leadId limit 1];
    }
    public static List<contact> getContactDetails(String leadId){
        return [Select MobilePhone,Email from Contact where Leadc__c =: leadId order by createddate limit 1];
    }
    public static List<Account> getAccountDetails(String leadId){         
        return [Select id,Name,owner.name,CreatedDate From Account Where id =: leadId limit 1];
    }
    public static List<contact> getAccountContactDetails(String leadId){
        return [Select MobilePhone,Email from Contact where AccountId =: leadId order by createddate limit 1];
    }
}