public class BAFCOAirEnquiryController {
    @AuraEnabled
    public static String submitRoutingList(List<BAFCORoutingDetailsDto> routingList, String businessType, String quoteId,String closeDate, String commercialUserId,String isEdit,List<String> containerRemoveList,List<String> routeRemoveList, String optyId) {
        List<Route__c> routeList = new List<Route__c>();
        Opportunity optyObj = new Opportunity();
        if(isEdit == 'true'){
            optyObj.id = optyId;
            optyObj.CloseDate = date.valueOf(closeDate);
            optyObj.Commercial_User__c = commercialUserId != '' ? commercialUserId : null;
            update optyObj;
        }
        else{
            Account acc = [Select id,name,ownerId from Account where id=: quoteId];
            optyObj.Name = acc.Name +' - '+String.valueOf(date.today()).split(' ')[0];
            optyObj.AccountId = acc.Id;
            optyObj.OwnerId = acc.OwnerId;
            optyObj.Business_Type__c = businessType;
            try{
                optyObj.StageName = 'Qualification';
                optyObj.CloseDate = date.valueOf(closeDate);
                optyObj.Commercial_User__c = commercialUserId != '' ? commercialUserId : null;                
                Id LCLRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                    .get('LCL')
                    .getRecordTypeId();
                Id AirRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                    .get('Air Freight')
                    .getRecordTypeId();
                if(routingList[0].isAir == true) optyObj.RecordTypeId = AirRecId;
                else optyObj.RecordTypeId = LCLRecId;
                insert optyObj;
                Task tsk = new Task();
                tsk.Subject = 'Provide Quotation';
                tsk.Status = 'Open';
                tsk.OwnerId = commercialUserId != '' ? commercialUserId : UserInfo.getUserId();
                tsk.WhatId = optyObj.Id;
                tsk.IsReminderSet = true;
                tsk.ActivityDate = Date.valueOf(DateTime.now());
                insert tsk;
                system.debug('optyObj '+optyObj);
            }
            catch(Exception e){
                System.debug('Excepiton '+e.getMessage());
            }
        }
        Map<String,String> routeIndexToIdMap =  new Map<String,String>();
        List<Route_Equipment__c> routeEquipList = new List<Route_Equipment__c>();
        for(BAFCORoutingDetailsDto dto : routingList){
            Route__c routeObj = new Route__c();
            routeObj.Cargo_Weight__c = dto.cargoWeights;
            if(!String.isBlank(dto.commodity)) routeObj.Commodity__c =dto.commodity;
            routeObj.Kind_Of_Shipment__c = 'FCL';
            routeObj.Regular_Routing__c = dto.routingRegular;
            String ObjectName = '';
            routeObj.Regular_Routing_Lookup__c = dto.routingRegular != '' ? dto.routingRegular : null;
            if(!String.isBlank(dto.shippingLine)) routeObj.Shipping_Line__c = dto.shippingLine;
            routeObj.Service_Type__c = dto.serviceType;
            system.debug('submitRoutingList '+dto.isAir);
            if(dto.isAir == true){
              if(!String.isBlank(dto.portLoading)) routeObj.Airport_of_Loading__c = dto.portLoading;
            	if(!String.isBlank(dto.portDestination)) routeObj.Airport_of_Destination__c = dto.portDestination;  
            }
            else{
            	if(!String.isBlank(dto.portLoading)) routeObj.Port_of_loading__c = dto.portLoading;
            	if(!String.isBlank(dto.portDestination)) routeObj.Port_of_Destination__c = dto.portDestination;
            }
            routeObj.Remarks__c = dto.remarks;
            routeObj.Dangerous_Goods__c = dto.dangerousGoods;
            routeObj.Index__c = String.valueOf(dto.leadIndex);
            if(!String.isBlank(dto.incoTerm)) routeObj.INCO_Term__c = dto.incoTerm  ;
            routeObj.Opportunity_Enquiry__c = optyObj.id;
            routeObj.DG_Class__c = dto.dgClass;
            if(!String.isBlank(dto.placeOfPickup)) routeObj.Pickup_Place__c = dto.placeOfPickup;
            if(!String.isBlank(dto.placeOfDischarge)) routeObj.Discharge_Place__c = dto.placeOfDischarge;
            routeObj.id = dto.routeId !='' ? dto.routeId : null;
            system.debug('dto.cargoReadiness '+dto.cargoReadiness);
            if(dto.cargoReadiness != null && !String.isBlank(dto.cargoReadiness)) routeObj.Cargo_Readiness__c = Date.valueOf(dto.cargoReadiness);
            else routeObj.Cargo_Readiness__c = null;
            routeList.add(routeObj);
        }
        if(routeList.size() > 0){
            upsert routeList;
        }        
        for(Route__c obj : routeList){
            routeIndexToIdMap.put(obj.Index__c, obj.Id);
        }
        for(BAFCORoutingDetailsDto dto : routingList){
            for(BAFCORoutingDetailsDto.containerRecord contr : dto.containerRecord){
                Route_Equipment__c routeQuipobj = new Route_Equipment__c();
                routeQuipobj.Length__c = contr.length;
                routeQuipobj.Width__c = contr.width;
                routeQuipobj.Height__c = contr.height;
                routeQuipobj.CBM__c = contr.CBM;
                routeQuipobj.Weight_Kgs__c = contr.Weight;
                routeQuipobj.Stackable__c = contr.stackable;
                routeQuipobj.Palletized__c = contr.palletized;
				routeQuipobj.Units__c = contr.units;
				routeQuipobj.Cargo_Details__c = contr.cargoDetails;       
                routeQuipobj.Route__c = routeIndexToIdMap.get(dto.leadIndex);
                routeQuipobj.id = contr.id != '' ? contr.id : null;
                routeEquipList.add(routeQuipobj);
            }
        }
        if(routeEquipList.size() > 0){
            upsert routeEquipList;
        }
        if(containerRemoveList.size() > 0){
            List<Route_Equipment__c> containerToDel = new List<Route_Equipment__c>();
            for(String dd : containerRemoveList){
                Route_Equipment__c routeQuipobj = new Route_Equipment__c();
                routeQuipobj.id = dd;
                containerToDel.add(routeQuipobj);
            }
            delete containerToDel;
        }
        if(routeRemoveList.size() > 0){
            List<Route__c> routeToDel = new List<Route__c>();
            for(String dd : routeRemoveList){
                Route__c routeObj = new Route__c();
                routeObj.id = dd;
                routeToDel.add(routeObj);
            }
            delete routeToDel;
        }
        return optyObj.id;
    }
    @AuraEnabled
    public static List<Route_Equipment__c> getRouteListOnload(String routeId){
        if(routeId != null){
            return [Select id,Name,Tab_View__c,Quantity__c,Route__r.Opportunity_Enquiry__r.Account.FD__c from Route_Equipment__c where Route__c =: routeId ];
        }
        return null;
    }
    @AuraEnabled 
    public static List<BAFCORoutingDetailsDto> getQuoteLineItemRoute(String quoteId){
        BAFCOReviseQuoteDto dto = new BAFCOReviseQuoteDto();
        Map<String,Quotation_Item__c> mapRouteIdToQuotationItem = new Map<String,Quotation_Item__c>();
        for(Quotation_Item__c item : [SELECT Quotation__r.isAir__c,Route__c,Equipment_Type__c, Shipping_Line__c FROM Quotation_Item__c where Quotation__c =: quoteId Order by CreatedDate]){
            if(!mapRouteIdToQuotationItem.containsKey(item.Route__c)) 
                mapRouteIdToQuotationItem.put(item.Route__c,item);
        }
        List<BAFCORoutingDetailsDto> routingDetailsList = new List<BAFCORoutingDetailsDto>();
        Integer index = 1;
        for(Route__c enqObj : [SELECT Airport_of_Loading__r.name,Airport_of_Destination__r.Name,(Select id, Equipment_Type__r.name,Quantity__c from Route_Equipments__r),Place_of_Discharge__r.Name,Place_of_Pickup__r.Name,Opportunity_Enquiry__c ,Regular_Routing_Lookup__r.name,Port_of_loading__c,Discharge_Place__c,Pickup_Place__c,Id, Regular_Routing__c,INCO_Term__r.name, Kind_Of_Shipment__c, Service_Type__c, Port_of_loading__r.Name, 
                               Port_of_Destination__r.Name, Shipping_Line__r.name, Commodity__r.Name, Cargo_Weight__c, Remarks__c, Name  
                               FROM Route__c WHERE  Id in : mapRouteIdToQuotationItem.keySet()]){
                                   BAFCORoutingDetailsDto enqDtoObj = new BAFCORoutingDetailsDto();
                                   Quotation_Item__c item = mapRouteIdToQuotationItem.get(enqObj.Id);
                                   enqDtoObj.routeName = 'Route '+ index;
                                   enqDtoObj.routingRegular = enqObj.Regular_Routing_Lookup__c != null ? enqObj.Regular_Routing_Lookup__r.name : '-';
                                   enqDtoObj.shipmentKind = enqObj.Kind_Of_Shipment__c != null ? enqObj.Kind_Of_Shipment__c : '-';
                                   enqDtoObj.serviceType = enqObj.Service_Type__c != null ? enqObj.Service_Type__c : '-';
                                   if(item.Quotation__r.isAir__c){
                                       enqDtoObj.portDestination = enqObj.Airport_of_Destination__r.Name != null ? enqObj.Airport_of_Destination__r.Name :'-';
                                       enqDtoObj.portLoading = enqObj.Airport_of_Loading__r.name != null ? enqObj.Airport_of_Loading__r.name : '-';
                                       enqDtoObj.portLoadingId = enqObj.Airport_of_Loading__c;
                                       enqDtoObj.portDestinationId = enqObj.Airport_of_Destination__c;
                                   }
                                   else{
                                       enqDtoObj.portDestination = enqObj.Port_of_Destination__r.Name != null ? enqObj.Port_of_Destination__r.Name :'-';
                                       enqDtoObj.portLoading = enqObj.Port_of_loading__r.name != null ? enqObj.Port_of_loading__r.name : '-';
                                       enqDtoObj.portLoadingId = enqObj.Port_of_loading__c;
                                       enqDtoObj.portDestinationId = enqObj.Port_of_Destination__c;
                                   }
                                   enqDtoObj.commodity = enqObj.Commodity__r.Name != null ? enqObj.Commodity__r.name : '-';
                                   enqDtoObj.cargoWeights = enqObj.Cargo_Weight__c != null ? enqObj.Cargo_Weight__c : 0 ;
                                   enqDtoObj.remarks = enqObj.Remarks__c != null ? enqObj.Remarks__c : '-';
                                   enqDtoObj.routeId = enqObj.Id;
                                   enqDtoObj.shippingLine = enqObj.Shipping_Line__r.name != null ? enqObj.Shipping_Line__r.name : '-';
                                   enqDtoObj.enquiryId = enqObj.Opportunity_Enquiry__c;
                                   enqDtoObj.placeOfPickupName = enqObj.Pickup_Place__c;
                                   enqDtoObj.placeOfDischargeName = enqObj.Discharge_Place__c;
                                   if(enqObj.Route_Equipments__r.size() > 0){
                                       String equipmentType ='';
                                       for(Route_Equipment__c rr : enqObj.Route_Equipments__r){
                                           if(rr.Equipment_Type__c != null){
                                               equipmentType+=rr.Equipment_Type__r.Name+' - '+ rr.Quantity__c;
                                               equipmentType+=', ';
                                           }
                                       }
                                       if(equipmentType != ''){
                                           equipmentType = equipmentType.removeEnd(', ');
                                       }
                                       enqDtoObj.equipmentType = equipmentType;
                                   }
                                   index++;
                                   routingDetailsList.add(enqDtoObj);
                               }
        return routingDetailsList;
    }
    @AuraEnabled
    public static List<BAFCOAllQuotationItemDto> getQuoteLineItem(String quoteId){
        List<BAFCOAllQuotationItemDto> dtoList = new List<BAFCOAllQuotationItemDto>();
        for(Quotation_Item__c item : [SELECT Quotation__r.isLCL__c,Tab_View__c,Buying_Rate__c,Tank_Rental_Charges__c,Included_PDF_ShippingLine__c,Included_PDF_Origin__c,Included_PDF_Destination__c,Included_PDF_Additional__c,Included_PDF_Ex_works__c,Id, Alternate_depot_release_charges__c,Carrier_container_repositioning_charges__c,Freight_Difference_FD__c,Ex_Works_Charge_Name__r.name,Ex_Works_Charge__c,Add_to_Buying_ShippingLine__c,Add_to_Buying_Origin__c,Add_to_Buying_Ex_works__c,Add_to_Buying_Destination__c,Add_to_Buying_Additional__c,Quotation__r.CreatedDate,Name,Agent_Name__c,Equipment_Type__r.name, CurrencyIsoCode, Quotation__c, BAF__c, Bayan__c, Bayan_cancellation_charge__c, Bunker_surcharge__c, CMC__c, Cleaning_charges__c, Container_movement_charges__c, Container_Lashing_Charges__c, Container_stripping__c, DTHC__c, Destination_Customs_Clearance__c, Destination_Loading_Charges__c, EIC__c, Equipment_Type__c, Fasah_fee__c, Free_time_certificate_charges__c, Fumigation__c, ISPS__c, Inspection__c, Insurance_charges__c, Lift_on_Lift_off__c, MOT_fine_charges__c, Ministry_clearnce_charge_for_OOG_cargo__c, Miscellaneous__c, Non_Palletized_Surcharge__c, OTHC__c, Origin_Customs_clearance__c, Origin_Loading_Charges__c, Pest_control__c, Port_Shuttling__c, Port_of_Discharge__c, Port_of_Loading__c, RMS__c, Re_palletization__c, Reefer_PTI_charges__c, Reefer_cntr_plug_in_charges__c, Reefer_steam_wash__c, Route__c, Sea_Freight__c, Seal_Charges__c, Stuffing_Charges__c, SweepingCleaning__c, Tabadul__c, Tarpauline_charge__c, Total_INCO__c, Total_SL__c, Total__c, Truck_Head_charges__c, Truck_idling_charges__c, Vessel_certificate_charges__c, Wrappingpacking_charges__c, Xray__c, Shipping_Line__c, Loading_Charges__c, Carriage_Congestion_Surcharge__c, Carrier_Security_Fees__c, Bayan_Charges__c, BL_Fees__c, DG_Surcharge__c, DO_charges__c, Export_Service_Fees__c, Fasah_Charges__c, Fuel_Surcharge__c, Gate_pass_charges__c, Inland_Fuel_Surcharge__c, Inland_Handling_Fees__c, Inland_haulage__c, Low_Sulphur_Surcharge__c, Operational_Recovery_Surcharge__c, Lashing_Charges__c, LOLO_Charges__c, Origin_Detention_Demurrage_Charges__c, Overweight_surcharge__c, Pickup_Charges__c, Total_Dest__c, War_Risk_Surcharge__c, VGM__c, Total_Additional__c, Charges_Included__c
                                      FROM Quotation_Item__c where Quotation__c =: quoteId]){
                                          BAFCOAllQuotationItemDto itemDto = new BAFCOAllQuotationItemDto();
                                          itemDto = BAFCOQuotationReviseController.assignQuoteItemData(item,itemDto);
                                          itemDto.equipmentName = item.Tab_View__c; 
                                          itemDto.totaladditionalCharge = item.Total_Additional__c;
                                          itemDto.totalBuyingRate = item.Buying_Rate__c;
                                          dtoList.add(itemDto);
       }
        return dtoList;
    }
}