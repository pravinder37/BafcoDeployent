@isTest
public class BAFCOImportQuoteControllerTest {
	@TestSetup
    static void setup() {
        Lead__c ld = new Lead__c();
        ld.Business_Type__c = 'Import';
        insert ld;
        
        Port__c port = new Port__c();
        port.City__c = 'Test';
        port.Name ='PortName';
        port.Sector__c = 'Africa';
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
        
        Account acc = new Account();
        acc.Branch__c = 'Jeddah';
        acc.Average_Credit_Days__c = 2;
        acc.Average_Margin__c =2;
        acc.Best_Margin__c = 1;
        acc.name = 'test';
        insert acc;
        opportunity opty = new Opportunity();
        opty.AccountId = acc.id;
        opty.StageName = 'Qualification';
        opty.CloseDate = system.today();
        opty.Name ='testopty';
        opty.Business_Type__c = 'Export';
        insert opty;
        Regular_Routing__c regObj = new Regular_Routing__c();
        regObj.Account__c = acc.id;
        regObj.Name = 'test';
        insert regObj;
        
        Enquiry__c enq = new Enquiry__c();
        enq.Name = 'Test';
        enq.Account__c = acc.id;
        enq.Business_Type__c = 'Export';
        insert enq;
        place__c  placeObj = new place__c();
        placeObj.Name = 'test';
        insert placeObj;
        Route__c route = new Route__c();
        route.Opportunity_Enquiry__c = opty.id;
        route.Port_of_Destination__c = port.id;
        route.Port_of_loading__c =port.id;
        route.Commodity__c = comd.id;
        route.Place_of_Discharge__c = placeObj.id;
        route.Place_of_Pickup__c = placeObj.id;
        insert route;
        
        Route_Equipment__c rEquip = new Route_Equipment__c();
        rEquip.Route__c = route.id;
        rEquip.Equipment_Type__c = equip.id;
        Insert rEquip;
        Agent__c agentObj = new Agent__c();
        agentObj.name =  'test';
        insert agentObj;
         Id RMS_IMPORT_RECORDTYPE_Id = Schema.SObjectType.RMS__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
        RMS__c rmsObj = new RMS__c();
        rmsObj.Name ='Test';
        rmsObj.Port_Of_Discharge__c = port.Id;
        rmsObj.Port_Of_Loading__c = port.Id;
        rmsObj.Commodity__c =comd.Id;
        rmsObj.Shipping_Line__c = shipLine.id;
        rmsObj.Equipment_Type__c = equip.id;
        rmsObj.RecordTypeId = RMS_IMPORT_RECORDTYPE_Id;
        rmsObj.Validity__c = System.today().addDays(5);
        insert rmsObj;
        
        integer year =  Date.Today().Year();
        string s1=string.valueof(year).right(2);
        Integer Year1= Integer.valueof(s1);
        Quotation__c quoteObj = new Quotation__c();
        quoteObj.Name__c= 'Quote/'+Year1+'/'+1;
        quoteObj.Opportunity__c = opty.id;
        quoteObj.Leadc__c = ld.id;
        Insert quoteObj;
        
        Quotation_Item__c quoteItem = new Quotation_Item__c();
        quoteItem.RMS__c = rmsObj.id;
        quoteItem.Route__c = route.id;
        quoteItem.Quotation__c = quoteObj.Id;
        quoteItem.Equipment_Type__c = equip.id;
        Insert quoteItem;
        
        Exchange_Rate__c exc = new Exchange_Rate__c ();
        exc.Currency_Code__c = 'INR';
        insert exc;
        Route_Equipment__c routeEquip = new Route_Equipment__c();
        routeEquip.Route__c = route.Id;
        routeEquip.Equipment_Type__c = equip.Id;
        routeEquip.Quantity__c = 12;
        insert routeEquip;
        
        INCO_Term__c incoTerm = new INCO_Term__c();
        incoTerm.Name = 'IncoTerm';
        insert incoTerm;
        
        INCO_Term__c incoTerm2 = new INCO_Term__c();
        incoTerm2.Name = 'IncoTerm2';
        insert incoTerm2;
        
        INCO_Charge__c incoCharge = new INCO_Charge__c();
        incoCharge.INCO_Term__c = incoTerm.id;
        incoCharge.RMS__c = rmsObj.Id;
        incoCharge.Bayan__c=12;        
        insert incoCharge;
        
        INCO_Charge__c incoCharge2 = new INCO_Charge__c();
        incoCharge2.INCO_Term__c = incoTerm2.id;
        incoCharge2.RMS__c = rmsObj.Id;
        insert incoCharge2;
        
        Additional_Charge__c addCharge = new Additional_Charge__c();
        addCharge.Name = 'AdditionalCharge';
        insert addCharge;
        
        template__c templateObj= new template__c();
        templateObj.Name = 'test';
        templateObj.Field10_Name__c = 'test';
        templateObj.Field10_Value__c = 12;
        Insert templateObj;
        
    }
    testmethod static void generateQuote(){
        String routeId = [Select id from Route__c limit 1].Id;
        String rmsId = [Select id from RMS__c limit 1].Id;
        String enquiryId = [Select id from opportunity limit 1].Id;
        String quotationId = [Select id from Quotation__c limit 1].Id;
        String agentId = [Select id from Agent__c limit 1].Id;
        String incoTerm = 'IncoTerm';
       
        List< BAFCOImportRMSDto.AdditionalCharge> addList = new List< BAFCOImportRMSDto.AdditionalCharge>();
        
        BAFCOImportRMSDto.AdditionalCharge a1 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a1.name = 'Bayan cancellation charge';
        a1.value =12;
        addList.add(a1);
        BAFCOImportRMSDto.AdditionalCharge a2 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a2.name = 'Cleaning charges';
        a2.value =12;
        addList.add(a2);
        BAFCOImportRMSDto.AdditionalCharge a3 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a3.name = 'Container Lashing Charges';
        a3.value =12;
        addList.add(a3);
        BAFCOImportRMSDto.AdditionalCharge a4 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a4.name = 'Container movement charges';
        a4.value =12;
        addList.add(a4);
        BAFCOImportRMSDto.AdditionalCharge a5 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a5.name = 'Container stripping';
        a5.value =12;
        addList.add(a5);
        BAFCOImportRMSDto.AdditionalCharge a6 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a6.name = 'Free time certificate charges';
        a6.value =12;
        addList.add(a6);
        BAFCOImportRMSDto.AdditionalCharge a7 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a7.name = 'Fumigation';
        a7.value =12;
        addList.add(a7);
        BAFCOImportRMSDto.AdditionalCharge a8 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a8.name = 'Inspection';
        a8.value =12;
        addList.add(a8);
        BAFCOImportRMSDto.AdditionalCharge a9 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a9.name = 'Insurance charges';
        a9.value =12;
        addList.add(a9);
        BAFCOImportRMSDto.AdditionalCharge a10 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a10.name = 'Ministry clearnce charge for OOG cargo';
        a10.value =12;
        addList.add(a10);
        BAFCOImportRMSDto.AdditionalCharge a11 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a11.name = 'Miscellaneous';
        a11.value =12;
        addList.add(a11);
        BAFCOImportRMSDto.AdditionalCharge a12 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a12.name = 'MOT fine charges';
        a12.value =12;
        addList.add(a12);
        BAFCOImportRMSDto.AdditionalCharge a13 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a13.name = 'Non Palletized Surcharge';
        a13.value =12;
        addList.add(a13);
        BAFCOImportRMSDto.AdditionalCharge a14 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a14.name = 'Pest control';
        a14.value =12;
        addList.add(a14);
        BAFCOImportRMSDto.AdditionalCharge a15 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a15.name = 'Re palletization';
        a15.value =12;
        addList.add(a15);
        BAFCOImportRMSDto.AdditionalCharge a16 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a16.name = 'Reefer cntr plug-in charges';
        a16.value =12;
        addList.add(a16);
        BAFCOImportRMSDto.AdditionalCharge a17 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a17.name = 'Reefer PTI charges';
        a17.value =12;
        addList.add(a17);
        BAFCOImportRMSDto.AdditionalCharge a18 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a18.name = 'Reefer steam wash';
        a18.value =12;
        addList.add(a18);
        BAFCOImportRMSDto.AdditionalCharge a19 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a19.name = 'Stuffing Charges';
        a19.value =12;
        addList.add(a19);
        BAFCOImportRMSDto.AdditionalCharge a20 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a20.name = 'Sweeping/Cleaning';
        a20.value =12;
        addList.add(a20);
        BAFCOImportRMSDto.AdditionalCharge a21 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a21.name = 'Truck Head charges';
        a21.value =12;
        addList.add(a21);
        BAFCOImportRMSDto.AdditionalCharge a22 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a22.name = 'Truck idling charges';
        a22.value =12;
        addList.add(a22);
        BAFCOImportRMSDto.AdditionalCharge a23 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a23.name = 'Vessel certificate charges';
        a23.value =12;
        addList.add(a23);
        BAFCOImportRMSDto.AdditionalCharge a24 = new BAFCOImportRMSDto.AdditionalCharge(); 
        a24.name = 'Wrapping/packing charges';
        a24.value =12;
        addList.add(a24);
        
        BAFCOImportRMSDto dto = new BAFCOImportRMSDto();
        BAFCOIncoChargesDto incoChargeList = new BAFCOIncoChargesDto();
        incoChargeList.bayan=12;
        BAFCOImportRMSDto.destinChargeObj destiObj = new BAFCOImportRMSDto.destinChargeObj();
        destiObj.destinBayanCharges = 1;
        destiObj.DestinTotalChanged = false;
        BAFCOImportRMSDto.originChargesObj originObj = new BAFCOImportRMSDto.originChargesObj();
        originObj.bayan = 1;
        originObj.originTotalChanged = false;
        BAFCOImportRMSDto.servichargesObj servObj = new BAFCOImportRMSDto.servichargesObj();
        servObj.BAF = 1;
        servObj.shippTotalChanged = false;
        BAFCOImportRMSDto.serviceChargeList servList1 = new BAFCOImportRMSDto.serviceChargeList();
        servList1.destinChargeObj = destiObj;
        servList1.originChargesObj = originObj;
        servList1.servichargesObj = servObj;
        dto.serviceChargeList = servList1;
        dto.additionalChargeList = addList;
        test.startTest();
        String QuoteId = BAFCOImportQuoteController.genrateQuotation(routeId, rmsId, enquiryId, quotationId, dto, incoTerm, 'test', 1, false, false, agentId);
        String QuoteId1 = BAFCOImportQuoteController.genrateQuotation(routeId, rmsId, enquiryId, quotationId, dto, incoTerm, 'test', 1, true, true, agentId);
        test.stopTest();
    }
    testmethod static void getAgentsRecordsTest(){
        test.startTest();
        BAFCOImportQuoteController.getAgentsRecords();
        test.stopTest();
    }
    testmethod static void getImportRMSDetailsTest(){
        String portLoading = 'PortName';
        String portDestination = 'PortName';
        String commodity = 'CommodityName';
        String enquiryId =''/* [Select id from Enquiry__c limit 1].Id*/;
        String routeId = [Select id from Route__c limit 1].Id;
        test.startTest();
        BAFCOImportQuoteController.getImportRMSDetails(portLoading, portDestination, commodity, routeId, enquiryId);
        test.stopTest();
    }
}