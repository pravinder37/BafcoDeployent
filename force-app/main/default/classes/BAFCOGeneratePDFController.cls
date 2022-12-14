public without sharing class BAFCOGeneratePDFController {
    public Boolean showShippLine {get;set;}
    public Boolean showPickupPlace {get;set;}
    public Boolean showPickupDischarge {get;set;}
    public Boolean showCharges {get;set;}
    public String recordId {get;set;}
    public BAFCOGeneratePDFDto dto {get;set;}
    public BAFCOGeneratePDFController(ApexPages.StandardController controller){
       /* Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        String showShippLine = pageParameters.get('showShippLine');
        String showCharges = pageParameters.get('showCharges');
        String recordId = pageParameters.get('recordId');
        if(showShippLine == 'true') this.showShippLine = true; 
        else this.showShippLine = false;
        if(showCharges == 'true') this.showCharges = true; 
        else this.showCharges = false;
        this.recordId = recordId;*/
        this.recordId = 'a0K78000000VVkgEAG'; this.showShippLine = true;this.showCharges = true;
        dto =new BAFCOGeneratePDFDto();
    }
    public void getQuoteData(){
        system.debug(' recordid '+this.recordId);
        Boolean has40HCEquip = false;
        if(this.recordId != null ){
            Quotation__c quoteObj = [Select Exclusions__c,Remarks__c,Account__r.Name,Name,(Select Route__r.Service_Type__c,Route__r.INCO_Term__r.name from Quotation_Items__r),createdDate,CreatedBy.Name,Quotation_Validity__c from Quotation__c where id =: this.recordId];
            this.dto.quoteNumber = quoteObj.Name;
            this.dto.validityTo = String.valueOf(Date.valueOf(quoteObj.Quotation_Validity__c));
            this.dto.customerName = quoteObj.Account__r.Name;
            this.dto.quoteIssued = quoteObj.createdDate.day()+'-'+ BAFCOLeadDetailsController.getMonthName(quoteObj.createdDate.month()) +'-'+quoteObj.createdDate.year();
            this.dto.preparedBy = quoteObj.CreatedBy.Name;
            this.dto.salesResponsible=quoteObj.CreatedBy.Name;
            //this.dto.exclusion =quoteObj.Exclusions__c != null ? quoteObj.Exclusions__c.split('.') : null; 
            this.dto.remarks = quoteObj.Remarks__c != null ? quoteObj.Remarks__c : null;
            this.dto.effectiveFrom = quoteObj.createdDate.day()+'-'+ BAFCOLeadDetailsController.getMonthName(quoteObj.createdDate.month()) +'-'+quoteObj.createdDate.year();
            if(quoteObj.Quotation_Items__r.size() > 0){
                this.dto.serviceType = quoteObj.Quotation_Items__r[0].Route__r.Service_Type__c;
                this.dto.shippingTerm =quoteObj.Quotation_Items__r[0].Route__r.INCO_Term__r.name;
            }
            if(quoteObj.Account__c != null){
                List<Contact> contlist = [Select name,email,Phone,fax,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                          Account.BillingCountry from contact where AccountId = : quoteObj.Account__c order by createddate desc];
                if(contlist.size() >0){
                    Contact cont = contlist[0];
                    this.dto.contactPerson = cont.Name;
                    String Address = Account.BillingStreet != null ? String.valueOf(cont.Account.BillingStreet) :null;
                    Address += Account.BillingCity != null ? ', '+String.valueOf(cont.Account.BillingCity) :null;
                    Address += Account.BillingState != null ? ', '+String.valueOf(cont.Account.BillingState) :null;
                    Address += Account.BillingPostalCode != null ? ', '+String.valueOf(cont.Account.BillingPostalCode) :null;
                    Address += Account.BillingCountry != null ? ', '+String.valueOf(cont.Account.BillingCountry) :null;
                    this.dto.address = Address;
                    this.dto.phone = cont.Phone;
                    this.dto.email =cont.Email;
                }
            }
            List<Quotation_Item__c> quoteItem = [Select Ex_Works_Charge__c,Ex_Works_Charge_Name__r.name,Place_of_Discharge__r.Name,Place_of_Pickup__r.Name,Port_of_Discharge__r.name,Port_of_Loading__r.name,BAF__c,Bayan__c,Bayan_cancellation_charge__c,Bunker_surcharge__c,Cleaning_charges__c,
                                                 CMC__c,Container_movement_charges__c,Container_stripping__c,
                                                 Destination_Customs_Clearance__c,Destination_Loading_Charges__c,DTHC__c,EIC__c,Equipment_Type__c,
                                                 Fasah_fee__c,Free_time_certificate_charges__c,Fumigation__c,Inspection__c,Insurance_charges__c,
                                                 ISPS__c,Lift_on_Lift_off__c,Loading_Charges__c,Ministry_clearnce_charge_for_OOG_cargo__c,
                                                 Miscellaneous__c,MOT_fine_charges__c,Non_Palletized_Surcharge__c,Origin_Customs_clearance__c,
                                                 Origin_Loading_Charges__c,OTHC__c,Pest_control__c,Port_of_Discharge__c,Port_of_Loading__c,
                                                 Port_Shuttling__c,Re_palletization__c,Reefer_cntr_plug_in_charges__c,Reefer_PTI_charges__c,
                                                 Reefer_steam_wash__c,RMS__c,Route__c,Sea_Freight__c,Seal_Charges__c,Stuffing_Charges__c,
                                                 SweepingCleaning__c,Tabadul__c,Tarpauline_charge__c,Total_INCO__c,Total_SL__c,Truck_Head_charges__c,
                                                 Truck_idling_charges__c,Vessel_certificate_charges__c,Wrappingpacking_charges__c,Xray__c,Quotation__r.RecordtypeId,
                                                 Quotation__r.Leadc__c,Quotation__r.Opportunity__c,Quotation__r.Account__c,Total__c,Agent_Name__c,
                                                 Remarks_SL_Charges__c,Remarks_Origin_Charges__c,Remarks_Destination_Charges__c,Remarks_Additional_Charges__c,Total_Additional__c,War_Risk_Surcharge__c,VGM__c,Total_Dest__c,Pickup_Charges__c,Overweight_surcharge__c,Origin_Detention_Demurrage_Charges__c,Lashing_Charges__c,Operational_Recovery_Surcharge__c,Low_Sulphur_Surcharge__c,Inland_haulage__c,Inland_Handling_Fees__c,Inland_Fuel_Surcharge__c,Gate_pass_charges__c,Fuel_Surcharge__c,Fasah_Charges__c,Export_Service_Fees__c,DG_Surcharge__c,Carriage_Congestion_Surcharge__c,BL_Fees__c,Bayan_Charges__c,
                                                 Container_Lashing_Charges__c,DO_charges__c,LOLO_Charges__c,Carrier_Security_Fees__c,
                                                 Shipping_Line__c,Equipment_Type__r.Name,Place_of_Pickup__c,Place_of_Discharge__c   
                                                 from Quotation_Item__c 
                                                 where Quotation__c =: this.recordId];
            if(quoteItem.size()>0){
                Map<string,Quotation_Item__c> shipLineToitem = new Map<string,Quotation_Item__c>();
                List<BAFCOGeneratePDFDto.serviceChargeList> quoteItemDto = new List<BAFCOGeneratePDFDto.serviceChargeList>();
                for(Quotation_Item__c item  : quoteItem){
                    if(item.Equipment_Type__r.Name == '20DC'){
                        shipLineToitem.put(item.Shipping_Line__c,item);
                    }
                }
                for(Quotation_Item__c item  : quoteItem){
                    if(item.Equipment_Type__r.Name != '20DC'){
                        BAFCOGeneratePDFDto.serviceChargeList itemDto = new BAFCOGeneratePDFDto.serviceChargeList();
                        itemDto.shippingLine = item.Shipping_Line__c ;
                        itemDto.transitTime = '** (Not Mapped) **';
                        itemDto.placeOfPickup = item.Place_of_Pickup__c != null ? item.Place_of_Pickup__r.Name : null;
                        itemDto.placeOfDischarge = item.Place_of_Discharge__c != null ? item.Place_of_Discharge__r.Name : null;
                        itemDto.portOfLoading = item.Port_of_Loading__r.name;
                        itemDto.portOfDestination = item.Port_of_Discharge__r.name;
                        if(item.Equipment_Type__r.Name == '40HC'){
                            has40HCEquip = true;
                            if(shipLineToitem.size() > 0 && shipLineToitem.containskey(item.Shipping_Line__c)){
                                Quotation_Item__c dcQuoteItem = shipLineToitem.get(item.Shipping_Line__c);
                                itemDto.equipmentType = item.Equipment_Type__r.name+' - '+ '20DC';
                            }
                            else{
                                itemDto.equipmentType = item.Equipment_Type__r.name;
                            }
                        }else{
                            itemDto.equipmentType = item.Equipment_Type__r.name;
                        }
                        //ServiceCharges
                        BAFCOImportRMSDto.servichargesObj serviceChargeObj = new BAFCOImportRMSDto.servichargesObj();
                        serviceChargeObj.BAF = item.BAF__c > 0 ? item.BAF__c : null;
                        serviceChargeObj.bunkerCharges = item.Bunker_surcharge__c > 0 ? item.Bunker_surcharge__c : null;
                        serviceChargeObj.cleaningCharges = item.Cleaning_charges__c > 0 ? item.Cleaning_charges__c : null;
                        serviceChargeObj.CMC = item.CMC__c > 0 ? item.CMC__c : null;
                        serviceChargeObj.carriageCongestionSurcharge = item.Carriage_Congestion_Surcharge__c > 0 ? item.Carriage_Congestion_Surcharge__c : null;
                        serviceChargeObj.carrierSecurityFees = item.Carrier_Security_Fees__c > 0 ? item.Carrier_Security_Fees__c : null;
                        serviceChargeObj.dgSurcharge = item.DG_Surcharge__c > 0 ? item.DG_Surcharge__c : null;
                        serviceChargeObj.DTHC = item.DTHC__c > 0 ? item.DTHC__c : null;
                        serviceChargeObj.equipmentImbalance = item.EIC__c > 0 ? item.EIC__c : null;
                        serviceChargeObj.inlandFuelCharges = item.Inland_Fuel_Surcharge__c > 0 ? item.Inland_Fuel_Surcharge__c : null;
                        serviceChargeObj.inlandHandlingfees = item.Inland_Handling_Fees__c > 0 ? item.Inland_Handling_Fees__c : null;
                        serviceChargeObj.inlandHaulage = item.Inland_haulage__c > 0 ? item.Inland_haulage__c : null;
                        serviceChargeObj.ISPS = item.ISPS__c > 0 ? item.ISPS__c : null;
                        serviceChargeObj.lowerSulphurSurcharge = item.Low_Sulphur_Surcharge__c > 0 ? item.Low_Sulphur_Surcharge__c : null;
                        serviceChargeObj.operationalRecovery = item.Operational_Recovery_Surcharge__c > 0 ? item.Operational_Recovery_Surcharge__c : null;
                        serviceChargeObj.OTHC = item.OTHC__c > 0 ? item.OTHC__c : null;
                        serviceChargeObj.overWeightCharge = item.Overweight_surcharge__c > 0 ? item.Overweight_surcharge__c : null;
                        serviceChargeObj.sealCharges = item.Seal_Charges__c > 0 ? item.Seal_Charges__c : null;
                        serviceChargeObj.warRiskSurcharges = item.War_Risk_Surcharge__c > 0 ? item.War_Risk_Surcharge__c : null;
                        serviceChargeObj.totalSl = item.Total_SL__c > 0 ? item.Total_SL__c : null;
                        itemDto.servichargesObj = serviceChargeObj;
                        
                        // origin Charges 
                        BAFCOImportRMSDto.originChargesObj orgnChargeObj = new BAFCOImportRMSDto.originChargesObj();
                        orgnChargeObj.bayan = item.Bayan__c > 0 ? item.Bayan__c : null; 
                        orgnChargeObj.blFees = item.BL_Fees__c > 0 ? item.BL_Fees__c : null; 
                        orgnChargeObj.originCustomClearance = item.Origin_Customs_clearance__c > 0 ? item.Origin_Customs_clearance__c : null; 
                        orgnChargeObj.exportServiceFees = item.Export_Service_Fees__c > 0 ? item.Export_Service_Fees__c : null; 
                        orgnChargeObj.fasahFees = item.Fasah_fee__c > 0 ? item.Fasah_fee__c : null; 
                        orgnChargeObj.inspection = item.Inspection__c > 0 ? item.Inspection__c : null; 
                        orgnChargeObj.insuranceCharges = item.Insurance_charges__c > 0 ? item.Insurance_charges__c : null; 
                        orgnChargeObj.liftOnLiftOff = item.Lift_on_Lift_off__c > 0 ? item.Lift_on_Lift_off__c : null; 
                        orgnChargeObj.OriginDetention = item.Origin_Detention_Demurrage_Charges__c > 0 ? item.Origin_Detention_Demurrage_Charges__c : null; 
                        orgnChargeObj.OriginLoadingCharges = item.Origin_Loading_Charges__c > 0 ? item.Origin_Loading_Charges__c : null; 
                        orgnChargeObj.pickUpCharges = item.Pickup_Charges__c > 0 ? item.Pickup_Charges__c : null; 
                        orgnChargeObj.ReeferControlPlugInCharge = item.Reefer_cntr_plug_in_charges__c > 0 ? item.Reefer_cntr_plug_in_charges__c : null; 
                        orgnChargeObj.tabadul = item.Tabadul__c > 0 ? item.Tabadul__c : null; 
                        orgnChargeObj.trapulinCharges = item.Tarpauline_charge__c > 0 ? item.Tarpauline_charge__c : null; 
                        orgnChargeObj.truckIdlingCharges = item.Truck_idling_charges__c > 0 ? item.Truck_idling_charges__c : null;
                        orgnChargeObj.vgm = item.VGM__c > 0 ? item.VGM__c : null; 
                        orgnChargeObj.xray = item.Xray__c > 0 ? item.Xray__c : null; 
                        orgnChargeObj.lashingCharges = item.Lashing_Charges__c > 0 ? item.Lashing_Charges__c : null; 
                        orgnChargeObj.fuelSurcharge = item.Fuel_Surcharge__c > 0 ? item.Fuel_Surcharge__c : null; 
                        orgnChargeObj.TotalOrigincharges = item.Total_INCO__c > 0 ? item.Total_INCO__c : null; 
                        itemDto.originChargesObj = orgnChargeObj;
                        
                        //Destination Charges 
                        BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                        destinObj.destinBayanCharges = item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null ;        
                        destinObj.destinCustomClearanceCharges = item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null ;        
                        destinObj.destinDOCharges = item.DO_charges__c > 0 ? item.DO_charges__c : null ;  
                        destinObj.destinFasahCharges = item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null ;        
                        destinObj.destinGatePassCharges = item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null ;        
                        destinObj.destinLOLOCharges = item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null ;        
                        //destinObj.destinTransPortationCharges = item. > 0 ? item.XXX : null ;        
                        destinObj.destinTotalCharges = item.Total_Dest__c > 0 ? item.Total_Dest__c : null ;
                        itemDto.destinChargeObj = destinObj;
                        
                        //Additional Charges
                        BAFCOImportRMSDto.additionalChargesObj addnObj = new BAFCOImportRMSDto.additionalChargesObj();
                        addnObj.Bayancancellationcharge = item.Bayan_cancellation_charge__c > 0 ? item.Bayan_cancellation_charge__c : null;
                        addnObj.Cleaningcharges = item.Cleaning_charges__c > 0 ? item.Cleaning_charges__c : null;
                        addnObj.ContainerLashingCharges = item.Container_Lashing_Charges__c > 0 ? item.Container_Lashing_Charges__c : null;
                        addnObj.Containermovementcharges = item.Container_movement_charges__c > 0 ? item.Container_movement_charges__c : null;
                        addnObj.Containerstripping = item.Container_stripping__c > 0 ? item.Container_stripping__c : null;
                        addnObj.Freetimecertificatecharges = item.Free_time_certificate_charges__c > 0 ? item.Free_time_certificate_charges__c : null;
                        addnObj.Fumigation = item.Fumigation__c > 0 ? item.Fumigation__c : null;
                        addnObj.Inspection = item.Inspection__c > 0 ? item.Inspection__c : null;
                        addnObj.Insurancecharges = item.Insurance_charges__c > 0 ? item.Insurance_charges__c : null;
                        addnObj.MinistryclearncechargeforOOGcargo = item.Ministry_clearnce_charge_for_OOG_cargo__c > 0 ? item.Ministry_clearnce_charge_for_OOG_cargo__c : null;
                        addnObj.Miscellaneous = item.Miscellaneous__c > 0 ? item.Miscellaneous__c : null;
                        addnObj.MOTfinecharges = item.MOT_fine_charges__c > 0 ? item.MOT_fine_charges__c : null;
                        addnObj.NonPalletizedSurcharge = item.Non_Palletized_Surcharge__c > 0 ? item.Non_Palletized_Surcharge__c : null;
                        addnObj.Pestcontrol = item.Pest_control__c > 0 ? item.Pest_control__c : null;
                        addnObj.Repalletization = item.Re_palletization__c > 0 ? item.Re_palletization__c : null;
                        addnObj.Reefercntrplugincharges = item.Reefer_cntr_plug_in_charges__c > 0 ? item.Reefer_cntr_plug_in_charges__c : null;
                        addnObj.ReeferPTIcharges = item.Reefer_PTI_charges__c > 0 ? item.Reefer_PTI_charges__c : null;
                        addnObj.Reefersteamwash = item.Reefer_steam_wash__c > 0 ? item.Reefer_steam_wash__c : null;
                        addnObj.StuffingCharges = item.Stuffing_Charges__c > 0 ? item.Stuffing_Charges__c : null;
                        addnObj.SweepingCleaning = item.SweepingCleaning__c > 0 ? item.SweepingCleaning__c : null;
                        addnObj.TruckHeadcharges = item.Truck_Head_charges__c > 0 ? item.Truck_Head_charges__c : null;
                        addnObj.Truckidlingcharges = item.Truck_idling_charges__c > 0 ? item.Truck_idling_charges__c : null;
                        addnObj.Vesselcertificatecharges = item.Vessel_certificate_charges__c > 0 ? item.Vessel_certificate_charges__c : null;
                        addnObj.Wrappingpackingcharges = item.Wrappingpacking_charges__c > 0 ? item.Wrappingpacking_charges__c : null;
                        addnObj.totalAdditional = item.Total_Additional__c > 0 ? item.Total_Additional__c : null;
                        itemDto.additionalChargesObj = addnObj;
                        
                        //ExWorks Charges
                        BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                        xWorksObj.LoadCharge = item.Ex_Works_Charge__c  > 0 ?  item.Ex_Works_Charge__c : null ;
                        xWorksObj.Id = item.Ex_Works_Charge_Name__c != null ? item.Ex_Works_Charge_Name__r.name : null;
                        itemDto.exWorksObj = xWorksObj;
                        system.debug('xWorksObj.LoadCharge '+xWorksObj.LoadCharge);
                        quoteItemDto.add(itemDto);
                    }
                }
                if(has40HCEquip == false){
                    for(Quotation_Item__c item  : quoteItem){
                        if(item.Equipment_Type__r.Name == '20DC'){
                            BAFCOGeneratePDFDto.serviceChargeList itemDto = new BAFCOGeneratePDFDto.serviceChargeList();
                            itemDto.shippingLine = item.Shipping_Line__c ;
                            itemDto.transitTime = '** (Not Mapped) **';
                            itemDto.placeOfPickup = item.Place_of_Pickup__c != null ? item.Place_of_Pickup__r.Name : null;
                            itemDto.placeOfDischarge = item.Place_of_Discharge__c != null ? item.Place_of_Discharge__r.Name : null;
                            itemDto.portOfLoading = item.Port_of_Loading__r.name;
                            itemDto.portOfDestination = item.Port_of_Discharge__r.name;
                            
                            itemDto.equipmentType = item.Equipment_Type__r.name;
                            //ServiceCharges
                            BAFCOImportRMSDto.servichargesObj serviceChargeObj = new BAFCOImportRMSDto.servichargesObj();
                            serviceChargeObj.BAF = item.BAF__c > 0 ? item.BAF__c : null;
                            serviceChargeObj.bunkerCharges = item.Bunker_surcharge__c > 0 ? item.Bunker_surcharge__c : null;
                            serviceChargeObj.cleaningCharges = item.Cleaning_charges__c > 0 ? item.Cleaning_charges__c : null;
                            serviceChargeObj.CMC = item.CMC__c > 0 ? item.CMC__c : null;
                            serviceChargeObj.carriageCongestionSurcharge = item.Carriage_Congestion_Surcharge__c > 0 ? item.Carriage_Congestion_Surcharge__c : null;
                            serviceChargeObj.carrierSecurityFees = item.Carrier_Security_Fees__c > 0 ? item.Carrier_Security_Fees__c : null;
                            serviceChargeObj.dgSurcharge = item.DG_Surcharge__c > 0 ? item.DG_Surcharge__c : null;
                            serviceChargeObj.DTHC = item.DTHC__c > 0 ? item.DTHC__c : null;
                            serviceChargeObj.equipmentImbalance = item.EIC__c > 0 ? item.EIC__c : null;
                            serviceChargeObj.inlandFuelCharges = item.Inland_Fuel_Surcharge__c > 0 ? item.Inland_Fuel_Surcharge__c : null;
                            serviceChargeObj.inlandHandlingfees = item.Inland_Handling_Fees__c > 0 ? item.Inland_Handling_Fees__c : null;
                            serviceChargeObj.inlandHaulage = item.Inland_haulage__c > 0 ? item.Inland_haulage__c : null;
                            serviceChargeObj.ISPS = item.ISPS__c > 0 ? item.ISPS__c : null;
                            serviceChargeObj.lowerSulphurSurcharge = item.Low_Sulphur_Surcharge__c > 0 ? item.Low_Sulphur_Surcharge__c : null;
                            serviceChargeObj.operationalRecovery = item.Operational_Recovery_Surcharge__c > 0 ? item.Operational_Recovery_Surcharge__c : null;
                            serviceChargeObj.OTHC = item.OTHC__c > 0 ? item.OTHC__c : null;
                            serviceChargeObj.overWeightCharge = item.Overweight_surcharge__c > 0 ? item.Overweight_surcharge__c : null;
                            serviceChargeObj.sealCharges = item.Seal_Charges__c > 0 ? item.Seal_Charges__c : null;
                            serviceChargeObj.warRiskSurcharges = item.War_Risk_Surcharge__c > 0 ? item.War_Risk_Surcharge__c : null;
                            serviceChargeObj.totalSl = item.Total_SL__c > 0 ? item.Total_SL__c : null;
                            itemDto.servichargesObj = serviceChargeObj;
                            
                            // origin Charges 
                            BAFCOImportRMSDto.originChargesObj orgnChargeObj = new BAFCOImportRMSDto.originChargesObj();
                            orgnChargeObj.bayan = item.Bayan__c > 0 ? item.Bayan__c : null; 
                            orgnChargeObj.blFees = item.BL_Fees__c > 0 ? item.BL_Fees__c : null; 
                            orgnChargeObj.originCustomClearance = item.Origin_Customs_clearance__c > 0 ? item.Origin_Customs_clearance__c : null; 
                            orgnChargeObj.exportServiceFees = item.Export_Service_Fees__c > 0 ? item.Export_Service_Fees__c : null; 
                            orgnChargeObj.fasahFees = item.Fasah_fee__c > 0 ? item.Fasah_fee__c : null; 
                            orgnChargeObj.inspection = item.Inspection__c > 0 ? item.Inspection__c : null; 
                            orgnChargeObj.insuranceCharges = item.Insurance_charges__c > 0 ? item.Insurance_charges__c : null; 
                            orgnChargeObj.liftOnLiftOff = item.Lift_on_Lift_off__c > 0 ? item.Lift_on_Lift_off__c : null; 
                            orgnChargeObj.OriginDetention = item.Origin_Detention_Demurrage_Charges__c > 0 ? item.Origin_Detention_Demurrage_Charges__c : null; 
                            orgnChargeObj.OriginLoadingCharges = item.Origin_Loading_Charges__c > 0 ? item.Origin_Loading_Charges__c : null; 
                            orgnChargeObj.pickUpCharges = item.Pickup_Charges__c > 0 ? item.Pickup_Charges__c : null; 
                            orgnChargeObj.ReeferControlPlugInCharge = item.Reefer_cntr_plug_in_charges__c > 0 ? item.Reefer_cntr_plug_in_charges__c : null; 
                            orgnChargeObj.tabadul = item.Tabadul__c > 0 ? item.Tabadul__c : null; 
                            orgnChargeObj.trapulinCharges = item.Tarpauline_charge__c > 0 ? item.Tarpauline_charge__c : null; 
                            orgnChargeObj.truckIdlingCharges = item.Truck_idling_charges__c > 0 ? item.Truck_idling_charges__c : null;
                            orgnChargeObj.vgm = item.VGM__c > 0 ? item.VGM__c : null; 
                            orgnChargeObj.xray = item.Xray__c > 0 ? item.Xray__c : null; 
                            orgnChargeObj.lashingCharges = item.Lashing_Charges__c > 0 ? item.Lashing_Charges__c : null; 
                            orgnChargeObj.fuelSurcharge = item.Fuel_Surcharge__c > 0 ? item.Fuel_Surcharge__c : null; 
                            orgnChargeObj.TotalOrigincharges = item.Total_INCO__c > 0 ? item.Total_INCO__c : null; 
                            itemDto.originChargesObj = orgnChargeObj;
                            
                            //Destination Charges 
                            BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                            destinObj.destinBayanCharges = item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null ;        
                            destinObj.destinCustomClearanceCharges = item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null ;        
                            destinObj.destinDOCharges = item.DO_charges__c > 0 ? item.DO_charges__c : null ;  
                            destinObj.destinFasahCharges = item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null ;        
                            destinObj.destinGatePassCharges = item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null ;        
                            destinObj.destinLOLOCharges = item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null ;        
                            //destinObj.destinTransPortationCharges = item. > 0 ? item.XXX : null ;        
                            destinObj.destinTotalCharges = item.Total_Dest__c > 0 ? item.Total_Dest__c : null ;
                            itemDto.destinChargeObj = destinObj;
                            
                            //Additional Charges
                            BAFCOImportRMSDto.additionalChargesObj addnObj = new BAFCOImportRMSDto.additionalChargesObj();
                            addnObj.Bayancancellationcharge = item.Bayan_cancellation_charge__c > 0 ? item.Bayan_cancellation_charge__c : null;
                            addnObj.Cleaningcharges = item.Cleaning_charges__c > 0 ? item.Cleaning_charges__c : null;
                            addnObj.ContainerLashingCharges = item.Container_Lashing_Charges__c > 0 ? item.Container_Lashing_Charges__c : null;
                            addnObj.Containermovementcharges = item.Container_movement_charges__c > 0 ? item.Container_movement_charges__c : null;
                            addnObj.Containerstripping = item.Container_stripping__c > 0 ? item.Container_stripping__c : null;
                            addnObj.Freetimecertificatecharges = item.Free_time_certificate_charges__c > 0 ? item.Free_time_certificate_charges__c : null;
                            addnObj.Fumigation = item.Fumigation__c > 0 ? item.Fumigation__c : null;
                            addnObj.Inspection = item.Inspection__c > 0 ? item.Inspection__c : null;
                            addnObj.Insurancecharges = item.Insurance_charges__c > 0 ? item.Insurance_charges__c : null;
                            addnObj.MinistryclearncechargeforOOGcargo = item.Ministry_clearnce_charge_for_OOG_cargo__c > 0 ? item.Ministry_clearnce_charge_for_OOG_cargo__c : null;
                            addnObj.Miscellaneous = item.Miscellaneous__c > 0 ? item.Miscellaneous__c : null;
                            addnObj.MOTfinecharges = item.MOT_fine_charges__c > 0 ? item.MOT_fine_charges__c : null;
                            addnObj.NonPalletizedSurcharge = item.Non_Palletized_Surcharge__c > 0 ? item.Non_Palletized_Surcharge__c : null;
                            addnObj.Pestcontrol = item.Pest_control__c > 0 ? item.Pest_control__c : null;
                            addnObj.Repalletization = item.Re_palletization__c > 0 ? item.Re_palletization__c : null;
                            addnObj.Reefercntrplugincharges = item.Reefer_cntr_plug_in_charges__c > 0 ? item.Reefer_cntr_plug_in_charges__c : null;
                            addnObj.ReeferPTIcharges = item.Reefer_PTI_charges__c > 0 ? item.Reefer_PTI_charges__c : null;
                            addnObj.Reefersteamwash = item.Reefer_steam_wash__c > 0 ? item.Reefer_steam_wash__c : null;
                            addnObj.StuffingCharges = item.Stuffing_Charges__c > 0 ? item.Stuffing_Charges__c : null;
                            addnObj.SweepingCleaning = item.SweepingCleaning__c > 0 ? item.SweepingCleaning__c : null;
                            addnObj.TruckHeadcharges = item.Truck_Head_charges__c > 0 ? item.Truck_Head_charges__c : null;
                            addnObj.Truckidlingcharges = item.Truck_idling_charges__c > 0 ? item.Truck_idling_charges__c : null;
                            addnObj.Vesselcertificatecharges = item.Vessel_certificate_charges__c > 0 ? item.Vessel_certificate_charges__c : null;
                            addnObj.Wrappingpackingcharges = item.Wrappingpacking_charges__c > 0 ? item.Wrappingpacking_charges__c : null;
                            addnObj.totalAdditional = item.Total_Additional__c > 0 ? item.Total_Additional__c : null;
                            itemDto.additionalChargesObj = addnObj;
                            
                            //ExWorks Charges
                            BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                            xWorksObj.LoadCharge = item.Ex_Works_Charge__c  > 0 ?  item.Ex_Works_Charge__c : null ;
                            xWorksObj.Id = item.Ex_Works_Charge_Name__c != null ? item.Ex_Works_Charge_Name__r.name : null;
                            itemDto.exWorksObj = xWorksObj;
                            quoteItemDto.add(itemDto);
                        }
                    }
                }
                system.debug('quoteItemDto '+quoteItemDto);
                this.dto.serviceChargeList = quoteItemDto; 
            }
        }
    }
}