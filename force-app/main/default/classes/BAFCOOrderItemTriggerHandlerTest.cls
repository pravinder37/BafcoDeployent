@istest
public class BAFCOOrderItemTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.name = 'test';
        acc.branch__c ='Jeddah';
        insert acc;
        opportunity opty = new Opportunity();
        opty.AccountId = acc.id;
        opty.StageName = 'Qualification';
        opty.CloseDate = system.today();
        opty.Name ='testopty';
        opty.Business_Type__c = 'Export';
        insert opty;
        Task tsk = new Task();
        tsk.Subject = 'Provide Quotation';
        tsk.Status = 'Open';
        tsk.OwnerId = UserInfo.getUserId();
        tsk.WhatId = opty.Id;
        tsk.IsReminderSet = true;
        tsk.ActivityDate = Date.valueOf(DateTime.now());
        insert tsk;
        
        Port__c port = new Port__c();
        port.City__c = 'Test';
        port.Name ='PortName';
        port.Sector__c = 'Africa';
        Insert port;
        Date dt = System.today();
        Target__c targObj = new Target__c();
        targObj.Target_Month__c = dt;
        targObj.Target_Value_In_Teus__c = 3;
        insert targObj;
        
	    Port__c port2 = new Port__c();
        port2.City__c = 'Test1';
        port2.Name ='PortName1';
        port2.Sector__c = 'Africa';
        Insert port2;
        
        Regular_Routing__c regObj2 = new Regular_Routing__c();
        regObj2.Account__c=acc.id;
        regObj2.Port_of_Loading__c = port.id;
        regObj2.Port_of_Destination__c = port.id;
        insert regObj2;
        
        integer year =  Date.Today().Year();
        string s1=string.valueof(year).right(2);
        Integer Year1= Integer.valueof(s1);
        Quotation__c quoteObj = new Quotation__c();
        quoteObj.Name__c= 'Quote/'+Year1+'/'+1;
        quoteObj.Opportunity__c = opty.id;
        quoteObj.Account__c = acc.id;
        quoteObj.Customer_Name__c = 'test';
        Insert quoteObj;
        
        Order__c obj = new Order__c();
        obj.Account_Order__c = acc.id;
        obj.Quotation__c = quoteObj.id;
        insert obj;
        
    }
    testmethod static void testItemInsert(){
        Order__c obj = [Select id from Order__c limit 1];
        Port__c port2 = [Select id from Port__c where Name ='PortName1' limit 1];                
        Order_item__c item2  = new Order_item__c();
        item2.Port_of_Discharge_Order__c = port2.id;
        item2.Port_of_Loading_Order__c =port2.id;
        item2.Order__c = obj.id;
        insert item2;
        delete item2;
    }
    testmethod static void testItemInsert2(){
        Order__c obj = [Select id from Order__c limit 1];
        Port__c port2 = [Select id from Port__c where Name <> 'PortName1' limit 1];                
        Order_item__c item2  = new Order_item__c();
        item2.Port_of_Discharge_Order__c = port2.id;
        item2.Port_of_Loading_Order__c =port2.id;
        item2.Order__c = obj.id;
        Port__c port = new Port__c();
        port.City__c = 'Test';
        port.Name ='PortName';
        port.Sector__c = 'Africa';
        Insert port;
        
        
         Order_item__c item3  = new Order_item__c();
        item3.Port_of_Discharge_Order__c = port.id;
        item3.Port_of_Loading_Order__c =port.id;
        item3.Order__c = obj.id;
        List<Order_item__c> itemList  = new List<Order_item__c>{item2,item3};
            
            insert itemList;
        // itemList;
    }
}