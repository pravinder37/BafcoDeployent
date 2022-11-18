@istest
public class QuotationItemTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Lead__c ld = new Lead__c();
        ld.Business_Type__c = 'Import';
        insert ld;
        
        Account acc = new Account();
        acc.name = 'test';
        acc.Branch__c = 'Jeddah';
        insert acc;
        Enquiry__c enq = new Enquiry__c();
        enq.Name = 'Test';
        enq.Lead__c = ld.id;
        insert enq;
        
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
        RMS__c rmsObj = new RMS__c();
        rmsObj.Name ='Test';
        rmsObj.Port_Of_Discharge__c = port.Id;
        rmsObj.Port_Of_Loading__c = port.Id;
        rmsObj.Commodity__c =comd.Id;
        rmsObj.Shipping_Line__c = shipLine.id;
        rmsObj.Equipment_Type__c = equip.id;
        rmsObj.Validity__c = System.today().addDays(5);
        rmsObj.Sea_Freight__c = 1000;
        insert rmsObj;
        
        Route__c route = new Route__c();
        route.Enquiry__c = enq.id;
        route.Port_of_Destination__c = port.id;
        route.Port_of_loading__c =port.id;
        route.Commodity__c = comd.id;
        insert route;
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
        quoteItem.Origin_Loading_Charges__c = 10;
        quoteItem.Bayan__c = 10;
        quoteItem.Destination_Customs_Clearance__c = 10;
        quoteItem.Destination_Loading_Charges__c = 10;
        quoteItem.Xray__c = 10;
        quoteItem.Total__c = 10;
        quoteItem.Tabadul__c = 10;
        quoteItem.Port_Shuttling__c = 10;
        quoteItem.Origin_Customs_clearance__c = 10;
        quoteItem.Loading_Charges__c = 10;
        quoteItem.Lift_on_Lift_off__c = 10;
        quoteItem.Inspection__c = 10;
        quoteItem.Fasah_fee__c = 10;
        quoteItem.Total_SL__c = 100;      
        quoteItem.Bayan_cancellation_charge__c = 10;
        quoteItem.Cleaning_charges__c =10;
        //quoteItem.Container_Lashing_Charges__c = 10;        
        quoteItem.Container_movement_charges__c = 10;        
        quoteItem.Container_stripping__c = 10;        
        quoteItem.Free_time_certificate_charges__c = 10;        
        quoteItem.Fumigation__c = 10;        
        quoteItem.Insurance_charges__c = 10;        
        quoteItem.Ministry_clearnce_charge_for_OOG_cargo__c = 10;        
        quoteItem.Miscellaneous__c = 10;        
        quoteItem.MOT_fine_charges__c = 10;        
        quoteItem.Non_Palletized_Surcharge__c = 10;        
        quoteItem.Pest_control__c = 10;        
        quoteItem.Re_palletization__c = 10;
        quoteItem.Reefer_cntr_plug_in_charges__c = 10;        
        quoteItem.Reefer_PTI_charges__c = 10;        
        quoteItem.Reefer_steam_wash__c = 10;        
        quoteItem.Stuffing_Charges__c = 10;        
        quoteItem.SweepingCleaning__c = 10;        
        quoteItem.Truck_Head_charges__c = 10;        
        quoteItem.Truck_idling_charges__c = 10;        
        quoteItem.Vessel_certificate_charges__c = 10;        
        quoteItem.Wrappingpacking_charges__c = 10;
        Insert quoteItem;
    }
    testmethod static void updateTriggerTest(){
        Quotation_Item__c quoteItem = [Select id from Quotation_Item__c limit 1];
        quoteItem.Bunker_surcharge__c = 10;
        quoteItem.CMC__c = 10;
        quoteItem.Carriage_Congestion_Surcharge__c = 10;
        quoteItem.Carrier_Security_Fees__c = 10;
        quoteItem.DG_Surcharge__c = 10;
        quoteItem.DTHC__c = 10;
        quoteItem.EIC__c = 10;
        quoteItem.Inland_Fuel_Surcharge__c = 10;
        quoteItem.Inland_Handling_Fees__c = 10;
        quoteItem.Inland_haulage__c = 10;
        quoteItem.BAF__c = 10;
        quoteItem.ISPS__c = 10;
        quoteItem.Low_Sulphur_Surcharge__c = 10;
        quoteItem.Operational_Recovery_Surcharge__c = 10;
        quoteItem.Overweight_surcharge__c = 10;
        quoteItem.Seal_Charges__c = 10;
        quoteItem.War_Risk_Surcharge__c = 10;
        quoteItem.BL_Fees__c = 10;
        quoteItem.Export_Service_Fees__c = 10;
        quoteItem.Fuel_Surcharge__c = 10;
        quoteItem.Lashing_Charges__c = 10;
        quoteItem.Origin_Detention_Demurrage_Charges__c = 10;
        quoteItem.Pickup_Charges__c = 10;
        quoteItem.Tarpauline_charge__c = 10;
        quoteItem.VGM__c = 10;
        quoteItem.Bayan_Charges__c = 10;
        quoteItem.DO_charges__c = 10;
        quoteItem.Fasah_Charges__c = 10;
        quoteItem.Gate_pass_charges__c = 10;
        quoteItem.LOLO_Charges__c = 10;
        quoteItem.OTHC__c = 10;
        update quoteItem;
        
    }
}