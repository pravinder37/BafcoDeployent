@isTest
public class BAFCOSalesOrderControllerTest {
    @TestSetup
    static void setup() {
        Lead__c ld = new Lead__c();
        ld.Business_Type__c = 'Import';
        insert ld;
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        Port__c port = new Port__c();
        port.City__c = 'Test';
        port.Name ='PortName';
        Insert port;
        
        Commodity__c comd = new Commodity__c();
        comd.Name = 'CommodityName';
        comd.DG_Class__c = 'test';
        insert comd;
        
        Shipping_Line__c shipLine = new  Shipping_Line__c();
        shipLine.Name = 'ShipLine';
        Insert shipLine;
        
        Equipment_Type__c equip = new Equipment_Type__c();
        equip.Name='EquipName';
        Insert equip;
        
        Enquiry__c enq = new Enquiry__c();
        enq.Name = 'Test';
        insert enq;
        
        Route__c route = new Route__c();
        route.Enquiry__c = enq.id;
        route.Port_of_Destination__c = port.id;
        route.Port_of_loading__c =port.id;
        route.Commodity__c = comd.id;
        insert route;
        
        Route_Equipment__c rEquip = new Route_Equipment__c();
        rEquip.Name = 'Test';
        rEquip.Route__c = route.id;
        Insert rEquip;
        
        RMS__c rmsObj = new RMS__c();
        rmsObj.Name ='Test';
        rmsObj.Port_Of_Discharge__c = port.Id;
        rmsObj.Port_Of_Loading__c = port.Id;
        rmsObj.Commodity__c =comd.Id;
        rmsObj.Shipping_Line__c = shipLine.id;
        rmsObj.Equipment_Type__c = equip.id;
        rmsObj.Validity__c = System.today().addDays(5);
        insert rmsObj;
        
        integer year =  Date.Today().Year();
        string s1=string.valueof(year).right(2);
        Integer Year1= Integer.valueof(s1);
        Quotation__c quoteObj = new Quotation__c();
        quoteObj.Name__c= 'Quote/'+Year1+'/'+1;
        quoteObj.Enquiry__c = enq.id;
        quoteObj.Leadc__c = ld.id;
        quoteObj.Account__c = acc.id;
        Insert quoteObj;
        
        Quotation_Item__c quoteItem = new Quotation_Item__c();
        quoteItem.RMS__c = rmsObj.id;
        quoteItem.Route__c = route.id;
        quoteItem.Quotation__c = quoteObj.Id;
        quoteItem.Equipment_Type__c = equip.id;
        Insert quoteItem;
        
    }
    testmethod static void getRouteItemTest(){
        String quoteID = [Select id from Quotation__c limit 1].Id;
        test.startTest();
        BAFCOSalesOrderController.getRouteItem(quoteID);        
        test.stopTest();
    }
    testmethod static void getQuoteLineItemTest(){
        String quoteID = [Select id from Quotation__c limit 1].Id;
        String routeID = getRouteId();
        test.startTest();
        BAFCOSalesOrderController.getQuoteLineItem(quoteID,routeID);        
        test.stopTest();
    }
    testmethod static void createOrderTest(){
        test.startTest();
        List<BAFCOOrderCreationDto> dtoList = getOrderCreationDto();
        system.debug('dtoList '+dtoList);
        BAFCOSalesOrderController.createOrder(dtoList);        
        test.stopTest();
    }
    static List<BAFCOOrderCreationDto> getOrderCreationDto(){
		List<BAFCOOrderCreationDto.value> valueList = new List<BAFCOOrderCreationDto.value>();        
        BAFCOOrderCreationDto.value valueObj = new BAFCOOrderCreationDto.value();
        valueObj.accountId = getAccountId();
        valueObj.baf = 0;
        valueObj.bayan = 0;
        valueObj.bayanCancellation = 0;
        valueObj.enquiryId = getEnquiryId();
        valueObj.quotationId = getQuoteId();
        valueObj.shipName = 'COSCO';
        valueObj.sellingTotal = 1100;
        valueList.add(valueObj);
        
        List<BAFCOOrderCreationDto.equipment> equipList = new List<BAFCOOrderCreationDto.equipment>();
        BAFCOOrderCreationDto.equipment equipObj = new BAFCOOrderCreationDto.equipment();
        equipObj.key = '20FT HC';
        equipObj.value = valueList;
        equipList.add(equipObj);
        
        List<BAFCOOrderCreationDto> dtoList = new List<BAFCOOrderCreationDto>();
        BAFCOOrderCreationDto dtoObj = new BAFCOOrderCreationDto();
        dtoObj.routeName = 'Test';
        dtoObj.routeId = getRouteId();
        dtoObj.equipment = equipList;
        dtoList.add(dtoObj);
        return dtoList;
    }
    static string getRouteId(){
        return [Select id from Route__c limit 1].Id;
    }
    static string getAccountId(){
        return [Select id from Account limit 1].Id;
    }
    static string getEnquiryId(){
        return [Select id from Enquiry__c limit 1].Id;
    }
    static string getQuoteId(){
        return [Select id from Quotation__c limit 1].Id;
    }
}