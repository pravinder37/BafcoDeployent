@isTest
public class BAFCOLRoutingDetailsControllerTest {
    @TestSetup
    static void setup() {
        Lead__c ld = new Lead__c();
        ld.Business_Type__c = 'Import';
        insert ld;
        
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
        
        Account acc = new Account();
        acc.Branch__c = 'Jeddah';
        acc.Average_Credit_Days__c = 2;
        acc.Average_Margin__c =2;
        acc.Best_Margin__c = 1;
        acc.name = 'test';
        insert acc;
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
        route.Enquiry__c = enq.id;
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
    testmethod static void getEnqueryDetailsTest01(){
        String enquiryID = [Select id from Enquiry__c limit 1].Id;
        test.startTest();
        try{
            BAFCOLRoutingDetailsController.getEnqueryDetails(enquiryID);
        }
        Catch(Exception e){
            system.debug('getEnqueryDetailsTest '+e);
        }
        test.stopTest();
    }
    testmethod static void getRMSDetailsTest01(){
        String portLoading = 'PortName';
        String portDestination = 'PortName';
        String commodity = 'CommodityName';
        String enquiryId = [Select id from Enquiry__c limit 1].Id;
        String routeId = [Select id from Route__c limit 1].Id;
        test.startTest();
        BAFCOLRoutingDetailsController.getRMSDetails(portLoading, portDestination, commodity, routeId, enquiryId);
        test.stopTest();
    }
    testMethod static void searchTest01(){
        String searchTerm='PortName';
        String myObject ='Port__c';
        String filter = 'test';
        test.startTest();
        try{
            BAFCOLRoutingDetailsController.search(searchTerm, myObject, null);
            BAFCOLRoutingDetailsController.search(null, myObject, null);
            BAFCOLRoutingDetailsController.search(searchTerm, myObject, filter);
        }
        catch(Exception e){}
        test.stopTest();
    }
    testMethod static void submitRoutingListTest(){
        List<BAFCORoutingDetailsDto> bafcoList = new List<BAFCORoutingDetailsDto>();
        String equipId = [Select id from Equipment_Type__c limit 1].id;
        BAFCORoutingDetailsDto.containerRecord contRecord = new  BAFCORoutingDetailsDto.containerRecord();
        contRecord.containerType = equipId;
        List<BAFCORoutingDetailsDto.containerRecord> contList = new List<BAFCORoutingDetailsDto.containerRecord>();
        contList.add(contRecord);
        BAFCORoutingDetailsDto dto = new BAFCORoutingDetailsDto();
        dto.dgClass = 'Class 1';
        dto.dangerousGoods = true;
        dto.leadIndex = '0';
        dto.containerRecord = contList;
        bafcoList.add(dto);
        String quoteId = [Select id from Lead__c limit 1].Id;
        BAFCOLRoutingDetailsController.submitRoutingList(bafcoList, 'Import', quoteId);
    }
    testMethod static void getIncoChargesTest(){
        string rmsId = [Select id from RMS__c limit 1].Id;
        String incoTerm = 'IncoTerm';
        test.startTest();
        BAFCOLRoutingDetailsController.getIncoCharges(rmsId, incoTerm);
        test.stopTest();
    }
    testMethod static void getIncoChargesTest02(){
        string rmsId = [Select id from RMS__c limit 1].Id;
        String incoTerm = 'IncoTerm2';
        test.startTest();
        BAFCOLRoutingDetailsController.getIncoCharges(rmsId, incoTerm);
        test.stopTest();
    }
    testMethod static void getAdditionalChargesTest(){
        String value = 'AdditionalCharge';
        test.startTest();
        BAFCOLRoutingDetailsController.getAdditionalCharges(value);
        test.stopTest();
    }
    testMethod static void genrateQuotationTest(){
        String routeId = [Select id from Route__c limit 1].Id;
        String rmsId = [Select id from RMS__c limit 1].Id;
        String enquiryId = [Select id from Enquiry__c limit 1].Id;
        String quotationId = [Select id from Quotation__c limit 1].Id;
        String incoTerm = 'IncoTerm';
        
         List< BAFCOGenerteQuoteDto.AdditionalCharge> addList = new List< BAFCOGenerteQuoteDto.AdditionalCharge>();
        
        BAFCOGenerteQuoteDto.AdditionalCharge a1 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a1.name = 'Bayan cancellation charge';
        a1.value =12;
        addList.add(a1);
        BAFCOGenerteQuoteDto.AdditionalCharge a2 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a2.name = 'Cleaning charges';
        a2.value =12;
        addList.add(a2);
        BAFCOGenerteQuoteDto.AdditionalCharge a3 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a3.name = 'Container Lashing Charges';
        a3.value =12;
        addList.add(a3);
        BAFCOGenerteQuoteDto.AdditionalCharge a4 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a4.name = 'Container movement charges';
        a4.value =12;
        addList.add(a4);
        BAFCOGenerteQuoteDto.AdditionalCharge a5 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a5.name = 'Container stripping';
        a5.value =12;
        addList.add(a5);
        BAFCOGenerteQuoteDto.AdditionalCharge a6 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a6.name = 'Free time certificate charges';
        a6.value =12;
        addList.add(a6);
        BAFCOGenerteQuoteDto.AdditionalCharge a7 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a7.name = 'Fumigation';
        a7.value =12;
        addList.add(a7);
        BAFCOGenerteQuoteDto.AdditionalCharge a8 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a8.name = 'Inspection';
        a8.value =12;
        addList.add(a8);
        BAFCOGenerteQuoteDto.AdditionalCharge a9 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a9.name = 'Insurance charges';
        a9.value =12;
        addList.add(a9);
        BAFCOGenerteQuoteDto.AdditionalCharge a10 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a10.name = 'Ministry clearnce charge for OOG cargo';
        a10.value =12;
        addList.add(a10);
        BAFCOGenerteQuoteDto.AdditionalCharge a11 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a11.name = 'Miscellaneous';
        a11.value =12;
        addList.add(a11);
        BAFCOGenerteQuoteDto.AdditionalCharge a12 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a12.name = 'MOT fine charges';
        a12.value =12;
        addList.add(a12);
        BAFCOGenerteQuoteDto.AdditionalCharge a13 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a13.name = 'Non Palletized Surcharge';
        a13.value =12;
        addList.add(a13);
        BAFCOGenerteQuoteDto.AdditionalCharge a14 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a14.name = 'Pest control';
        a14.value =12;
        addList.add(a14);
        BAFCOGenerteQuoteDto.AdditionalCharge a15 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a15.name = 'Re palletization';
        a15.value =12;
        addList.add(a15);
        BAFCOGenerteQuoteDto.AdditionalCharge a16 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a16.name = 'Reefer cntr plug-in charges';
        a16.value =12;
        addList.add(a16);
        BAFCOGenerteQuoteDto.AdditionalCharge a17 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a17.name = 'Reefer PTI charges';
        a17.value =12;
        addList.add(a17);
        BAFCOGenerteQuoteDto.AdditionalCharge a18 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a18.name = 'Reefer steam wash';
        a18.value =12;
        addList.add(a18);
        BAFCOGenerteQuoteDto.AdditionalCharge a19 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a19.name = 'Stuffing Charges';
        a19.value =12;
        addList.add(a19);
        BAFCOGenerteQuoteDto.AdditionalCharge a20 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a20.name = 'Sweeping/Cleaning';
        a20.value =12;
        addList.add(a20);
        BAFCOGenerteQuoteDto.AdditionalCharge a21 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a21.name = 'Truck Head charges';
        a21.value =12;
        addList.add(a21);
        BAFCOGenerteQuoteDto.AdditionalCharge a22 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a22.name = 'Truck idling charges';
        a22.value =12;
        addList.add(a22);
        BAFCOGenerteQuoteDto.AdditionalCharge a23 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a23.name = 'Vessel certificate charges';
        a23.value =12;
        addList.add(a23);
        BAFCOGenerteQuoteDto.AdditionalCharge a24 = new BAFCOGenerteQuoteDto.AdditionalCharge(); 
        a24.name = 'Wrapping/packing charges';
        a24.value =12;
        addList.add(a24);
        
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
        BAFCOGenerteQuoteDto.serviceChargeList servList1 = new BAFCOGenerteQuoteDto.serviceChargeList();
        servList1.destinChargeObj = destiObj;
        servList1.originChargesObj = originObj;
        servList1.servichargesObj = servObj;
        
        BAFCOGenerteQuoteDto dto1 = new BAFCOGenerteQuoteDto();
        dto1.seaFreightSellRate = 121;
        dto1.total = 121;
        dto1.incoChargList = incoChargeList;
        dto1.additionalChargeList = addList;
        dto1.serviceChargeList = servList1;
        String validityDate = String.valueOf(System.today());
        test.startTest();
        String QuoteId = BAFCOLRoutingDetailsController.genrateQuotation(routeId, rmsId, enquiryId, quotationId, dto1, incoTerm,false,false,'test',1);
        BAFCOLRoutingDetailsController.genrateQuotation(routeId, rmsId, enquiryId, quotationId, dto1, incoTerm,true,true,'test',1);
        BAFCOLRoutingDetailsController.updateValidityDate(QuoteId, validityDate);
        test.stopTest();
    }
    testMethod static void addRatesTest(){
        BAFCORMSDto rmsDetail = new BAFCORMSDto();
        rmsDetail.validity = '2022-07-22';
        rmsDetail.allInRate = false;
        rmsDetail.FOBAllIn = false;
        rmsDetail.ExWorksIn = false;
        String routeId = [Select id from Route__c limit 1].Id;
        shippingLineChargesDTO shippingChargeDto = new shippingLineChargesDTO();
        BAFCOIncoChargesDto incocharges = new BAFCOIncoChargesDto();
        BAFCODestinationChargeDto destiObj =new BAFCODestinationChargeDto();
        Boolean totalShippChanged = false;
        Boolean totalIncoChanged = false;
        String equipmentType = 'EquipName';
        String shippingLine = 'ShipLine';
        String leadId = [Select id from Lead__c limit 1].Id;
        
        test.startTest();
        BAFCOLRoutingDetailsController.addRates(rmsDetail, routeId, shippingChargeDto, incocharges, totalShippChanged, totalIncoChanged, equipmentType, shippingLine, leadId,false,destiObj);
        test.stopTest();
    }
    testMethod static void getShiplineTest(){
        test.startTest();
        BAFCOLRoutingDetailsController.getShipline();
        test.stopTest();
    }
    testMethod static void getRouteEquipTypeTest(){
        String routeId = [Select id from Route__c limit 1].id;
        test.startTest();
        BAFCOLRoutingDetailsController.getRouteEquipType(routeId);
        test.stopTest();
    }
    testMethod static void getTemplatesDataTest(){
        test.startTest();
        BAFCOLRoutingDetailsController.getTemplatesData();
        test.stopTest();
    }
    testMethod static void submitTemplatesDataTest(){
        template__c templateObj= new template__c();
        templateObj.Name = 'test';
        templateObj.Field10_Name__c = 'test';
        templateObj.Field10_Value__c = 12;
        test.startTest();
        BAFCOLRoutingDetailsController.submitTemplatesData(templateObj);
        test.stopTest();
    }
    testMethod static void getLoadingChargesTest(){
        String pickupPlace = '';
        String portLoading = '';
        String directionValue = '';
        test.startTest();
        BAFCOLRoutingDetailsController.getLoadingCharges(pickupPlace, portLoading, directionValue);
        test.stopTest();
    }
    testMethod static void getAllRegularRouteTest(){
       Account acc = [Select id from account limit 1];
        test.startTest();
        BAFCOLRoutingDetailsController.getAllRegularRoute(acc.id);
        test.stopTest();
    }
    testMethod static void getRegularRouteDataTest(){
       Regular_Routing__c acc = [Select id from Regular_Routing__c limit 1];
        test.startTest();
        BAFCOLRoutingDetailsController.getRegularRouteData(acc.id);
        test.stopTest();
    }
    testMethod static void getExchangeRateTest(){
        test.startTest();
        BAFCOLRoutingDetailsController.getExchangeRate();
        test.stopTest();
    }
    testMethod static void createRateProcumentTest(){
        Port__c portObj = [Select id,name from Port__c limit 1];
        Enquiry__c enquiryId = [Select id from Enquiry__c limit 1];
        Route__c roue = [Select id from Route__c limit 1];
        Agent__c agent = [Select id from Agent__c limit 1];
        Shipping_Line__c shipLine = [Select id from Shipping_Line__c limit 1];
         test.startTest();
        BAFCOLRoutingDetailsController.createRateProcument(portObj.name, 'commodity', shipLine.id, portObj.name, 1, enquiryId.id, roue.id, agent.id);
        test.stopTest();
    }
}