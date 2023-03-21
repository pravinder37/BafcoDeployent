public without sharing class BAFCOGeneratePDFController {
    public static final Id QUOTE_EXPORT_RECORDTYPE_Id = Schema.SObjectType.quotation__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id QUOTE_IMPORT_RECORDTYPE_Id = Schema.SObjectType.quotation__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    public Boolean showShippLine {get;set;}
    public Boolean showPickupPlace {get;set;}
    public Boolean showPickupDischarge {get;set;}
    public Boolean showCharges {get;set;}
    public Boolean isPhone {get;set;}
    public String recordId {get;set;}
    public Boolean isLCL {get;set;}
    
     public String subject { get; set; }
    public String loadingPortLabel { get; set; }
    public String destinationPortLabel { get; set; }
 public String body { get; set; }
 public String emailid{get; set;}
    
    public BAFCOGeneratePDFDto dto {get;set;}
    public BAFCOGeneratePDFController(ApexPages.StandardController controller){
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        String showShippLine = pageParameters.get('showShippLine');
        String showCharges = pageParameters.get('showCharges');
        String recordId = pageParameters.get('recordId');
        String device = pageParameters.get('device');
        if(showShippLine == 'true') this.showShippLine = true; 
        else this.showShippLine = false;
        if(showCharges == 'true') this.showCharges = true; 
        else this.showCharges = false;
        this.recordId = recordId;
        if(device == 'PHONE') this.isPhone = true;
        else this.isPhone = false;
        dto =new BAFCOGeneratePDFDto();
        System.debug('device '+device);
    }
    public void getQuoteData(){
        system.debug(' recordid '+this.recordId);
        Boolean has40HCEquip = false;
        Boolean DC20Added = false;
        if(this.recordId != null ){
            Quotation__c quoteObj = [Select isAir__c,isLCL__c,Recordtype.Name,Terms_and_Conditions__c,RecordtypeId,Effective_From__c,Payment_Terms__c,Inclusions__c,Exclusions__c,Remarks__c,Account__r.Name,Name,(Select Route__r.Service_Type__c,Route__r.INCO_Term__r.name from Quotation_Items__r),createdDate,CreatedBy.Name,Quotation_Validity__c from Quotation__c where id =: this.recordId];
            this.dto.quoteNumber = quoteObj.Name;
            if(quoteObj.Quotation_Validity__c != null )this.dto.validityTo = quoteObj.Quotation_Validity__c.day()+'-'+ BAFCOLeadDetailsController.getMonthName(quoteObj.Quotation_Validity__c.month()) +'-'+quoteObj.Quotation_Validity__c.year();
            this.dto.customerName = quoteObj.Account__r.Name;
            if(quoteObj.isLCL__c == true || quoteObj.isAir__c == true) this.isLCL = true;
            else this.isLCL = false;
            if(quoteObj.isAir__c == true){
                this.loadingPortLabel ='Airport of Loading :';
                this.destinationPortLabel = 'Airport of Destination :';
            }
            else{
                this.loadingPortLabel ='Port of Loading :';
                this.destinationPortLabel = 'Port of Destination :';
            }
            this.dto.quoteIssued = quoteObj.createdDate.day()+'-'+ BAFCOLeadDetailsController.getMonthName(quoteObj.createdDate.month()) +'-'+quoteObj.createdDate.year();
            this.dto.preparedBy = quoteObj.CreatedBy.Name;
            this.dto.paymentTerm = quoteObj.Payment_Terms__c;
            this.dto.recordTypeName = quoteObj.RecordType.Name;
            if(quoteObj.recordtypeId == QUOTE_EXPORT_RECORDTYPE_Id){
                List<String> inclusionList =quoteObj.Inclusions__c != null ? quoteObj.Inclusions__c.split(';;') : null; 
                if(inclusionList != null && inclusionList.size() > 0){
                    this.dto.inclusionHeader = inclusionList[0] != null ? inclusionList[0] : null;
                    if(inclusionList.size() >1){
                        this.dto.inclusionList = inclusionList[1].split(';');
                    }
                }
                List<String> exclusionList =quoteObj.Exclusions__c != null ? quoteObj.Exclusions__c.split(';;') : null; 
                if(exclusionList != null && exclusionList.size() > 0){
                    this.dto.exclusionHeader = exclusionList[0] != null ? exclusionList[0] : null;
                    if(exclusionList.size() >1){
                        this.dto.exclusionList = exclusionList[1].split(';');
                    }
                }
            }
            else if(quoteObj.recordtypeId == QUOTE_IMPORT_RECORDTYPE_Id){
                List<String> termsList =quoteObj.Terms_and_Conditions__c != null ? quoteObj.Terms_and_Conditions__c.split(';;') : null; 
                if(termsList != null && termsList.size() > 0){
                    this.dto.termsNConditionHeader = termsList[0] != null ? termsList[0] : null;
                    if(termsList.size() >1){
                        this.dto.termsNConditionList = termsList[1].split(';');
                    }
                }
            }
            this.dto.remarks = quoteObj.Remarks__c != null ? quoteObj.Remarks__c : null;
            if(quoteObj.Effective_From__c != null)
                this.dto.effectiveFrom = quoteObj.Effective_From__c.day()+'-'+ BAFCOLeadDetailsController.getMonthName(quoteObj.Effective_From__c.month()) +'-'+quoteObj.Effective_From__c.year();
            if(quoteObj.Quotation_Items__r.size() > 0){
                this.dto.serviceType = quoteObj.Quotation_Items__r[0].Route__r.Service_Type__c;
                this.dto.shippingTerm =quoteObj.Quotation_Items__r[0].Route__r.INCO_Term__r.name;
            }
            if(quoteObj.Account__c != null){
                Account acc = [Select id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry, Owner.name from Account where id =: quoteObj.Account__c];
                String Address = acc.BillingStreet != null ? String.valueOf(acc.BillingStreet) :'';
                Address += acc.BillingCity != null ? ', '+String.valueOf(acc.BillingCity) :'';
                Address += acc.BillingState != null ? ', '+String.valueOf(acc.BillingState) :'';
                Address += acc.BillingPostalCode != null ? ', '+String.valueOf(acc.BillingPostalCode) :'';
                Address += acc.BillingCountry != null ? ', '+String.valueOf(acc.BillingCountry) :'';
                this.dto.address = Address != '' ? Address : '-';
                this.dto.salesResponsible = acc.Owner.name;
                List<Contact> contlist = [Select name,email,Phone,fax,Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                          Account.BillingCountry from contact where AccountId = : quoteObj.Account__c order by createddate desc];
                if(contlist.size() >0){
                    Contact cont = contlist[0];
                    this.dto.contactPerson = cont.Name;                    
                    this.dto.phone = cont.Phone;
                    this.dto.email =cont.Email;
                }
                else{
                    this.dto.contactPerson = '-';
                    this.dto.phone = '-';
                    this.dto.email ='-';
                }
            }
            else{
                this.dto.contactPerson = '-';
                this.dto.address =  '-';
                this.dto.phone = '-';
                this.dto.email ='-';
            }
            List<Quotation_Item__c> quoteItem = [Select Airport_of_Loading__r.name,Airport_of_Destination__r.name,Quotation__r.isAir__c,Quotation__r.isLCL__c,Tab_View__c,Tank_Rental_Charges__c,Freight_Difference_FD__c,Carrier_container_repositioning_charges__c,Alternate_depot_release_charges__c,Included_PDF_ShippingLine__c,Included_PDF_Origin__c,Included_PDF_Ex_works__c,Included_PDF_Destination__c,Included_PDF_Additional__c,Route__r.Service_Type__c,Ex_Works_Charge__c,Ex_Works_Charge_Name__r.name,Place_of_Discharge__r.Name,Place_of_Pickup__r.Name,Port_of_Discharge__r.name,Port_of_Loading__r.name,BAF__c,Bayan__c,Bayan_cancellation_charge__c,Bunker_surcharge__c,Cleaning_charges__c,
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
                                                 Shipping_Line__c,Equipment_Type__r.Name,/*Place_of_Pickup__c,Place_of_Discharge__c*/Pickup_Place__c,Discharge_Place__c    
                                                 from Quotation_Item__c 
                                                 where Quotation__c =: this.recordId];
            if(quoteItem.size()>0){
                Map<string,Quotation_Item__c> shipLineToitem = new Map<string,Quotation_Item__c>();
                List<BAFCOGeneratePDFDto.serviceChargeList> quoteItemDto = new List<BAFCOGeneratePDFDto.serviceChargeList>();
                for(Quotation_Item__c item  : quoteItem){
                    if(item.Equipment_Type__r.Name == '20DC' && item.Quotation__r.isLCL__c != true && item.Quotation__r.isAir__c != true){
                        String UniqKey = item.Shipping_Line__c+'-'+item.Port_of_Loading__c+'-'+item.Port_of_Discharge__c;
                        shipLineToitem.put(UniqKey,item);
                    }
                }
                for(Quotation_Item__c item  : quoteItem){
                    if(item.Quotation__r.isLCL__c == true || item.Quotation__r.isAir__c == true){
                        BAFCOGeneratePDFDto.serviceChargeList itemDto = new BAFCOGeneratePDFDto.serviceChargeList();
                            itemDto.shippingLine = item.Shipping_Line__c ;
                            itemDto.transitTime = '** (Not Mapped) **';
                            itemDto.serviceType = item.Route__r.Service_Type__c;
                            //itemDto.placeOfPickup = item.Place_of_Pickup__c != null ? item.Place_of_Pickup__r.Name : null;
                            //itemDto.placeOfDischarge = item.Place_of_Discharge__c != null ? item.Place_of_Discharge__r.Name : null;
                            itemDto.placeOfPickup = item.Pickup_Place__c;
                        	itemDto.placeOfDischarge = item.Discharge_Place__c;
                            if(item.Quotation__r.isAir__c == true){
                                itemDto.portOfLoading = item.Airport_of_Loading__r.name;
                                itemDto.portOfDestination = item.Airport_of_Destination__r.name;
                            }
                            else{
                                itemDto.portOfLoading = item.Port_of_Loading__r.name;
                                itemDto.portOfDestination = item.Port_of_Discharge__r.name;
                            }
                            itemDto.total = item.Total__c;
                            itemDto.equipmentType = item.Tab_View__c;
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
                            serviceChargeObj.includeServiceCharge = item.Included_PDF_ShippingLine__c;
                            if(item.BAF__c > 0 || item.Bunker_surcharge__c  > 0 || 
                               item.Cleaning_charges__c > 0 || item.CMC__c > 0 || 
                               item.Carriage_Congestion_Surcharge__c > 0 || item.Carrier_Security_Fees__c > 0 || 
                               item.DG_Surcharge__c > 0 || item.DTHC__c > 0 || item.EIC__c > 0 || 
                               item.Inland_Fuel_Surcharge__c > 0 || item.Inland_Handling_Fees__c > 0 || 
                               item.Inland_haulage__c > 0 || item.ISPS__c > 0 || 
                               item.Low_Sulphur_Surcharge__c > 0 || item.Operational_Recovery_Surcharge__c > 0 || 
                               item.OTHC__c > 0 || item.Overweight_surcharge__c > 0 || item.Seal_Charges__c > 0 || 
                               item.War_Risk_Surcharge__c > 0 ){
                                   serviceChargeObj.shippTotalChanged = false;
                               }
                            else{
                                serviceChargeObj.shippTotalChanged = true;
                            }
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
                            orgnChargeObj.includeOriginCharge = item.Included_PDF_Origin__c;
                            if(item.Bayan__c > 0 || item.BL_Fees__c > 0 ||  
                               item.Origin_Customs_clearance__c > 0 ||   item.Export_Service_Fees__c > 0 ||   
                               item.Fasah_fee__c > 0 ||   item.Inspection__c > 0 ||  
                               item.Insurance_charges__c > 0 ||   item.Lift_on_Lift_off__c > 0 ||   
                               item.Origin_Detention_Demurrage_Charges__c > 0 ||  
                               item.Origin_Loading_Charges__c > 0 ||   item.Reefer_cntr_plug_in_charges__c > 0 || 
                               item.Tarpauline_charge__c > 0 ||   item.Truck_idling_charges__c > 0 ||   
                               item.Lashing_Charges__c > 0 ||   item.Fuel_Surcharge__c  > 0 ){
                                   orgnChargeObj.originTotalChanged = false;
                               }
                            else{
                                orgnChargeObj.originTotalChanged = true;
                            }
                            itemDto.originChargesObj = orgnChargeObj;
                            
                            //Destination Charges 
                            BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                            destinObj.destinBayanCharges = item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null ;        
                            destinObj.destinCustomClearanceCharges = item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null ;        
                            destinObj.destinDOCharges = item.DO_charges__c > 0 ? item.DO_charges__c : null ;  
                            destinObj.destinFasahCharges = item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null ;        
                            destinObj.destinGatePassCharges = item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null ;        
                            destinObj.destinLOLOCharges = item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null ;        
                            destinObj.includeDestinCharge = item.Included_PDF_Destination__c ;           
                            destinObj.destinTotalCharges = item.Total_Dest__c > 0 ? item.Total_Dest__c : null ;
                            if(item.Bayan_Charges__c > 0 ||  item.Destination_Customs_Clearance__c  > 0 ||  
                               item.DO_charges__c > 0 || item.Fasah_Charges__c  > 0 ||  
                               item.Gate_pass_charges__c  > 0 ||  item.LOLO_Charges__c > 0 ){
                                   destinObj.DestinTotalChanged = false;
                               }
                            else{
                                destinObj.DestinTotalChanged = true;
                            }
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
                            addnObj.includeAdditionalCharge =item.Included_PDF_Additional__c;
                            addnObj.AlternateDepotReleaseCharges = item.Alternate_depot_release_charges__c > 0 ? item.Alternate_depot_release_charges__c : null;
                        	addnObj.FreightDifference = item.Freight_Difference_FD__c > 0 ? item.Freight_Difference_FD__c : null;
                        	addnObj.CarrierContainerRepositioningCharges = item.Carrier_container_repositioning_charges__c > 0 ? item.Carrier_container_repositioning_charges__c : null;
                            addnObj.tankRentalCharge = item.Tank_Rental_Charges__c > 0 ? item.Tank_Rental_Charges__c : null;
                            itemDto.additionalChargesObj = addnObj;
                            
                            //ExWorks Charges
                            BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                            xWorksObj.LoadCharge = item.Ex_Works_Charge__c  > 0 ?  item.Ex_Works_Charge__c : null ;
                            xWorksObj.Id = item.Ex_Works_Charge_Name__c != null ? item.Ex_Works_Charge_Name__r.name : null;
                            xWorksObj.includeExWorksCharge = item.Included_PDF_Ex_works__c ;
                            itemDto.exWorksObj = xWorksObj;
                        quoteItemDto.add(itemDto);
                    }
                    else{
                    if(item.Equipment_Type__r.Name != '20DC'){
                        BAFCOGeneratePDFDto.serviceChargeList itemDto = new BAFCOGeneratePDFDto.serviceChargeList();
                        itemDto.shippingLine = item.Shipping_Line__c ;
                        itemDto.serviceType = item.Route__r.Service_Type__c;
                        itemDto.transitTime = '** (Not Mapped) **';
                        //itemDto.placeOfPickup = item.Place_of_Pickup__c != null ? item.Place_of_Pickup__r.Name : null;
                        //itemDto.placeOfDischarge = item.Place_of_Discharge__c != null ? item.Place_of_Discharge__r.Name : null;
                        itemDto.placeOfPickup = item.Pickup_Place__c;
                        itemDto.placeOfDischarge = item.Discharge_Place__c;
                        itemDto.portOfLoading = item.Port_of_Loading__r.name;
                        itemDto.portOfDestination = item.Port_of_Discharge__r.name;
                        itemDto.total = item.Total__c;
                        if(item.Equipment_Type__r.Name == '40HC'){
                            has40HCEquip = true;
                            String UniqKey = item.Shipping_Line__c+'-'+item.Port_of_Loading__c+'-'+item.Port_of_Discharge__c;
                            if(shipLineToitem.size() > 0 && shipLineToitem.containskey(UniqKey)){
                                Quotation_Item__c dcQuoteItem = shipLineToitem.get(UniqKey);
                                //itemDto.equipmentType = item.Equipment_Type__r.name+' - '+ '20DC';
                                itemDto.equipmentType = item.Equipment_Type__r.name;
                                DC20Added = true;
                                itemDto.ShowtotalDC = True;
                                itemDto.totalDC = dcQuoteItem.Total__c;
                                BAFCOGeneratePDFDto.DC20Charges dcObj = new BAFCOGeneratePDFDto.DC20Charges(); 
                                //**** 20 DC Charges ****//
                                BAFCOImportRMSDto.servichargesObj serviceChargeObj = new BAFCOImportRMSDto.servichargesObj();
                                serviceChargeObj.BAF = dcQuoteItem.BAF__c > 0 ? dcQuoteItem.BAF__c : null;
                                serviceChargeObj.bunkerCharges = dcQuoteItem.Bunker_surcharge__c > 0 ? dcQuoteItem.Bunker_surcharge__c : null;
                                serviceChargeObj.cleaningCharges = dcQuoteItem.Cleaning_charges__c > 0 ? dcQuoteItem.Cleaning_charges__c : null;
                                serviceChargeObj.CMC = dcQuoteItem.CMC__c > 0 ? dcQuoteItem.CMC__c : null;
                                serviceChargeObj.carriageCongestionSurcharge = dcQuoteItem.Carriage_Congestion_Surcharge__c > 0 ? dcQuoteItem.Carriage_Congestion_Surcharge__c : null;
                                serviceChargeObj.carrierSecurityFees = dcQuoteItem.Carrier_Security_Fees__c > 0 ? dcQuoteItem.Carrier_Security_Fees__c : null;
                                serviceChargeObj.dgSurcharge = dcQuoteItem.DG_Surcharge__c > 0 ? dcQuoteItem.DG_Surcharge__c : null;
                                serviceChargeObj.DTHC = dcQuoteItem.DTHC__c > 0 ? dcQuoteItem.DTHC__c : null;
                                serviceChargeObj.equipmentImbalance = dcQuoteItem.EIC__c > 0 ? dcQuoteItem.EIC__c : null;
                                serviceChargeObj.inlandFuelCharges = dcQuoteItem.Inland_Fuel_Surcharge__c > 0 ? dcQuoteItem.Inland_Fuel_Surcharge__c : null;
                                serviceChargeObj.inlandHandlingfees = dcQuoteItem.Inland_Handling_Fees__c > 0 ? dcQuoteItem.Inland_Handling_Fees__c : null;
                                serviceChargeObj.inlandHaulage = dcQuoteItem.Inland_haulage__c > 0 ? dcQuoteItem.Inland_haulage__c : null;
                                serviceChargeObj.ISPS = dcQuoteItem.ISPS__c > 0 ? dcQuoteItem.ISPS__c : null;
                                serviceChargeObj.lowerSulphurSurcharge = dcQuoteItem.Low_Sulphur_Surcharge__c > 0 ? dcQuoteItem.Low_Sulphur_Surcharge__c : null;
                                serviceChargeObj.operationalRecovery = dcQuoteItem.Operational_Recovery_Surcharge__c > 0 ? dcQuoteItem.Operational_Recovery_Surcharge__c : null;
                                serviceChargeObj.OTHC = dcQuoteItem.OTHC__c > 0 ? dcQuoteItem.OTHC__c : null;
                                serviceChargeObj.overWeightCharge = dcQuoteItem.Overweight_surcharge__c > 0 ? dcQuoteItem.Overweight_surcharge__c : null;
                                serviceChargeObj.sealCharges = dcQuoteItem.Seal_Charges__c > 0 ? dcQuoteItem.Seal_Charges__c : null;
                                serviceChargeObj.warRiskSurcharges = dcQuoteItem.War_Risk_Surcharge__c > 0 ? dcQuoteItem.War_Risk_Surcharge__c : null;
                                serviceChargeObj.totalSl = dcQuoteItem.Total_SL__c > 0 ? dcQuoteItem.Total_SL__c : null;
                                serviceChargeObj.includeServiceCharge = dcQuoteItem.Included_PDF_ShippingLine__c;
                                if(dcQuoteItem.BAF__c > 0 || dcQuoteItem.Bunker_surcharge__c  > 0 || 
                                   dcQuoteItem.Cleaning_charges__c > 0 || dcQuoteItem.CMC__c > 0 || 
                                   dcQuoteItem.Carriage_Congestion_Surcharge__c > 0 || dcQuoteItem.Carrier_Security_Fees__c > 0 || 
                                   dcQuoteItem.DG_Surcharge__c > 0 || dcQuoteItem.DTHC__c > 0 || dcQuoteItem.EIC__c > 0 || 
                                   dcQuoteItem.Inland_Fuel_Surcharge__c > 0 || dcQuoteItem.Inland_Handling_Fees__c > 0 || 
                                   dcQuoteItem.Inland_haulage__c > 0 || dcQuoteItem.ISPS__c > 0 || 
                                   dcQuoteItem.Low_Sulphur_Surcharge__c > 0 || dcQuoteItem.Operational_Recovery_Surcharge__c > 0 || 
                                   dcQuoteItem.OTHC__c > 0 || dcQuoteItem.Overweight_surcharge__c > 0 || dcQuoteItem.Seal_Charges__c > 0 || 
                                   dcQuoteItem.War_Risk_Surcharge__c > 0 ){
                                       serviceChargeObj.shippTotalChanged = false;
                                   }
                                else{
                                    serviceChargeObj.shippTotalChanged = true;
                                }
                                dcObj.servichargesObj = serviceChargeObj;
                                
                                // origin Charges 
                                BAFCOImportRMSDto.originChargesObj orgnChargeObj = new BAFCOImportRMSDto.originChargesObj();
                                orgnChargeObj.bayan = dcQuoteItem.Bayan__c > 0 ? dcQuoteItem.Bayan__c : null; 
                                orgnChargeObj.blFees = dcQuoteItem.BL_Fees__c > 0 ? dcQuoteItem.BL_Fees__c : null; 
                                orgnChargeObj.originCustomClearance = dcQuoteItem.Origin_Customs_clearance__c > 0 ? dcQuoteItem.Origin_Customs_clearance__c : null; 
                                orgnChargeObj.exportServiceFees = dcQuoteItem.Export_Service_Fees__c > 0 ? dcQuoteItem.Export_Service_Fees__c : null; 
                                orgnChargeObj.fasahFees = dcQuoteItem.Fasah_fee__c > 0 ? dcQuoteItem.Fasah_fee__c : null; 
                                orgnChargeObj.inspection = dcQuoteItem.Inspection__c > 0 ? dcQuoteItem.Inspection__c : null; 
                                orgnChargeObj.insuranceCharges = dcQuoteItem.Insurance_charges__c > 0 ? dcQuoteItem.Insurance_charges__c : null; 
                                orgnChargeObj.liftOnLiftOff = dcQuoteItem.Lift_on_Lift_off__c > 0 ? dcQuoteItem.Lift_on_Lift_off__c : null; 
                                orgnChargeObj.OriginDetention = dcQuoteItem.Origin_Detention_Demurrage_Charges__c > 0 ? dcQuoteItem.Origin_Detention_Demurrage_Charges__c : null; 
                                orgnChargeObj.OriginLoadingCharges = dcQuoteItem.Origin_Loading_Charges__c > 0 ? dcQuoteItem.Origin_Loading_Charges__c : null; 
                                orgnChargeObj.pickUpCharges = dcQuoteItem.Pickup_Charges__c > 0 ? dcQuoteItem.Pickup_Charges__c : null; 
                                orgnChargeObj.ReeferControlPlugInCharge = dcQuoteItem.Reefer_cntr_plug_in_charges__c > 0 ? dcQuoteItem.Reefer_cntr_plug_in_charges__c : null; 
                                orgnChargeObj.tabadul = dcQuoteItem.Tabadul__c > 0 ? dcQuoteItem.Tabadul__c : null; 
                                orgnChargeObj.trapulinCharges = dcQuoteItem.Tarpauline_charge__c > 0 ? dcQuoteItem.Tarpauline_charge__c : null; 
                                orgnChargeObj.truckIdlingCharges = dcQuoteItem.Truck_idling_charges__c > 0 ? dcQuoteItem.Truck_idling_charges__c : null;
                                orgnChargeObj.vgm = dcQuoteItem.VGM__c > 0 ? dcQuoteItem.VGM__c : null; 
                                orgnChargeObj.xray = dcQuoteItem.Xray__c > 0 ? dcQuoteItem.Xray__c : null; 
                                orgnChargeObj.lashingCharges = dcQuoteItem.Lashing_Charges__c > 0 ? dcQuoteItem.Lashing_Charges__c : null; 
                                orgnChargeObj.fuelSurcharge = dcQuoteItem.Fuel_Surcharge__c > 0 ? dcQuoteItem.Fuel_Surcharge__c : null; 
                                orgnChargeObj.TotalOrigincharges = dcQuoteItem.Total_INCO__c > 0 ? dcQuoteItem.Total_INCO__c : null; 
                                orgnChargeObj.includeOriginCharge = dcQuoteItem.Included_PDF_Origin__c;
                                if(dcQuoteItem.Bayan__c > 0 || dcQuoteItem.BL_Fees__c > 0 ||  
                                   dcQuoteItem.Origin_Customs_clearance__c > 0 ||   dcQuoteItem.Export_Service_Fees__c > 0 ||   
                                   dcQuoteItem.Fasah_fee__c > 0 ||   dcQuoteItem.Inspection__c > 0 ||  
                                   dcQuoteItem.Insurance_charges__c > 0 ||   dcQuoteItem.Lift_on_Lift_off__c > 0 ||   
                                   dcQuoteItem.Origin_Detention_Demurrage_Charges__c > 0 ||  
                                   dcQuoteItem.Origin_Loading_Charges__c > 0 ||   dcQuoteItem.Reefer_cntr_plug_in_charges__c > 0 || 
                                   dcQuoteItem.Tarpauline_charge__c > 0 ||   dcQuoteItem.Truck_idling_charges__c > 0 ||   
                                   dcQuoteItem.Lashing_Charges__c > 0 ||   dcQuoteItem.Fuel_Surcharge__c  > 0 ){
                                       orgnChargeObj.originTotalChanged = false;
                                   }
                                else{
                                    orgnChargeObj.originTotalChanged = true;
                                }
                                dcObj.originChargesObj = orgnChargeObj;
                                
                                //Destination Charges 
                                BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                                destinObj.destinBayanCharges = dcQuoteItem.Bayan_Charges__c > 0 ? dcQuoteItem.Bayan_Charges__c : null ;        
                                destinObj.destinCustomClearanceCharges = dcQuoteItem.Destination_Customs_Clearance__c > 0 ? dcQuoteItem.Destination_Customs_Clearance__c : null ;        
                                destinObj.destinDOCharges = dcQuoteItem.DO_charges__c > 0 ? dcQuoteItem.DO_charges__c : null ;  
                                destinObj.destinFasahCharges = dcQuoteItem.Fasah_Charges__c > 0 ? dcQuoteItem.Fasah_Charges__c : null ;        
                                destinObj.destinGatePassCharges = dcQuoteItem.Gate_pass_charges__c > 0 ? dcQuoteItem.Gate_pass_charges__c : null ;        
                                destinObj.destinLOLOCharges = dcQuoteItem.LOLO_Charges__c > 0 ? dcQuoteItem.LOLO_Charges__c : null ;        
                                destinObj.destinTotalCharges = dcQuoteItem.Total_Dest__c > 0 ? dcQuoteItem.Total_Dest__c : null ;
                                destinObj.includeDestinCharge = dcQuoteItem.Included_PDF_Destination__c ;
                                if(dcQuoteItem.Bayan_Charges__c > 0 ||  dcQuoteItem.Destination_Customs_Clearance__c  > 0 ||  
                                   dcQuoteItem.DO_charges__c > 0 || dcQuoteItem.Fasah_Charges__c  > 0 ||  
                                   dcQuoteItem.Gate_pass_charges__c  > 0 ||  dcQuoteItem.LOLO_Charges__c > 0 ){
                                       destinObj.DestinTotalChanged = false;
                                   }
                                else{
                                    destinObj.DestinTotalChanged = true;
                                }
                                dcObj.destinChargeObj = destinObj;
                                
                                //Additional Charges
                                BAFCOImportRMSDto.additionalChargesObj addnObj = new BAFCOImportRMSDto.additionalChargesObj();
                                addnObj.Bayancancellationcharge = dcQuoteItem.Bayan_cancellation_charge__c > 0 ? dcQuoteItem.Bayan_cancellation_charge__c : null;
                                addnObj.Cleaningcharges = dcQuoteItem.Cleaning_charges__c > 0 ? dcQuoteItem.Cleaning_charges__c : null;
                                addnObj.ContainerLashingCharges = dcQuoteItem.Container_Lashing_Charges__c > 0 ? dcQuoteItem.Container_Lashing_Charges__c : null;
                                addnObj.Containermovementcharges = dcQuoteItem.Container_movement_charges__c > 0 ? dcQuoteItem.Container_movement_charges__c : null;
                                addnObj.Containerstripping = dcQuoteItem.Container_stripping__c > 0 ? dcQuoteItem.Container_stripping__c : null;
                                addnObj.Freetimecertificatecharges = dcQuoteItem.Free_time_certificate_charges__c > 0 ? dcQuoteItem.Free_time_certificate_charges__c : null;
                                addnObj.Fumigation = dcQuoteItem.Fumigation__c > 0 ? dcQuoteItem.Fumigation__c : null;
                                addnObj.Inspection = dcQuoteItem.Inspection__c > 0 ? dcQuoteItem.Inspection__c : null;
                                addnObj.Insurancecharges = dcQuoteItem.Insurance_charges__c > 0 ? dcQuoteItem.Insurance_charges__c : null;
                                addnObj.MinistryclearncechargeforOOGcargo = dcQuoteItem.Ministry_clearnce_charge_for_OOG_cargo__c > 0 ? dcQuoteItem.Ministry_clearnce_charge_for_OOG_cargo__c : null;
                                addnObj.Miscellaneous = dcQuoteItem.Miscellaneous__c > 0 ? dcQuoteItem.Miscellaneous__c : null;
                                addnObj.MOTfinecharges = dcQuoteItem.MOT_fine_charges__c > 0 ? dcQuoteItem.MOT_fine_charges__c : null;
                                addnObj.NonPalletizedSurcharge = dcQuoteItem.Non_Palletized_Surcharge__c > 0 ? dcQuoteItem.Non_Palletized_Surcharge__c : null;
                                addnObj.Pestcontrol = dcQuoteItem.Pest_control__c > 0 ? dcQuoteItem.Pest_control__c : null;
                                addnObj.Repalletization = dcQuoteItem.Re_palletization__c > 0 ? dcQuoteItem.Re_palletization__c : null;
                                addnObj.Reefercntrplugincharges = dcQuoteItem.Reefer_cntr_plug_in_charges__c > 0 ? dcQuoteItem.Reefer_cntr_plug_in_charges__c : null;
                                addnObj.ReeferPTIcharges = dcQuoteItem.Reefer_PTI_charges__c > 0 ? dcQuoteItem.Reefer_PTI_charges__c : null;
                                addnObj.Reefersteamwash = dcQuoteItem.Reefer_steam_wash__c > 0 ? dcQuoteItem.Reefer_steam_wash__c : null;
                                addnObj.StuffingCharges = dcQuoteItem.Stuffing_Charges__c > 0 ? dcQuoteItem.Stuffing_Charges__c : null;
                                addnObj.SweepingCleaning = dcQuoteItem.SweepingCleaning__c > 0 ? dcQuoteItem.SweepingCleaning__c : null;
                                addnObj.TruckHeadcharges = dcQuoteItem.Truck_Head_charges__c > 0 ? dcQuoteItem.Truck_Head_charges__c : null;
                                addnObj.Truckidlingcharges = dcQuoteItem.Truck_idling_charges__c > 0 ? dcQuoteItem.Truck_idling_charges__c : null;
                                addnObj.Vesselcertificatecharges = dcQuoteItem.Vessel_certificate_charges__c > 0 ? dcQuoteItem.Vessel_certificate_charges__c : null;
                                addnObj.Wrappingpackingcharges = dcQuoteItem.Wrappingpacking_charges__c > 0 ? dcQuoteItem.Wrappingpacking_charges__c : null;
                                addnObj.totalAdditional = dcQuoteItem.Total_Additional__c > 0 ? dcQuoteItem.Total_Additional__c : null;
                                addnObj.includeAdditionalCharge = dcQuoteItem.Included_PDF_Additional__c;
                                addnObj.AlternateDepotReleaseCharges = dcQuoteItem.Alternate_depot_release_charges__c > 0 ? dcQuoteItem.Alternate_depot_release_charges__c : null;
                                addnObj.FreightDifference = dcQuoteItem.Freight_Difference_FD__c > 0 ? dcQuoteItem.Freight_Difference_FD__c : null;
                                addnObj.CarrierContainerRepositioningCharges = dcQuoteItem.Carrier_container_repositioning_charges__c > 0 ? dcQuoteItem.Carrier_container_repositioning_charges__c : null;
                                addnObj.tankRentalCharge = dcQuoteItem.Tank_Rental_Charges__c > 0 ? dcQuoteItem.Tank_Rental_Charges__c : null;
                                
                                dcObj.additionalChargesObj = addnObj;
                                
                                //ExWorks Charges
                                BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                                xWorksObj.LoadCharge = dcQuoteItem.Ex_Works_Charge__c  > 0 ?  dcQuoteItem.Ex_Works_Charge__c : null ;
                                xWorksObj.Id = dcQuoteItem.Ex_Works_Charge_Name__c != null ? dcQuoteItem.Ex_Works_Charge_Name__r.name : null;
                                xWorksObj.includeExWorksCharge = dcQuoteItem.Included_PDF_Ex_works__c ;
                                dcObj.exWorksObj = xWorksObj;
                                //////*** 20 DC charges End***//////
                                itemDto.dc20Charges = dcObj;
                                
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
                        serviceChargeObj.includeServiceCharge = item.Included_PDF_ShippingLine__c;
                        if(item.BAF__c > 0 || item.Bunker_surcharge__c  > 0 || 
                           item.Cleaning_charges__c > 0 || item.CMC__c > 0 || 
                           item.Carriage_Congestion_Surcharge__c > 0 || item.Carrier_Security_Fees__c > 0 || 
                           item.DG_Surcharge__c > 0 || item.DTHC__c > 0 || item.EIC__c > 0 || 
                           item.Inland_Fuel_Surcharge__c > 0 || item.Inland_Handling_Fees__c > 0 || 
                           item.Inland_haulage__c > 0 || item.ISPS__c > 0 || 
                           item.Low_Sulphur_Surcharge__c > 0 || item.Operational_Recovery_Surcharge__c > 0 || 
                           item.OTHC__c > 0 || item.Overweight_surcharge__c > 0 || item.Seal_Charges__c > 0 || 
                           item.War_Risk_Surcharge__c > 0 ){
                               serviceChargeObj.shippTotalChanged = false;
                           }
                        else{
                            serviceChargeObj.shippTotalChanged = true;
                        }
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
                        orgnChargeObj.includeOriginCharge = item.Included_PDF_Origin__c;
                        if(item.Bayan__c > 0 || item.BL_Fees__c > 0 ||  
                           item.Origin_Customs_clearance__c > 0 ||   item.Export_Service_Fees__c > 0 ||   
                           item.Fasah_fee__c > 0 ||   item.Inspection__c > 0 ||  
                           item.Insurance_charges__c > 0 ||   item.Lift_on_Lift_off__c > 0 ||   
                           item.Origin_Detention_Demurrage_Charges__c > 0 ||  
                           item.Origin_Loading_Charges__c > 0 ||   item.Reefer_cntr_plug_in_charges__c > 0 || 
                           item.Tarpauline_charge__c > 0 ||   item.Truck_idling_charges__c > 0 ||   
                           item.Lashing_Charges__c > 0 ||   item.Fuel_Surcharge__c  > 0 ){
                               orgnChargeObj.originTotalChanged = false;
                           }
                        else{
                            orgnChargeObj.originTotalChanged = true;
                        }
                        itemDto.originChargesObj = orgnChargeObj;
                        
                        //Destination Charges 
                        BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                        destinObj.destinBayanCharges = item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null ;        
                        destinObj.destinCustomClearanceCharges = item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null ;        
                        destinObj.destinDOCharges = item.DO_charges__c > 0 ? item.DO_charges__c : null ;  
                        destinObj.destinFasahCharges = item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null ;        
                        destinObj.destinGatePassCharges = item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null ;        
                        destinObj.destinLOLOCharges = item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null ;        
                        destinObj.includeDestinCharge = item.Included_PDF_Destination__c ;       
                        destinObj.destinTotalCharges = item.Total_Dest__c > 0 ? item.Total_Dest__c : null ;
                        if(item.Bayan_Charges__c > 0 ||  item.Destination_Customs_Clearance__c  > 0 ||  
                           item.DO_charges__c > 0 || item.Fasah_Charges__c  > 0 ||  
                           item.Gate_pass_charges__c  > 0 ||  item.LOLO_Charges__c > 0 ){
                               destinObj.DestinTotalChanged = false;
                           }
                        else{
                            destinObj.DestinTotalChanged = true;
                        }
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
                        addnObj.includeAdditionalCharge =item.Included_PDF_Additional__c;
                        addnObj.AlternateDepotReleaseCharges = item.Alternate_depot_release_charges__c > 0 ? item.Alternate_depot_release_charges__c : null;
                        addnObj.FreightDifference = item.Freight_Difference_FD__c > 0 ? item.Freight_Difference_FD__c : null;
                        addnObj.CarrierContainerRepositioningCharges = item.Carrier_container_repositioning_charges__c > 0 ? item.Carrier_container_repositioning_charges__c : null;
                        addnObj.tankRentalCharge = item.Tank_Rental_Charges__c > 0 ? item.Tank_Rental_Charges__c : null;
                                
                        itemDto.additionalChargesObj = addnObj;
                        
                        //ExWorks Charges
                        BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                        xWorksObj.LoadCharge = item.Ex_Works_Charge__c  > 0 ?  item.Ex_Works_Charge__c : null ;
                        xWorksObj.Id = item.Ex_Works_Charge_Name__c != null ? item.Ex_Works_Charge_Name__r.name : null;
                        xWorksObj.includeExWorksCharge = item.Included_PDF_Ex_works__c ;
                        itemDto.exWorksObj = xWorksObj;
                        system.debug('xWorksObj.LoadCharge '+xWorksObj.LoadCharge);
                        quoteItemDto.add(itemDto);
                    }
                    }
                }
               // if(has40HCEquip == false){
                    for(Quotation_Item__c item  : quoteItem){
                        if(item.Equipment_Type__r.Name == '20DC'){
                            BAFCOGeneratePDFDto.serviceChargeList itemDto = new BAFCOGeneratePDFDto.serviceChargeList();
                            itemDto.shippingLine = item.Shipping_Line__c ;
                            itemDto.transitTime = '** (Not Mapped) **';
                            itemDto.serviceType = item.Route__r.Service_Type__c;
                            //itemDto.placeOfPickup = item.Place_of_Pickup__c != null ? item.Place_of_Pickup__r.Name : null;
                            //itemDto.placeOfDischarge = item.Place_of_Discharge__c != null ? item.Place_of_Discharge__r.Name : null;
                            itemDto.placeOfPickup = item.Pickup_Place__c;
                        	itemDto.placeOfDischarge = item.Discharge_Place__c;
                            itemDto.portOfLoading = item.Port_of_Loading__r.name;
                            itemDto.portOfDestination = item.Port_of_Discharge__r.name;
                            itemDto.total = item.Total__c;
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
                            serviceChargeObj.includeServiceCharge = item.Included_PDF_ShippingLine__c;
                            if(item.BAF__c > 0 || item.Bunker_surcharge__c  > 0 || 
                               item.Cleaning_charges__c > 0 || item.CMC__c > 0 || 
                               item.Carriage_Congestion_Surcharge__c > 0 || item.Carrier_Security_Fees__c > 0 || 
                               item.DG_Surcharge__c > 0 || item.DTHC__c > 0 || item.EIC__c > 0 || 
                               item.Inland_Fuel_Surcharge__c > 0 || item.Inland_Handling_Fees__c > 0 || 
                               item.Inland_haulage__c > 0 || item.ISPS__c > 0 || 
                               item.Low_Sulphur_Surcharge__c > 0 || item.Operational_Recovery_Surcharge__c > 0 || 
                               item.OTHC__c > 0 || item.Overweight_surcharge__c > 0 || item.Seal_Charges__c > 0 || 
                               item.War_Risk_Surcharge__c > 0 ){
                                   serviceChargeObj.shippTotalChanged = false;
                               }
                            else{
                                serviceChargeObj.shippTotalChanged = true;
                            }
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
                            orgnChargeObj.includeOriginCharge = item.Included_PDF_Origin__c;
                            if(item.Bayan__c > 0 || item.BL_Fees__c > 0 ||  
                               item.Origin_Customs_clearance__c > 0 ||   item.Export_Service_Fees__c > 0 ||   
                               item.Fasah_fee__c > 0 ||   item.Inspection__c > 0 ||  
                               item.Insurance_charges__c > 0 ||   item.Lift_on_Lift_off__c > 0 ||   
                               item.Origin_Detention_Demurrage_Charges__c > 0 ||  
                               item.Origin_Loading_Charges__c > 0 ||   item.Reefer_cntr_plug_in_charges__c > 0 || 
                               item.Tarpauline_charge__c > 0 ||   item.Truck_idling_charges__c > 0 ||   
                               item.Lashing_Charges__c > 0 ||   item.Fuel_Surcharge__c  > 0 ){
                                   orgnChargeObj.originTotalChanged = false;
                               }
                            else{
                                orgnChargeObj.originTotalChanged = true;
                            }
                            itemDto.originChargesObj = orgnChargeObj;
                            
                            //Destination Charges 
                            BAFCOImportRMSDto.destinChargeObj destinObj = new BAFCOImportRMSDto.destinChargeObj();
                            destinObj.destinBayanCharges = item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null ;        
                            destinObj.destinCustomClearanceCharges = item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null ;        
                            destinObj.destinDOCharges = item.DO_charges__c > 0 ? item.DO_charges__c : null ;  
                            destinObj.destinFasahCharges = item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null ;        
                            destinObj.destinGatePassCharges = item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null ;        
                            destinObj.destinLOLOCharges = item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null ;        
                            destinObj.includeDestinCharge = item.Included_PDF_Destination__c ;           
                            destinObj.destinTotalCharges = item.Total_Dest__c > 0 ? item.Total_Dest__c : null ;
                            if(item.Bayan_Charges__c > 0 ||  item.Destination_Customs_Clearance__c  > 0 ||  
                               item.DO_charges__c > 0 || item.Fasah_Charges__c  > 0 ||  
                               item.Gate_pass_charges__c  > 0 ||  item.LOLO_Charges__c > 0 ){
                                   destinObj.DestinTotalChanged = false;
                               }
                            else{
                                destinObj.DestinTotalChanged = true;
                            }
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
                            addnObj.includeAdditionalCharge =item.Included_PDF_Additional__c;
                            addnObj.AlternateDepotReleaseCharges = item.Alternate_depot_release_charges__c > 0 ? item.Alternate_depot_release_charges__c : null;
                        	addnObj.FreightDifference = item.Freight_Difference_FD__c > 0 ? item.Freight_Difference_FD__c : null;
                        	addnObj.CarrierContainerRepositioningCharges = item.Carrier_container_repositioning_charges__c > 0 ? item.Carrier_container_repositioning_charges__c : null;
                            addnObj.tankRentalCharge = item.Tank_Rental_Charges__c > 0 ? item.Tank_Rental_Charges__c : null;
                            itemDto.additionalChargesObj = addnObj;
                            
                            //ExWorks Charges
                            BAFCOImportRMSDto.exWorksObj xWorksObj = new BAFCOImportRMSDto.exWorksObj();
                            xWorksObj.LoadCharge = item.Ex_Works_Charge__c  > 0 ?  item.Ex_Works_Charge__c : null ;
                            xWorksObj.Id = item.Ex_Works_Charge_Name__c != null ? item.Ex_Works_Charge_Name__r.name : null;
                            xWorksObj.includeExWorksCharge = item.Included_PDF_Ex_works__c ;
                            itemDto.exWorksObj = xWorksObj;
                            String UniqKey = item.Shipping_Line__c+'-'+item.Port_of_Loading__c+'-'+item.Port_of_Discharge__c;
                            Boolean alreadyAdded = false;
                            if(shipLineToitem.size() > 0 && shipLineToitem.containskey(UniqKey)){
                               Quotation_item__c  dc20item = shipLineToitem.get(UniqKey);
                                if(has40HCEquip == true && dc20item.id == item.id && DC20Added == true) alreadyAdded = true;
                            }
                            if(alreadyAdded == false)quoteItemDto.add(itemDto);
                        }
                    }
                //}
                system.debug('quoteItemDto '+quoteItemDto);
                this.dto.serviceChargeList = quoteItemDto; 
            }
        }
    }
}