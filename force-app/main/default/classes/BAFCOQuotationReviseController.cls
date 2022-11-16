public class BAFCOQuotationReviseController {
    public static final Id QUOTE_EXPORT_RECORDTYPE_Id = Schema.SObjectType.quotation__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    @AuraEnabled
    public static BAFCOReviseQuoteDto getquoteDetails(String quoteId){
        Quotation__c quoteObj = [SELECT Name__c,Enquiry__c, Leadc__c,Enquiry__r.Account__r.Average_margin__c,
                                 Enquiry__r.Account__r.Best_Margin__c,Enquiry__r.Account__r.Average_credit_days__c,
                                 Enquiry__r.Business_Type__c, Account__r.Name,Enquiry__r.Lead__r.Modes__c,
                                 Enquiry__r.Account__r.Name, 
                                 Name, Id FROM Quotation__c where id =: quoteId];        
        BAFCOReviseQuoteDto dto = new BAFCOReviseQuoteDto();
        dto.quoteNumber = quoteObj.Name__c;
        dto.enquiryId = quoteObj.Enquiry__c;
        dto.company = quoteObj.Enquiry__r.Account__r.Name;
        dto.accountAvgMargin = quoteObj.Enquiry__r.Account__r.Average_margin__c;
        dto.accountBestMargin = quoteObj.Enquiry__r.Account__r.Best_Margin__c;
        dto.accountAvgCreditDays = quoteObj.Enquiry__r.Account__r.Average_credit_days__c;
        dto.businessType = quoteObj.Enquiry__r.Business_Type__c;
        dto.mode = quoteObj.Enquiry__r.Lead__r.Modes__c;
        if(quoteObj.Enquiry__r.Lead__c != null){
            dto.leadId = quoteObj.Enquiry__r.Lead__c;
            List<contact> contactList = BAFCOLeadDetailsHelper.getContactDetails(dto.leadId);
            if(contactList.size() > 0){
                dto.contactMobile = contactList[0].MobilePhone != null ? contactList[0].MobilePhone : '-';
                dto.contactEmail = contactList[0].Email != null ? contactList[0].Email : '-';
            }
            else{
                dto.contactMobile =  '-';
                dto.contactEmail =  '-';
            }
        }
        else{
            dto.contactMobile =  '-';
            dto.contactEmail =  '-';
        }
        // getting quoteItem 
        Map<String, List<Quotation_Item__c>> routetoItemMap = new Map<String, List<Quotation_Item__c>>();
        for(Quotation_Item__c item : [SELECT Total__c, Route__r.name, Name, Id, Shipping_Line__c,Equipment_Type__r.name  FROM Quotation_Item__c where Quotation__c =: quoteId]){
            if(!routetoItemMap.containskey(item.Route__r.name)){
                routetoItemMap.put(item.Route__r.name, new list<Quotation_Item__c>());
            }
            routetoItemMap.get(item.Route__r.name).add(item);
        }
        dto.routetoItemMap = routetoItemMap;
        return dto;
    }
    @AuraEnabled
    public static List<Quotation__c> getquoteList(String quoteId){
        Quotation__c quoteObj = [Select Enquiry__c,Enquiry__r.Recordtype.name from Quotation__c where Id =: quoteId limit 1];
        List<Quotation__c> quoteList =  [Select Id,Name__c,Recordtype.name from Quotation__c where Enquiry__c =: quoteObj.Enquiry__c and recordtypeid = :QUOTE_EXPORT_RECORDTYPE_Id order by CreatedDate desc];
        
        return quoteList;
    }
    @AuraEnabled 
    public static List<BAFCORoutingDetailsDto> getQuoteLineItemRoute(String quoteId){
        BAFCOReviseQuoteDto dto = new BAFCOReviseQuoteDto();
        Map<String,Quotation_Item__c> mapRouteIdToQuotationItem = new Map<String,Quotation_Item__c>();
        for(Quotation_Item__c item : [SELECT Route__c,Equipment_Type__c, Shipping_Line__c FROM Quotation_Item__c where Quotation__c =: quoteId Order by CreatedDate]){
            if(!mapRouteIdToQuotationItem.containsKey(item.Route__c)) 
                mapRouteIdToQuotationItem.put(item.Route__c,item);
        }
        List<BAFCORoutingDetailsDto> routingDetailsList = new List<BAFCORoutingDetailsDto>();
        Integer index = 1;
        for(Route__c enqObj : [SELECT Enquiry__c ,Regular_Routing_Lookup__r.name,Port_of_loading__c,Place_of_Discharge__c,Place_of_Pickup__c,Id, Regular_Routing__c,INCO_Term__r.name, Kind_Of_Shipment__c, Service_Type__c, Port_of_loading__r.Name, 
                               Port_of_Destination__r.Name, Shipping_Line__r.name, Commodity__r.Name, Cargo_Weight__c, Remarks__c, Name  
                               FROM Route__c WHERE  Id in : mapRouteIdToQuotationItem.keySet()]){
                                   BAFCORoutingDetailsDto enqDtoObj = new BAFCORoutingDetailsDto();
                                   enqDtoObj.routeName = 'Route '+ index;
                                   enqDtoObj.routingRegular = enqObj.Regular_Routing_Lookup__c != null ? enqObj.Regular_Routing_Lookup__r.name : '-';
                                   enqDtoObj.shipmentKind = enqObj.Kind_Of_Shipment__c != null ? enqObj.Kind_Of_Shipment__c : '-';
                                   enqDtoObj.serviceType = enqObj.Service_Type__c != null ? enqObj.Service_Type__c : '-';
                                   enqDtoObj.portDestination = enqObj.Port_of_Destination__r.Name != null ? enqObj.Port_of_Destination__r.Name :'-';
                                   enqDtoObj.portLoading = enqObj.Port_of_loading__r.name != null ? enqObj.Port_of_loading__r.name : '-';
                                   enqDtoObj.commodity = enqObj.Commodity__r.Name != null ? enqObj.Commodity__r.name : '-';
                                   enqDtoObj.cargoWeights = enqObj.Cargo_Weight__c != null ? enqObj.Cargo_Weight__c : 0 ;
                                   enqDtoObj.remarks = enqObj.Remarks__c != null ? enqObj.Remarks__c : '-';
                                   enqDtoObj.routeId = enqObj.Id;
                                   enqDtoObj.shippingLine = enqObj.Shipping_Line__r.name != null ? enqObj.Shipping_Line__r.name : '-';
                                   enqDtoObj.enquiryId = enqObj.Enquiry__c;
                                   index++;
                                   routingDetailsList.add(enqDtoObj);
                               }
        return routingDetailsList;
    }
    @AuraEnabled 
    public static Map<String,List<BAFCOAllQuotationItemDto>> getQuoteLineItemDetails(String quoteId,String portLoading, String portDestination, String commodity, String routeId){
        Map<String,List<BAFCOAllQuotationItemDto>> shipLineToEquipMap = new Map<String,List<BAFCOAllQuotationItemDto>>();
        Map<String,RMS__c> rmsObjectToSeaFreightMap = new Map<String,RMS__c>();
        Map<String,INCO_Charge__c> rmsIdToIncoMap = new Map<String,INCO_Charge__c>();
        Decimal buyingTotal = 0;
        Decimal incoTotal = 0;
        List<Id> rmsIds = new List<Id>();
        List<String> duplicateList = new List<String>();
        Set<Id> quoteRmsId = new Set<Id>();
        for(Quotation_Item__c item : [SELECT RMS__c from Quotation_Item__c where Quotation__c =: quoteId And Route__c =:routeId]){
            quoteRmsId.add(item.RMS__c);
        }
        for(RMS__c rmsObj : [Select Validity__c,Id,Sea_Freight__c, Shipping_Line__r.Name,Equipment_Type__r.name FROM RMS__c WHERE Port_Of_Loading__r.Name =: portLoading 
                             AND Port_Of_Discharge__r.Name =: portDestination
                             AND Shipping_Line__r.Name != null
                             AND Equipment_Type__r.name != null
                             AND Id in:quoteRmsId]
           ){
               if(rmsObj.Shipping_Line__r.Name != null && rmsObj.Equipment_Type__r.name != null){
                   String uniqueObj = rmsObj.Shipping_Line__r.Name+'-'+rmsObj.Equipment_Type__r.name;
                   rmsObjectToSeaFreightMap.put(uniqueObj,rmsObj);
               }
               rmsIds.add(rmsObj.id);
           }
        for(INCO_Charge__c incoObj : [SELECT Total__c, Id FROM INCO_Charge__c where RMS__c In: rmsIds]){
            if(incoObj.Total__c > 0) buyingTotal = incoObj.Total__c + buyingTotal;
        }
        for(Shipping_Line_Charge__c slc : [SELECT Total__c FROM Shipping_Line_Charge__c WHERE RMS__c In : rmsIds]){                                               
            if(slc.Total__c > 0 ) buyingTotal = buyingTotal + slc.Total__c;
            
        }
        for(Destination_Charges__c destinObj :  [SELECT Total__c FROM Destination_Charges__c where RMS__c =: rmsIds]){
            if(destinObj.Total__c > 0 ) buyingTotal = buyingTotal + destinObj.Total__c;
        }
        for(Quotation_Item__c item : [SELECT Id, Name,Agent_Name__c,Equipment_Type__r.name, CurrencyIsoCode, Quotation__c, BAF__c, Bayan__c, Bayan_cancellation_charge__c, Bunker_surcharge__c, CMC__c, Cleaning_charges__c, Container_movement_charges__c, Container_Lashing_Charges__c, Container_stripping__c, DTHC__c, Destination_Customs_Clearance__c, Destination_Loading_Charges__c, EIC__c, Equipment_Type__c, Fasah_fee__c, Free_time_certificate_charges__c, Fumigation__c, ISPS__c, Inspection__c, Insurance_charges__c, Lift_on_Lift_off__c, MOT_fine_charges__c, Ministry_clearnce_charge_for_OOG_cargo__c, Miscellaneous__c, Non_Palletized_Surcharge__c, OTHC__c, Origin_Customs_clearance__c, Origin_Loading_Charges__c, Pest_control__c, Port_Shuttling__c, Port_of_Discharge__c, Port_of_Loading__c, RMS__c, Re_palletization__c, Reefer_PTI_charges__c, Reefer_cntr_plug_in_charges__c, Reefer_steam_wash__c, Route__c, Sea_Freight__c, Seal_Charges__c, Stuffing_Charges__c, SweepingCleaning__c, Tabadul__c, Tarpauline_charge__c, Total_INCO__c, Total_SL__c, Total__c, Truck_Head_charges__c, Truck_idling_charges__c, Vessel_certificate_charges__c, Wrappingpacking_charges__c, Xray__c, Shipping_Line__c, Loading_Charges__c, Carriage_Congestion_Surcharge__c, Carrier_Security_Fees__c, Bayan_Charges__c, BL_Fees__c, DG_Surcharge__c, DO_charges__c, Export_Service_Fees__c, Fasah_Charges__c, Fuel_Surcharge__c, Gate_pass_charges__c, Inland_Fuel_Surcharge__c, Inland_Handling_Fees__c, Inland_haulage__c, Low_Sulphur_Surcharge__c, Operational_Recovery_Surcharge__c, Lashing_Charges__c, LOLO_Charges__c, Origin_Detention_Demurrage_Charges__c, Overweight_surcharge__c, Pickup_Charges__c, Total_Dest__c, War_Risk_Surcharge__c, VGM__c, Total_Additional__c, Charges_Included__c
                                      FROM Quotation_Item__c where Quotation__c =: quoteId And Route__c =:routeId ]){
            if(!shipLineToEquipMap.containsKey(item.Shipping_Line__c)){
                shipLineToEquipMap.put(item.Shipping_Line__c,new List<BAFCOAllQuotationItemDto>());
            }
            BAFCOAllQuotationItemDto itemDto = new BAFCOAllQuotationItemDto();
            string uniqueObj= item.Shipping_Line__c+'-'+item.Equipment_Type__r.name;
            if(rmsObjectToSeaFreightMap.containsKey(uniqueObj)){
                itemDto.seaFreight = item.Sea_Freight__c;
                //itemDto.totalBuyingRate = buyingTotal;
                itemDto.validity = String.valueof(rmsObjectToSeaFreightMap.get(uniqueObj).Validity__c);
                itemDto.rmsId = rmsObjectToSeaFreightMap.get(uniqueObj).Id;
                itemDto.totalBuyingRate = buyingTotal + (rmsObjectToSeaFreightMap.get(uniqueObj).Sea_Freight__c > 0 ? rmsObjectToSeaFreightMap.get(uniqueObj).Sea_Freight__c : 0);
                // Destin Charges
                itemdto.destinBayanCharges= item.Bayan_Charges__c > 0 ? item.Bayan_Charges__c : null;
                itemdto.destinCustomClearanceCharges= item.Destination_Customs_Clearance__c > 0 ? item.Destination_Customs_Clearance__c : null;
                itemdto.destinDOCharges= item.DO_charges__c > 0 ? item.DO_charges__c : null;
                itemdto.destinFasahCharges= item.Fasah_Charges__c > 0 ? item.Fasah_Charges__c : null;
                itemdto.destinGatePassCharges= item.Gate_pass_charges__c > 0 ? item.Gate_pass_charges__c : null;
                itemdto.destinLOLOCharges= item.LOLO_Charges__c > 0 ? item.LOLO_Charges__c : null;
                itemdto.destinTotalCharges= item.Total_Dest__c > 0 ? item.Total_Dest__c : null;
                // origin charges 
                itemDto.bayan = item.Bayan__c > 0 ? item.Bayan__c : null;
                itemDto.blFees = item.BL_Fees__c > 0  ? item.BL_Fees__c : null;
                itemDto.originCustomClearance = item.Origin_Customs_clearance__c > 0  ? item.Origin_Customs_clearance__c : null;
                itemDto.exportServiceFees = item.Export_Service_Fees__c > 0  ? item.Export_Service_Fees__c : null;
                itemDto.fasahFees = item.Fasah_fee__c > 0  ? item.Fasah_fee__c : null;
                itemDto.inspection = item.Inspection__c  > 0 ? item.Inspection__c : null;
                itemDto.insuranceCharges = item.Insurance_charges__c > 0 ? item.Insurance_charges__c : null;
                itemDto.liftOnLiftOff = item.Lift_on_Lift_off__c > 0  ? item.Lift_on_Lift_off__c : null;
                itemDto.OriginDetention = item.Origin_Detention_Demurrage_Charges__c > 0  ? item.Origin_Detention_Demurrage_Charges__c : null;
                itemDto.OriginLoadingCharges = item.Loading_Charges__c > 0  ? item.Loading_Charges__c : null;
                itemDto.pickUpCharges = item.Pickup_Charges__c > 0  ? item.Pickup_Charges__c : null;
                itemDto.ReeferControlPlugInCharge = item.Reefer_cntr_plug_in_charges__c > 0  ? item.Reefer_cntr_plug_in_charges__c : null;
                itemDto.tabadul = item.Tabadul__c > 0 ? item.Tabadul__c  : null;
                itemDto.trapulinCharges = item.Tarpauline_charge__c > 0  ? item.Tarpauline_charge__c : null;
                itemDto.truckIdlingCharges = item.Truck_idling_charges__c  > 0 ? item.Truck_idling_charges__c : null;
                itemDto.vgm = item.VGM__c > 0  ? item.VGM__c : null;
                itemDto.xray = item.Xray__c > 0  ? item.Xray__c : null;
                itemDto.lashingCharges = item.Lashing_Charges__c > 0 ? item.Lashing_Charges__c : null;
                itemDto.fuelSurcharge = item.Fuel_Surcharge__c > 0  ? item.Fuel_Surcharge__c : null;
                itemDto.TotalOrigincharges = item.Total_INCO__c > 0  ? item.Total_INCO__c : null;
                
                // Shipping Charges 
                itemDto.BAF = item.BAF__c > 0 ? item.BAF__c : null;
                itemDto.bunkerCharges = item.Bunker_surcharge__c > 0 ? item.Bunker_surcharge__c : null;
                itemDto.cleaningCharges = item.Cleaning_charges__c > 0 ? item.Cleaning_charges__c : null;
                itemDto.CMC = item.CMC__c > 0 ? item.CMC__c : null;
                itemDto.carriageCongestionSurcharge = item.Carriage_Congestion_Surcharge__c > 0 ? item.Carriage_Congestion_Surcharge__c : null;
                itemDto.carrierSecurityFees = item.Carrier_Security_Fees__c > 0 ? item.Carrier_Security_Fees__c : null;
                itemDto.dgSurcharge = item.DG_Surcharge__c > 0 ? item.DG_Surcharge__c : null;
                itemDto.DTHC = item.DTHC__c > 0 ? item.DTHC__c : null;
                itemDto.equipmentImbalance = item.EIC__c > 0 ? item.EIC__c : null;
                itemDto.inlandFuelCharges = item.Inland_Fuel_Surcharge__c > 0 ? item.Inland_Fuel_Surcharge__c : null;
                itemDto.inlandHandlingfees = item.Inland_Handling_Fees__c > 0 ? item.Inland_Handling_Fees__c : null;
                itemDto.inlandHaulage = item.Inland_haulage__c > 0 ? item.Inland_haulage__c : null;
                itemDto.ISPS = item.ISPS__c > 0 ? item.ISPS__c : null;
                itemDto.lowerSulphurSurcharge = item.Low_Sulphur_Surcharge__c > 0 ? item.Low_Sulphur_Surcharge__c : null;
                itemDto.operationalRecovery = item.Operational_Recovery_Surcharge__c > 0 ? item.Operational_Recovery_Surcharge__c : null;
                itemDto.OTHC = item.OTHC__c > 0 ? item.OTHC__c : null;
                itemDto.overWeightCharge = item.Overweight_surcharge__c > 0 ? item.Overweight_surcharge__c : null;
                itemDto.sealCharges = item.Seal_Charges__c > 0 ? item.Seal_Charges__c : null;
                itemDto.warRiskSurcharges = item.War_Risk_Surcharge__c > 0 ? item.War_Risk_Surcharge__c : null;
                itemDto.totalSl = item.Total_SL__c > 0 ? item.Total_SL__c : null;
                //Additional Charge Data
                List<BAFCOAllQuotationItemDto.additionalChargeList> additionalChargeList = new List<BAFCOAllQuotationItemDto.additionalChargeList>();
                if(item.Bayan_cancellation_charge__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Bayan cancellation charge';
                    obj.value = item.Bayan_cancellation_charge__c;
                    additionalChargeList.add(obj);
                }
                if(item.Container_movement_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Container movement charges';
                    obj.value = item.Container_movement_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Container_stripping__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Container stripping';
                    obj.value = item.Container_stripping__c;
                    additionalChargeList.add(obj);
                }
                if(item.Free_time_certificate_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Free time certificate charges';
                    obj.value = item.Free_time_certificate_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Fumigation__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Fumigation';
                    obj.value = item.Fumigation__c;
                    additionalChargeList.add(obj);
                }
                if(item.Ministry_clearnce_charge_for_OOG_cargo__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Ministry clearnce charge for OOG cargo';
                    obj.value = item.Ministry_clearnce_charge_for_OOG_cargo__c;
                    additionalChargeList.add(obj);
                }
                if(item.Miscellaneous__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Miscellaneous';
                    obj.value = item.Miscellaneous__c;
                    additionalChargeList.add(obj);
                }
                if(item.MOT_fine_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'MOT fine charges';
                    obj.value = item.MOT_fine_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Non_Palletized_Surcharge__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Non Palletized Surcharge';
                    obj.value = item.Non_Palletized_Surcharge__c;
                    additionalChargeList.add(obj);
                }
                if(item.Pest_control__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Pest control';
                    obj.value = item.Pest_control__c;
                    additionalChargeList.add(obj);
                }
                if(item.Re_palletization__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Re palletization';
                    obj.value = item.Re_palletization__c;
                    additionalChargeList.add(obj);
                }
                
                if(item.Reefer_PTI_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Reefer PTI charges';
                    obj.value = item.Reefer_PTI_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Reefer_steam_wash__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Reefer steam wash';
                    obj.value = item.Reefer_steam_wash__c;
                    additionalChargeList.add(obj);
                }
                if(item.Stuffing_Charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Stuffing Charges';
                    obj.value = item.Stuffing_Charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.SweepingCleaning__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Sweeping/Cleaning';
                    obj.value = item.SweepingCleaning__c;
                    additionalChargeList.add(obj);
                }
                if(item.Truck_Head_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Truck Head charges';
                    obj.value = item.Truck_Head_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Truck_idling_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Truck idling charges';
                    obj.value = item.Truck_idling_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Vessel_certificate_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Vessel certificate charges';
                    obj.value = item.Vessel_certificate_charges__c;
                    additionalChargeList.add(obj);
                }
                if(item.Wrappingpacking_charges__c > 0){
                    BAFCOAllQuotationItemDto.additionalChargeList obj = new BAFCOAllQuotationItemDto.additionalChargeList();
                    obj.Name = 'Wrapping/packing charges';
                    obj.value = item.Wrappingpacking_charges__c;
                    additionalChargeList.add(obj);
                }
                if(additionalChargeList.size() > 0){
                    itemDto.additionalChargeList = additionalChargeList;
                }
            }
            itemDto.totalSellingRate = item.Sea_Freight__c;
             if(!duplicateList.contains(item.Shipping_Line__c+item.Equipment_Type__r.name)){
                duplicateList.add(item.Shipping_Line__c+item.Equipment_Type__r.name);
                itemDto.equipmentName = item.Equipment_Type__r.name;
                itemDto.equipmentId = item.Equipment_Type__c;  
                itemDto.totaladditionalCharge = item.Total_Additional__c;
                shipLineToEquipMap.get(item.Shipping_Line__c).add(itemDto);
            }
        }
        return shipLineToEquipMap;
    }
    /*@AuraEnabled
public static Map<String,List<BAFCOLinitemDto>> getprevQuoteDetail(String enquiryId, String portLoading, String portDestination, String commodity){
Map<String,List<BAFCOLinitemDto>> shipLineToEquipMap = new Map<String,List<BAFCOLinitemDto>>();
List<Quotation__c> quoteList = [SELECT Id,createdDate FROM Quotation__c where Enquiry__c  =: enquiryId order by createdDate DESC limit 1 ];
if(quoteList.size() > 0){
// shipLineToEquipMap = getQuoteLineItemDetails(quoteList[0].id,portLoading,portDestination,commodity);
}
return shipLineToEquipMap;
}*/
}