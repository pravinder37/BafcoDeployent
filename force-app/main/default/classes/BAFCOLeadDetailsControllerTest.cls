@isTest
public class BAFCOLeadDetailsControllerTest {
    @TestSetup
    static void setup() {
        Lead__c ld = new Lead__c();
        ld.Business_Type__c = 'Import';
        insert ld;
        
        Lead__c ld1 = new Lead__c();
        ld1.Business_Type__c = 'Export';
        insert ld1;
        
        Contact cont = new Contact();
        cont.FirstName='First Name';
        cont.LastName = 'Last name';
        cont.Leadc__c = ld.Id;
        insert cont;
    }
    testmethod static void getLeadDetailsTest01(){
        Id leadId = [Select id from Lead__c where Business_Type__c = 'Import' limit 1].Id;
        test.startTest();
        try{
        	BAFCOLeadDetailsController.getLeadDetails(leadId);
        }
        Catch(Exception e){
            System.debug('BAFCOLeadDetailsControllerTest.getLeadDetailsTest01 exception '+e);
        }
        test.stopTest();
    }
    testmethod static void getLeadDetailsTest02(){
        Id leadId = [Select id from Lead__c where Business_Type__c = 'Export' limit 1].Id;
        test.startTest();
        try{
        	BAFCOLeadDetailsController.getLeadDetails(leadId);
        }
        Catch(Exception e){
            System.debug('BAFCOLeadDetailsControllerTest.getLeadDetailsTest02 exception '+e);
        }
        test.stopTest();
    }
}