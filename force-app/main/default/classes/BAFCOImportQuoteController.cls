public class BAFCOImportQuoteController {
    public static final Id RMS_IMPORT_RECORDTYPE_Id = Schema.SObjectType.RMS__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    public static final Id ENQUIRY_EXPORT_RECORDTYPE_Id = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id ENQUIRY_IMPORT_RECORDTYPE_Id = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    public static final Id QUOTE_EXPORT_RECORDTYPE_Id = Schema.SObjectType.quotation__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id QUOTE_IMPORT_RECORDTYPE_Id = Schema.SObjectType.quotation__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    @AuraEnabled
    public static List<Agent__c> getAgentsRecords(){
        return [Select Id, Name from Agent__c];
    }
    @AuraEnabled
    public static Map<String,Map<String,List<BAFCORMSDto>>> getImportRMSDetails(String portLoading, String portDestination, String commodity,String routeId,String enquiryId) {
        List<String> rmsEquipmentList = new List<String>();
        Map<String,Map<String,List<BAFCORMSDto>>> agentToEquipMap = new Map<String,Map<String,List<BAFCORMSDto>>>();
        List<String> routeEquipmentList = new List<String>();
        Map<String,Decimal> routeEquipmentoquantityMap = new Map<String,Decimal>();
        Date todaysDate = System.today();
        String QuoteId = '';        
        Map<String,String>  quoteItemToIdMap = new Map<String,String>();
        for(Route_Equipment__c routeEquip : [Select Equipment_Type__r.name,Quantity__c  FROM Route_Equipment__c WHERE Route__c=:routeId]){
            routeEquipmentList.add(routeEquip.Equipment_Type__r.name);
            routeEquipmentoquantityMap.put(routeEquip.Equipment_Type__r.name,routeEquip.Quantity__c);
        }
        for(RMS__c rmsObj : [Select Equipment_Type__c  FROM RMS__c WHERE Port_Of_Loading__r.Name =: portLoading 
                             AND Port_Of_Discharge__r.Name =: portDestination
                             AND Validity__c >=: todaysDate AND recordtypeId =: RMS_IMPORT_RECORDTYPE_Id]){
                                 rmsEquipmentList.add(rmsObj.Equipment_Type__c) ;                     
                             }
        // to get Previously generated Quote
        List<Quotation__c> quoteList = [SELECT Id FROM Quotation__c where Opportunity__c  =: enquiryId limit 1];
        if(quoteList.size() > 0) QuoteId = quoteList[0].Id;
        if(!String.isBlank(QuoteId)){
            for(Quotation_Item__c item : [Select Equipment_Type__r.name,Shipping_Line__c,id from Quotation_Item__c  where Quotation__c =: QuoteId
                                          AND Equipment_Type__r.name != null AND Shipping_Line__c != null ]){
                                              String key = item.Shipping_Line__c+'-'+item.Equipment_Type__r.name;
                                              quoteItemToIdMap.put(key,item.Id);
                                          }
        }
        if(rmsEquipmentList.size() > 0){
            for(Route_Equipment__c routeEquip : [Select Equipment_Type__r.name,Quantity__c  FROM Route_Equipment__c WHERE Route__c=:routeId and id in : rmsEquipmentList]){
                routeEquipmentoquantityMap.put(routeEquip.Equipment_Type__r.name,routeEquip.Quantity__c);
            }        
        }
        for(RMS__c rmsObj : [Select Agent__r.Name,Validity__c, Id,Sea_Freight__c, Equipment_Type__c,Shipping_Line__c,Shipping_Line__r.Name,Equipment_Type__r.name  
                             FROM RMS__c WHERE Port_Of_Loading__r.Name =: portLoading 
                             AND Port_Of_Discharge__r.Name =: portDestination
                             AND Shipping_Line__r.Name != null
                             AND Equipment_Type__r.name != null
                             AND Validity__c >=: todaysDate
                             AND recordtypeId =: RMS_IMPORT_RECORDTYPE_Id
                            ]){
                                if(!agentToEquipMap.ContainsKey(rmsObj.Agent__r.Name)){
                                    agentToEquipMap.put(rmsObj.Agent__r.Name,new Map<String,List<BAFCORMSDto>>());
                                }
                                Map<String,List<BAFCORMSDto>> tempMap = agentToEquipMap.get(rmsObj.Agent__r.Name);
                                if(!tempMap.containsKey(rmsObj.Shipping_Line__r.Name)){
                                    tempMap.put(rmsObj.Shipping_Line__r.Name, new List<BAFCORMSDto>());
                                }
                                BAFCORMSDto rmsDto = new BAFCORMSDto();  
                                if(routeEquipmentoquantityMap.containsKey(rmsObj.Equipment_Type__r.name)){
                                    rmsDto.quantity = routeEquipmentoquantityMap.get(rmsObj.Equipment_Type__r.name);
                                }
                                rmsDto.equipmentName = rmsObj.Equipment_Type__r.name;
                                rmsDto.equipmentId = rmsObj.Equipment_Type__c;
                                rmsDto.seaFreight = rmsObj.Sea_Freight__c ; 
                                rmsDto.rmsID = rmsObj.id;
                                rmsDto.quotationId = QuoteId;
                                rmsDto.agentId = rmsObj.Agent__c;
                                rmsDto.agentName = rmsObj.Agent__r.Name;
                                /* NEED TO DISCUSS */
                                /* String key = rmsObj.Shipping_Line__r.Name+'-'+rmsObj.Equipment_Type__r.name;
if(quoteItemToIdMap.containsKey(key)){
rmsDto.quotationItemId = quoteItemToIdMap.get(key);  
}*/
                                Date d = rmsObj.Validity__c != null ? rmsObj.Validity__c : null;
                                if(d != null)
                                    rmsDto.validity = DateTime.newInstance(d.year(),d.month(),d.day()).format('dd-MMM-YYYY') +', '+system.today().daysBetween(d) +' Days';
                                tempMap.get(rmsObj.Shipping_Line__r.Name).add(rmsDto);
                                
                            }
        for(String equip : routeEquipmentList){
            for(String key : agentToEquipMap.keyset()){
                for(String key2 : agentToEquipMap.get(key).keyset()){
                    Boolean found = false;
                    for(BAFCORMSDto dto : agentToEquipMap.get(key).get(key2)){
                        if(dto.equipmentName == equip){
                            found = true;
                            break;
                        }
                    }
                    if(!found){
                        BAFCORMSDto rmsDto = new BAFCORMSDto();
                        rmsDto.equipmentName = equip;
                        rmsDto.equipmentId  = '';
                        rmsDto.rmsID = '';
                        agentToEquipMap.get(key).get(key2).add(rmsDto);
                    }
                }
            }
        }
        return agentToEquipMap;
    }
    @AuraEnabled
    public static String genrateQuotation(String routeId, String rmsId, String enquiryId,String quotationId, BAFCOImportRMSDto dto, String incoTerm,String remarks, Decimal additionalChargeTotal,Boolean cameReviseCompt, Boolean sameRoute,string agentName){
        system.debug('dto '+dto);
        system.debug('enquiryId '+enquiryId);
        system.debug('agentName '+agentName);
        List<BAFCOImportRMSDto.AdditionalCharge> additionalChargeList = dto.additionalChargeList;
        shippingLineChargesDTO shipLineDto = BAFCOshippingLineChargesController.getShippingCharges(rmsId);
        List<Quotation__c> quoteList = new List<Quotation__c>();
        RMS__c rmsObj = [SELECT Id, Port_Of_Loading__c, Port_Of_Discharge__c, Equipment_Type__c FROM RMS__c where id =: rmsId Limit 1];
        BAFCOIncoChargesDto incoDto = BAFCOLRoutingDetailsController.getIncoCharges(rmsId,incoTerm);
        Quotation__c quoteObj = new Quotation__c();
        if(quotationId == ''  || quotationId == null || (cameReviseCompt  == true && sameRoute == true)){
            List<opportunity> enqList  = [SELECT Id,AccountId,Business_Type__c,No_of_Quotes__c,(Select id,name,Name__c from Quotations__r order by createdDate) FROM Opportunity where id =: enquiryId];     
            if(enqList.size() > 0){
                opportunity enqObj = enqList[0];
                //quoteObj.Leadc__c = enqObj.Lead__c;   
                quoteObj.Account__c = enqObj.AccountId;             
                if(enqObj.Business_Type__c == 'Export') quoteObj.recordtypeId = QUOTE_EXPORT_RECORDTYPE_Id;
                else if(enqObj.Business_Type__c == 'Import') quoteObj.recordtypeId = QUOTE_IMPORT_RECORDTYPE_Id;
                
                Decimal quoteNumber = enqObj.No_of_Quotes__c + 1;
                quoteList = enqObj.Quotations__r;
            }
            else{
               List<opportunity> enqList1  = [SELECT AccountId,Id,Business_Type__c,No_of_Quotes__c,(Select id,name,Name__c from Quotations__r order by createdDate) FROM opportunity where id =: enquiryId];
                system.debug('enqList1 '+enqList1);
                if(enqList1.size() > 0){
                    opportunity enqObj = enqList1[0];
                    quoteObj.Leadc__c = enqObj.Lead__c;
                    quoteObj.Account__c = enqObj.AccountId;
                    if(enqObj.Business_Type__c == 'Export') quoteObj.recordtypeId = QUOTE_EXPORT_RECORDTYPE_Id;
                    else if(enqObj.Business_Type__c == 'Import') quoteObj.recordtypeId = QUOTE_IMPORT_RECORDTYPE_Id;                    
                   Decimal quoteNumber = enqObj.No_of_Quotes__c + 1;
                    quoteList = enqObj.Quotations__r;
               }
            }
            quoteObj.Opportunity__c = enquiryId;            
            integer year =  Date.Today().Year();
            string s1=string.valueof(year).right(2);
            Integer Year1= Integer.valueof(s1);
            if(quoteList.size() > 0){
                if(cameReviseCompt == true){
                    String fullName = quoteList[0].Name__c;
                    String lastName = fullName.Substring(fullName.lastIndexOf('/')+1,fullName.length());
                    quoteObj.Name__c = 'Quote/'+Year1+'/'+lastName+'-'+quoteList.size();
                }else{                
                    Integer  quoteSize = quoteList.size();
                    quoteObj.Name__c = 'Quote/'+Year1+'/'+quoteSize;
                }
            }
            else{
                quoteObj.Name__c = 'Quote/'+Year1+'/'+1;
            }
            quoteObj.Remarks__c = remarks;
            Insert quoteObj;
        }
        Quotation_Item__c quoteItemObj = new Quotation_Item__c();
        quoteItemObj.Route__c = routeId;
        quoteItemObj.RMS__c = rmsId;
        quoteItemObj.CurrencyIsoCode = dto.currencyCode;
        quoteItemObj.Agent_Name__c = agentName;
        if(rmsObj != null){
            quoteItemObj.Port_of_Discharge__c = rmsObj.Port_Of_Discharge__c;
            quoteItemObj.Port_of_Loading__c = rmsObj.Port_Of_Loading__c;
            quoteItemObj.Equipment_Type__c = rmsObj.Equipment_Type__c;
        }
        if(quotationId == '' || quotationId == null || (cameReviseCompt  == true && sameRoute == true)){
            String initialquoteName = [Select Name from Quotation__c where id=: quoteObj.id limit 1].Name;
            quoteItemObj.Name = initialquoteName + ' - 1';
            quoteItemObj.Quotation__c = quoteObj.id;
        }
        else{
            List<Quotation_Item__c> quoteList3 = [Select id,Quotation__r.name from Quotation_Item__c where Quotation__c =: quotationId];
            quoteItemObj.Quotation__c = quotationId;
            if(quoteList3.size() > 0){
                quoteItemObj.Name = quoteList3[0].Quotation__r.name + ' - '+quoteList3.size() + 1;
            }
            quoteObj.id = quotationId;
            List<opportunity> enqList5  = [SELECT Id,Business_Type__c,No_of_Quotes__c,(Select id,name,Name__c from Quotations__r order by createdDate) FROM Opportunity where id =: enquiryId]; 
            opportunity enqObj = new opportunity();
            if(enqList5.size() > 0) enqObj = enqList5[0];
           integer year =  Date.Today().Year();
            string s1=string.valueof(year).right(2);
            Integer Year1= Integer.valueof(s1);
            Decimal quoteNumber = enqObj.No_of_Quotes__c != null ? enqObj.No_of_Quotes__c + 1 : 0;
            List<Quotation__c> quoteList2 = enqObj.Quotations__r; 
            if(quoteList2.size() > 0){
               if(cameReviseCompt == true){
                   String fullName = quoteList2[0].Name__c;
                    String lastName = fullName.Substring(fullName.lastIndexOf('/')+1,fullName.length());
                   quoteObj.Name__c = 'Quote/'+Year1+'/'+lastName+'-'+quoteList.size();
                }
                else{
                    Integer  quoteSize = quoteList2.size();
                    quoteObj.Name__c = 'Quote/'+Year1+'/'+quoteSize;
                }
            }
            quoteObj.Remarks__c = remarks;
           if(enqObj.Business_Type__c == 'Export') quoteObj.recordtypeId = QUOTE_EXPORT_RECORDTYPE_Id;
            else if(enqObj.Business_Type__c == 'Import') quoteObj.recordtypeId = QUOTE_IMPORT_RECORDTYPE_Id;                    
            update quoteObj;
        }
        if(dto.serviceChargeList != null){
            if(dto.serviceChargeList.servichargesObj != null){
                BAFCOImportRMSDto.servichargesObj servObj = dto.serviceChargeList.servichargesObj;
                if(servObj.shippTotalChanged == false){
                    quoteItemObj.BAF__c = servObj.BAF!= null ? servObj.BAF : null;
                    quoteItemObj.Bunker_surcharge__c = servObj.bunkerCharges!= null ? servObj.bunkerCharges : null;
                    quoteItemObj.Cleaning_charges__c = servObj.cleaningCharges!= null ? servObj.cleaningCharges : null;
                    quoteItemObj.CMC__c = servObj.CMC!= null ? servObj.CMC : null;
                    quoteItemObj.Carriage_Congestion_Surcharge__c = servObj.carriageCongestionSurcharge!= null ? servObj.carriageCongestionSurcharge : null;
                    quoteItemObj.Carrier_Security_Fees__c = servObj.carrierSecurityFees!= null ? servObj.carrierSecurityFees :null;
                    quoteItemObj.DG_Surcharge__c = servObj.dgSurcharge!= null ? servObj.dgSurcharge : null;
                    quoteItemObj.DTHC__c = servObj.DTHC!= null ? servObj.DTHC : null;
                    quoteItemObj.EIC__c = servObj.equipmentImbalance!= null ? servObj.equipmentImbalance : null;
                    quoteItemObj.Inland_Fuel_Surcharge__c = servObj.inlandFuelCharges!= null ? servObj.inlandFuelCharges :null;
                    quoteItemObj.Inland_Handling_Fees__c = servObj.inlandHandlingfees!= null ? servObj.inlandHandlingfees :null;
                    quoteItemObj.Inland_haulage__c = servObj.inlandHaulage!= null ? servObj.inlandHaulage : null;
                    quoteItemObj.ISPS__c = servObj.ISPS!= null ? servObj.ISPS : null;
                    quoteItemObj.Low_Sulphur_Surcharge__c = servObj.lowerSulphurSurcharge!= null ? servObj.lowerSulphurSurcharge : null;
                    quoteItemObj.Operational_Recovery_Surcharge__c = servObj.operationalRecovery!= null ? servObj.operationalRecovery : null;
                    quoteItemObj.OTHC__c = servObj.OTHC!= null ? servObj.OTHC : null;
                    quoteItemObj.Overweight_surcharge__c = servObj.overWeightCharge!= null ? servObj.overWeightCharge : null;
                    quoteItemObj.Seal_Charges__c = servObj.sealCharges!= null ? servObj.sealCharges : null;
                    quoteItemObj.War_Risk_Surcharge__c = servObj.warRiskSurcharges!= null ? servObj.warRiskSurcharges : null;                  
                }
                quoteItemObj.Total_SL__c = servObj.totalSl!= null ? servObj.totalSl : null;
            }
            if(dto.serviceChargeList.originChargesObj != null){
                BAFCOImportRMSDto.originChargesObj originObj = dto.serviceChargeList.originChargesObj;
                if(originObj.originTotalChanged == false){
                    quoteItemObj.Bayan__c = originObj.bayan != null ? originObj.bayan : null;
                    quoteItemObj.BL_Fees__c = originObj.blFees != null ? originObj.blFees : null;
                    quoteItemObj.Origin_Customs_clearance__c = originObj.originCustomClearance != null ? originObj.originCustomClearance : null;
                    quoteItemObj.Export_Service_Fees__c = originObj.exportServiceFees != null ? originObj.exportServiceFees : null;
                    quoteItemObj.Fasah_fee__c = originObj.fasahFees != null ? originObj.fasahFees : null;
                    quoteItemObj.Inspection__c = originObj.inspection != null ? originObj.inspection : null;
                    quoteItemObj.Insurance_charges__c = originObj.insuranceCharges != null ? originObj.insuranceCharges : null;
                    quoteItemObj.Lift_on_Lift_off__c = originObj.liftOnLiftOff != null ? originObj.liftOnLiftOff : null;
                    quoteItemObj.Origin_Detention_Demurrage_Charges__c = originObj.OriginDetention != null ? originObj.OriginDetention : null;
                    quoteItemObj.Origin_Loading_Charges__c = originObj.OriginLoadingCharges != null ? originObj.OriginLoadingCharges : null;
                    quoteItemObj.Pickup_Charges__c = originObj.pickUpCharges != null ? originObj.pickUpCharges : null;
                    quoteItemObj.Reefer_cntr_plug_in_charges__c = originObj.ReeferControlPlugInCharge != null ? originObj.ReeferControlPlugInCharge : null;
                    quoteItemObj.Tabadul__c = originObj.tabadul != null ? originObj.tabadul : null;
                    quoteItemObj.Tarpauline_charge__c = originObj.trapulinCharges != null ? originObj.trapulinCharges : null;
                    quoteItemObj.Truck_idling_charges__c = originObj.truckIdlingCharges != null ? originObj.truckIdlingCharges : null;
                    // quoteItemObj.t = originObj.transportationCharges != null ? originObj.transportationCharges : null;
                    quoteItemObj.VGM__c = originObj.vgm != null ? originObj.vgm : null;
                    quoteItemObj.Xray__c = originObj.xray != null ? originObj.xray : null;
                    quoteItemObj.Fuel_Surcharge__c = originObj.fuelSurcharge != null ? originObj.fuelSurcharge : null;
                    quoteItemObj.Lashing_Charges__c = originObj.lashingCharges != null ? originObj.lashingCharges : null;
                }
                quoteItemObj.Total_INCO__c = originObj.TotalOrigincharges != null ? originObj.TotalOrigincharges : null;
                //quoteItemObj.d = originObj.directionValue != null ? originObj.directionValue : null;
                //quoteItemObj.lo = originObj.loadingChargeId != null ? originObj.loadingChargeId : null;
            }
            if(dto.serviceChargeList.destinChargeObj != null){
                BAFCOImportRMSDto.destinChargeObj destinObj = dto.serviceChargeList.destinChargeObj;
                if(destinObj.DestinTotalChanged == false){
                    quoteItemObj.Bayan_Charges__c = destinObj.destinBayanCharges != null ? destinObj.destinBayanCharges : null; 
                    quoteItemObj.Destination_Customs_Clearance__c = destinObj.destinCustomClearanceCharges != null ? destinObj.destinCustomClearanceCharges : null; 
                    quoteItemObj.DO_charges__c = destinObj.destinDOCharges != null ? destinObj.destinDOCharges : null;                      
                    quoteItemObj.Fasah_Charges__c = destinObj.destinFasahCharges != null ? destinObj.destinFasahCharges : null; 
                    quoteItemObj.Gate_pass_charges__c = destinObj.destinGatePassCharges != null ? destinObj.destinGatePassCharges : null; 
                    quoteItemObj.LOLO_Charges__c = destinObj.destinLOLOCharges != null ? destinObj.destinLOLOCharges : null; 
                    //quoteItemObj = destinObj.destinTransPortationCharges != null ? destinObj.destinTransPortationCharges : null; 
                }
                quoteItemObj.Total_Dest__c = destinObj.destinTotalCharges != null ? destinObj.destinTotalCharges : null; 
            }
        }
        
        for(BAFCOImportRMSDto.AdditionalCharge dto2 : additionalChargeList){
            if(dto2.name == 'Bayan cancellation charge'){
                quoteItemObj.Bayan_cancellation_charge__c = dto2.value;
            }
            if(dto2.name == 'Cleaning charges'){
                quoteItemObj.Cleaning_charges__c = dto2.value;
            }
            if(dto2.name == 'Container Lashing Charges'){
                //quoteItemObj.Container_Lashing_Charges__c = dto2.value;
            }
            if(dto2.name == 'Container movement charges'){
                quoteItemObj.Container_movement_charges__c = dto2.value;
            }
            if(dto2.name == 'Container stripping'){
                quoteItemObj.Container_stripping__c = dto2.value;
            }
            if(dto2.name == 'Free time certificate charges'){
                quoteItemObj.Free_time_certificate_charges__c = dto2.value;
            }
            if(dto2.name == 'Fumigation'){
                quoteItemObj.Fumigation__c= dto2.value;
            }
            if(dto2.name == 'Inspection'){
                quoteItemObj.Inspection__c = dto2.value;
            }
            if(dto2.name == 'Insurance charges'){
                quoteItemObj.Insurance_charges__c = dto2.value;
            }
            if(dto2.name == 'Ministry clearnce charge for OOG cargo'){
                quoteItemObj.Ministry_clearnce_charge_for_OOG_cargo__c = dto2.value;
            }
            if(dto2.name == 'Miscellaneous'){
                quoteItemObj.Miscellaneous__c = dto2.value;
            }
            if(dto2.name == 'MOT fine charges'){
                quoteItemObj.MOT_fine_charges__c = dto2.value;
            }
            if(dto2.name == 'Non Palletized Surcharge'){
                quoteItemObj.Non_Palletized_Surcharge__c = dto2.value;
            }
            if(dto2.name == 'Pest control'){
                quoteItemObj.Pest_control__c = dto2.value;
            }
            if(dto2.name == 'Re palletization'){
                quoteItemObj.Re_palletization__c = dto2.value;
            }
            if(dto2.name == 'Reefer cntr plug-in charges'){
                quoteItemObj.Reefer_cntr_plug_in_charges__c = dto2.value;
            }
            if(dto2.name == 'Reefer PTI charges'){
                quoteItemObj.Reefer_PTI_charges__c = dto2.value;
            }
            if(dto2.name == 'Reefer steam wash'){
                quoteItemObj.Reefer_steam_wash__c = dto2.value;
            }
            if(dto2.name == 'Stuffing Charges'){
                quoteItemObj.Stuffing_Charges__c = dto2.value;
            }
            if(dto2.name == 'Sweeping/Cleaning'){
                quoteItemObj.SweepingCleaning__c = dto2.value;
            }
            /*if(dto.name == 'Tarpauline charge'){
quoteItemObj. = dto.value;
}*/
            if(dto2.name == 'Truck Head charges'){
                quoteItemObj.Truck_Head_charges__c = dto2.value;
            }
            if(dto2.name == 'Truck idling charges'){
                quoteItemObj.Truck_idling_charges__c = dto2.value;
            }
            if(dto2.name == 'Vessel certificate charges'){
                quoteItemObj.Vessel_certificate_charges__c = dto2.value;
            }
            if(dto2.name == 'Wrapping/packing charges'){
                quoteItemObj.Wrappingpacking_charges__c = dto2.value;
            }
        }
        quoteItemObj.Total__c = dto.total;
        quoteItemObj.Total_Additional__c = additionalChargeTotal;
        quoteItemObj.Sea_Freight__c = dto.seaFreightSellRate;
        quoteItemObj.Place_of_Pickup__c = dto.pickupPlace != '' ? dto.pickupPlace : null;
        quoteItemObj.Place_of_Discharge__c = dto.dischargePlace != '' ? dto.dischargePlace : null;
        quoteItemObj.Quantity__c = dto.quantity;
        try{
            upsert quoteItemObj;
        }
        Catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        
        return quoteObj.Id;
    }
}