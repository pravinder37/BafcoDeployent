@isTest
public class BAFCOMeetingControllerTest {
	@TestSetup
    static void setup() {
       Account acc = new Account();
        acc.Branch__c = 'Jeddah';
        acc.Average_Credit_Days__c = 2;
        acc.Average_Margin__c =2;
        acc.Best_Margin__c = 1;
        acc.name = 'test';
        insert acc;
    }
    testMethod static void submitMeetingsRecords(){
        Account acc = [Select id from Account limit 1];
         Enquiry__c enq = new Enquiry__c();
        enq.Name = 'Test';
        enq.Account__c = acc.id;
        enq.Business_Type__c = 'Export';
        insert enq;
        String validityDate = String.valueOf(System.today());
        String timed  = String.valueof(System.now().format('HH:mm'));
        String visitFor = 'Issues';
        test.startTest();
        String eventId = BAFCOMeetingController.submitMeetingsRecords(acc.id, 'test', validityDate, timed, visitFor);
        BAFCOMeetingController.getIntakeMeetingObj(eventId);
        BAFCOMeetingController.getMeetingsRecords(validityDate);
        BAFCOMeetingController.updateEventObject(eventId, enq.id, validityDate, timed, validityDate, timed, 'test', '28.65', '77.4');
        test.stopTest();
    }
}