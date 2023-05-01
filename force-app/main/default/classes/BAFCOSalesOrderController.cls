public class BAFCOSalesOrderController {
    public static final Id ORDER_EXPORT_RECORDTYPE_Id = Schema.SObjectType.Order__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id ORDER_IMPORT_RECORDTYPE_Id = Schema.SObjectType.Order__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    public static final Id QUOTE_EXPORT_RECORDTYPE_Id = Schema.SObjectType.Quotation__c.getRecordTypeInfosByName()
        .get('Export')
        .getRecordTypeId();
    public static final Id QUOTE_IMPORT_RECORDTYPE_Id = Schema.SObjectType.Quotation__c.getRecordTypeInfosByName()
        .get('Import')
        .getRecordTypeId();
    @AuraEnabled
    public static Map<String,Route__c> getRouteItem(String quoteId){
        Map<String,Route__c> mapRouteNameToItem = new Map<String,Route__c>();
        Map<String,String> mapRouteIdToName = new Map<String,String>();
        Set<Id> routeId = new Set<Id>();
        Integer Index = 1;
        for(Quotation_Item__c item : [Select Route__c from Quotation_Item__c where Quotation__c =: quoteId]){
            routeId.add(item.Route__c);
        }
        if(routeId.size()>0){
            for(Route__c routeObj : [SELECT Cargo_Readiness__c,Opportunity_Enquiry__c ,Port_of_loading__c,/*Place_of_Discharge__c,Place_of_Pickup__c*/Discharge_Place__c,Pickup_Place__c,Id, Regular_Routing__c,INCO_Term__r.name, Kind_Of_Shipment__c, Service_Type__c, Port_of_loading__r.Name, 
                                     Port_of_Destination__r.Name, Shipping_Line__r.name, Commodity__r.Name, Cargo_Weight__c, Remarks__c, Name  
                                     FROM Route__c WHERE  Id in : routeId]){
                                         if(!mapRouteIdToName.containsKey(routeObj.Id)){
                                             mapRouteIdToName.put(routeObj.Id,'Route '+Index++);
                                         }
                                         if(!mapRouteNameToItem.containsKey(mapRouteIdToName.get(routeObj.Id))){
                                             mapRouteNameToItem.put(mapRouteIdToName.get(routeObj.Id),routeObj);
                                         }
                                     }
        }
        return mapRouteNameToItem;
    }
    @AuraEnabled
    public static Map<String,List<EquipData>> getQuoteLineItem(String quoteId,String routeId){
        Map<String,List<EquipData>> equipLineToShipData = new Map<String,List<EquipData>>();
        Map<String,Decimal> mapequipNameToQty = new Map<String,Decimal>();
        Map<String,Decimal> mapDimensionToQty = new Map<String,Decimal>();
        for(Route_Equipment__c re : [Select Tab_View__c,quantity__c, Equipment_Type__r.name from Route_Equipment__c where route__c =:routeId ]){
            mapequipNameToQty.put(re.Equipment_Type__r.name,re.Quantity__c);
            mapDimensionToQty.put(re.Tab_View__c,re.Quantity__c);
        }
        system.debug('mapequipNameToQty '+mapequipNameToQty);
        Integer index = 1;
        for(Quotation_Item__c item : [Select Selling_Charges_Include__c,Quotation__r.Quotation_type__c,Charges_Included__c,Airport_of_Loading__c,Airport_of_Destination__c,Quotation__r.isAir__c,Quotation__r.isLCL__c,Tab_View__c,INCO_Term__c,Tank_Rental_Charges__c,Agent__c,Id,Shipping_Linee__c,Buying_Rate__c,Alternate_depot_release_charges__c,Freight_Difference_FD__c,Carrier_container_repositioning_charges__c,Ex_Works_Charge__c,Ex_Works_Charge_Name__c,Included_PDF_Ex_works__c,Included_PDF_Additional__c,Included_PDF_Destination__c,Included_PDF_Origin__c,Included_PDF_ShippingLine__c,Add_to_Buying_Ex_works__c,Add_to_Buying_Additional__c,Add_to_Buying_Destination__c,Add_to_Buying_Origin__c,Add_to_Buying_ShippingLine__c,BAF__c,Bayan__c,Bayan_cancellation_charge__c,Bunker_surcharge__c,Cleaning_charges__c,
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
                                      Shipping_Line__c,Equipment_Type__r.Name,Pickup_Place__c,Discharge_Place__c   
                                      from Quotation_Item__c 
                                      where Quotation__c =: quoteId 
                                      And Route__c =:routeId]){
                                          system.debug('item.Equipment_Type__c '+item.Equipment_Type__c+' - '+item.Equipment_Type__r.name);
                                          system.debug('item.Quotation__r.isLCL__c '+item.Quotation__r.isLCL__c);
                                          system.debug('item.Quotation__r.isAir__c '+item.Quotation__r.isAir__c);
                                          if(item.Quotation__r.isLCL__c == true || item.Quotation__r.isAir__c == true){
                                              if(mapDimensionToQty.containsKey(item.Tab_View__c)){
                                                  if(!equipLineToShipData.containsKey(item.Tab_View__c)){
                                                      equipLineToShipData.put(item.Tab_View__c,new List<EquipData>());
                                                  }
                                                  EquipData dto = new EquipData();
                                                  //dto.Qty = mapDimensionToQty.get(item.Tab_View__c);
                                                  if(item.Quotation__r.isLCL__c == true) dto.isLCL = true;                                                  
                                                  else if(item.Quotation__r.isAir__c == true) dto.isAir = true;
                                                  system.debug(' dto.Qty '+ dto.Qty);
                                                  
                                                  dto.shipName = '';
                                                  dto = assignquoteItemToDto(dto,item);
                                                  if(item.Total__c > 0) equipLineToShipData.get(item.Tab_View__c).add(dto);
                                              }
                                          }
                                          else{
                                              if(item.Equipment_Type__c != null){
                                                  if(mapequipNameToQty.containsKey(item.Equipment_Type__r.Name)){
                                                      String equipName = item.Equipment_Type__r.Name;
                                                      if(!equipLineToShipData.containsKey(equipName)){
                                                          equipLineToShipData.put(equipName,new List<EquipData>());
                                                      }
                                                      EquipData dto = new EquipData();
                                                      system.debug('here '+mapequipNameToQty.get(item.Equipment_Type__r.Name));
                                                      //dto.Qty = mapequipNameToQty.get(item.Equipment_Type__r.Name);
                                                      dto.isLCL = false;
                                                      system.debug(' dto.Qty '+ dto.Qty);
                                                      if(item.Shipping_Line__c != null){
                                                          dto.shipName = item.Shipping_Line__c+( item.Agent_Name__c != null ? (' - '+item.Agent_Name__c) : '');
                                                      }
                                                      else{
                                                          dto.shipName = '';
                                                      }
                                                      dto = assignquoteItemToDto(dto,item);
                                                      if(item.Total__c > 0) equipLineToShipData.get(equipName).add(dto);
                                                  }
                                              }
                                          }
                                      }
        return equipLineToShipData;
    }
    private static EquipData assignquoteItemToDto(EquipData dto,Quotation_Item__c item){
        dto.sellingChargesIncluded = item.Selling_Charges_Include__c;
        dto.quotationType = item.Quotation__r.Quotation_Type__c;
        dto.sellingRate = item.Total__c;
        dto.chargesIncluded = item.Charges_Included__c;
        dto.checkBoxSelected = false;
        dto.accountId = item.Quotation__r.Account__c;
        dto.enquiryId = item.Quotation__r.Opportunity__c;
        dto.leadId = item.Quotation__r.Leadc__c;
        dto.quotationId = item.Quotation__c;
        dto.equipmentType =item.Equipment_Type__c ;
        dto.rmsID =item.RMS__c;
        dto.routeID=item.Route__c;
        dto.baf = item.BAF__c != null ? item.BAF__c : 0;
        dto.bayan =item.Bayan__c != null ? item.Bayan__c : 0;
        dto.bayanCancellation = item.Bayan_cancellation_charge__c != null ? item.Bayan_cancellation_charge__c : 0;
        dto.bunkerSurcharge = item.Bunker_surcharge__c != null ? item.Bunker_surcharge__c : 0;
        dto.cleaningCharges = item.Cleaning_charges__c != null ? item.Cleaning_charges__c : 0;
        //dto.containerLashing = item.Container_Lashing_Charges__c != null ? item.Container_Lashing_Charges__c : 0;
        dto.containerMaintenance = item.CMC__c != null ? item.CMC__c : 0;
        dto.containerMovement =item.Container_movement_charges__c != null ? item.Container_movement_charges__c : 0;
        dto.containerStripping =item.Container_stripping__c != null ? item.Container_stripping__c : 0;
        dto.destinationCustomClearnace = item.Destination_Customs_Clearance__c != null ? item.Destination_Customs_Clearance__c : 0;
        dto.destinationLoading = item.Destination_Loading_Charges__c != null ? item.Destination_Loading_Charges__c : 0;
        dto.dthc =item.DTHC__c != null ? item.DTHC__c : 0;
        dto.eic =item.EIC__c != null ? item.EIC__c : 0;                
        dto.fasahFee =item.Fasah_fee__c != null ? item.Fasah_fee__c : 0;
        dto.freeTimeCertification =item.Free_time_certificate_charges__c != null ? item.Free_time_certificate_charges__c : 0;
        dto.fumigation =item.Fumigation__c != null ? item.Fumigation__c : 0;
        dto.inspection =item.Inspection__c != null ? item.Inspection__c : 0;
        dto.insurance =item.Insurance_charges__c != null ? item.Insurance_charges__c : 0;
        dto.isps =item.ISPS__c != null ? item.ISPS__c : 0;
        dto.liftOnOff =item.Lift_on_Lift_off__c != null ? item.Lift_on_Lift_off__c : 0;
        dto.loadingCharges =item.Loading_Charges__c != null ? item.Loading_Charges__c : 0;
        dto.ministryClearance =item.Ministry_clearnce_charge_for_OOG_cargo__c != null ? item.Ministry_clearnce_charge_for_OOG_cargo__c : 0;
        dto.miscallenous =item.Miscellaneous__c != null ? item.Miscellaneous__c : 0;
        dto.mot =item.MOT_fine_charges__c != null ? item.MOT_fine_charges__c : 0;
        dto.nonPatellized =item.Non_Palletized_Surcharge__c != null ? item.Non_Palletized_Surcharge__c : 0;
        dto.originCustomClearance =item.Origin_Customs_clearance__c != null ? item.Origin_Customs_clearance__c : 0;
        dto.originloadingCharges =item.Origin_Loading_Charges__c != null ? item.Origin_Loading_Charges__c : 0;
        dto.othc =item.OTHC__c != null ? item.OTHC__c : 0;
        dto.pestController =item.Pest_control__c != null ? item.Pest_control__c : 0;
        if(item.Quotation__r.isAir__c == true){
            dto.postOfDischarge =item.Airport_of_Destination__c ;
        	dto.postOfLoading =item.Airport_of_Loading__c ;
        }
        else{
            dto.postOfDischarge =item.Port_of_Discharge__c ;
            dto.postOfLoading =item.Port_of_Loading__c ;
        }
        dto.portShuttling =item.Port_Shuttling__c != null ? item.Port_Shuttling__c : 0;
        dto.rePalletization =item.Re_palletization__c != null ? item.Re_palletization__c : 0;
        dto.refeerCentr =item.Reefer_cntr_plug_in_charges__c != null ? item.Reefer_cntr_plug_in_charges__c : 0;
        dto.refeerPTI =item.Reefer_PTI_charges__c != null ? item.Reefer_PTI_charges__c : 0;
        dto.refeerSteamWash =item.Reefer_steam_wash__c != null ? item.Reefer_steam_wash__c : 0;                
        dto.seaFreight=item.Sea_Freight__c != null ? item.Sea_Freight__c : 0;
        dto.sealCharges=item.Seal_Charges__c != null ? item.Seal_Charges__c : 0;
        dto.stuffingCharges=item.Stuffing_Charges__c != null ? item.Stuffing_Charges__c : 0;
        dto.sweepingCleaning=item.SweepingCleaning__c != null ? item.SweepingCleaning__c : 0;
        dto.tabadul=item.Tabadul__c != null ? item.Tabadul__c : 0;
        dto.tarapulin=item.Tarpauline_charge__c != null ? item.Tarpauline_charge__c : 0;
        dto.totalInco=item.Total_INCO__c != null ? item.Total_INCO__c : 0;
        dto.totalSL=item.Total_SL__c != null ? item.Total_SL__c : 0;
        dto.truckHead=item.Truck_Head_charges__c != null ? item.Truck_Head_charges__c : 0;
        dto.truckIdealing=item.Truck_idling_charges__c != null ? item.Truck_idling_charges__c : 0;
        dto.vesselCertificate=item.Vessel_certificate_charges__c != null ? item.Vessel_certificate_charges__c : 0;
        dto.wrappingPacking=item.Wrappingpacking_charges__c != null ? item.Wrappingpacking_charges__c : 0;
        dto.xRay=item.Xray__c != null ? item.Xray__c : 0;
        dto.recordtypeId = item.Quotation__r.RecordtypeId;
        
        //Added field
        dto.bayanCharges = item.Bayan_Charges__c != null ? item.Bayan_Charges__c : 0;
        dto.blFees = item.BL_Fees__c != null ? item.BL_Fees__c : 0;
        dto.carriageCongestionSurcharge = item.Carriage_Congestion_Surcharge__c != null ? item.Carriage_Congestion_Surcharge__c : 0;
        dto.dgSurcharge = item.DG_Surcharge__c != null ? item.DG_Surcharge__c : 0;
        dto.exportServiceFees = item.Export_Service_Fees__c != null ? item.Export_Service_Fees__c : 0;
        dto.fasahCharges = item.Fasah_Charges__c != null ? item.Fasah_Charges__c : 0;
        dto.fuelSurcharges = item.Fuel_Surcharge__c != null ? item.Fuel_Surcharge__c : 0;
        dto.gatePassCharges = item.Gate_pass_charges__c != null ? item.Gate_pass_charges__c : 0;
        dto.inlandFuelSurcharges = item.Inland_Fuel_Surcharge__c != null ? item.Inland_Fuel_Surcharge__c : 0;
        dto.inlandHandlingFees = item.Inland_Handling_Fees__c != null ? item.Inland_Handling_Fees__c : 0;
        dto.inlandHaulage = item.Inland_haulage__c != null ? item.Inland_haulage__c : 0;
        dto.lowSulpherSurcharge = item.Low_Sulphur_Surcharge__c != null ? item.Low_Sulphur_Surcharge__c : 0;
        dto.operationalRecoverySurcharge = item.Operational_Recovery_Surcharge__c != null ? item.Operational_Recovery_Surcharge__c : 0;
        dto.lashingCharges = item.Lashing_Charges__c != null ? item.Lashing_Charges__c : 0;
        dto.originDetentionCharges = item.Origin_Detention_Demurrage_Charges__c != null ? item.Origin_Detention_Demurrage_Charges__c : 0;
        dto.overWeightSurcharge = item.Overweight_surcharge__c != null ? item.Overweight_surcharge__c : 0;
        dto.pickupCharges = item.Pickup_Charges__c != null ? item.Pickup_Charges__c : 0;
        dto.totalDestination = item.Total_Dest__c != null ? item.Total_Dest__c : 0;
        dto.vgm = item.VGM__c != null ? item.VGM__c : 0;
        dto.warRiskCharges = item.War_Risk_Surcharge__c != null ? item.War_Risk_Surcharge__c : 0;
        dto.totalAdditional = item.Total_Additional__c != null ? item.Total_Additional__c : 0;
        dto.remarksAdditionalCharges = item.Remarks_Additional_Charges__c != null ? item.Remarks_Additional_Charges__c : '';
        dto.remarksDesinationCharges = item.Remarks_Destination_Charges__c != null ? item.Remarks_Destination_Charges__c : '';
        dto.remarksoriginCharges = item.Remarks_Origin_Charges__c != null ? item.Remarks_Origin_Charges__c : '';
        dto.remarksSLCharges = item.Remarks_SL_Charges__c != null ? item.Remarks_SL_Charges__c : '';
        dto.containerLashingCharges = item.Container_Lashing_Charges__c != null ? item.Container_Lashing_Charges__c : 0;
        dto.dOcharges = item.DO_charges__c != null ? item.DO_charges__c : 0;
        dto.lOLOCharges = item.LOLO_Charges__c != null ? item.LOLO_Charges__c : 0;
        dto.carrierSecurityFees = item.Carrier_Security_Fees__c != null ? item.Carrier_Security_Fees__c : 0;
        dto.pickupPlace = item.Pickup_Place__c;
        dto.dischargePlace = item.Discharge_Place__c;
        
        dto.addServiceCharge = item.Add_to_Buying_ShippingLine__c;
        dto.addOriginCharge = item.Add_to_Buying_Origin__c;
        dto.addDestinCharge = item.Add_to_Buying_Destination__c;
        dto.addAdditionalCharge = item.Add_to_Buying_Additional__c;
        dto.addExWorksCharge = item.Add_to_Buying_Ex_works__c;
        dto.includeServiceCharge = item.Included_PDF_ShippingLine__c;
        dto.includeOriginCharge = item.Included_PDF_Origin__c;
        dto.includeDestinCharge = item.Included_PDF_Destination__c;
        dto.includeAdditionalCharge = item.Included_PDF_Additional__c;
        dto.includeExWorksCharge = item.Included_PDF_Ex_works__c;
        dto.exWorksId = item.Ex_Works_Charge_Name__c;
        dto.exWorksCharge = item.Ex_Works_Charge__c;
        dto.AlternateDepotReleaseCharges = item.Alternate_depot_release_charges__c > 0 ? item.Alternate_depot_release_charges__c : 0;
        dto.FreightDifference = item.Freight_Difference_FD__c > 0 ? item.Freight_Difference_FD__c : 0;
        dto.CarrierContainerRepositioningCharges = item.Carrier_container_repositioning_charges__c > 0 ? item.Carrier_container_repositioning_charges__c : 0;
        dto.orderBuyingRate = item.Buying_Rate__c > 0 ? item.Buying_Rate__c : 0;
        dto.tankRentalCharge = item.Tank_Rental_Charges__c > 0? item.Tank_Rental_Charges__c : 0;
        dto.shippLine = item.Shipping_Linee__c;
        dto.quoteItemId = item.id;
        dto.incoTermId = item.INCO_Term__c;
        dto.agentId = item.Agent__c;
        return dto;
    }
    @AuraEnabled
    public static Order__c createOrder(List<BAFCOOrderCreationDto> orderCreationList, String validityDate, String custRefNumber, String bookRefNumber, List<consigneeList> consigneeList, List<shipperList> shipperList){
        Map<String,List<BAFCOOrderCreationDto.value>> routeIdToValueMap = new Map<String,List<BAFCOOrderCreationDto.value>>();
        Map<String,String> orderIdToOrderData = new  Map<String,String>();
        List<Order_Item__c> orderItemList = new  List<Order_Item__c>();
        list<Order__c> orderList = new List<Order__c>();
        if(orderCreationList.size() > 0){
            for(BAFCOOrderCreationDto dto : orderCreationList){
                for(BAFCOOrderCreationDto.equipment item  : dto.equipment){
                    for(BAFCOOrderCreationDto.value vv : item.value){
                        if(!routeIdToValueMap.containsKey(vv.routeID+'-'+vv.shippLine)){
                            routeIdToValueMap.put(vv.routeID+'-'+vv.shippLine,new List<BAFCOOrderCreationDto.value>());
                        }
                        routeIdToValueMap.get(vv.routeID+'-'+vv.shippLine).add(vv);
                    }
                }                
            }
        }
        for(String key : routeIdToValueMap.keySet()){
            List<BAFCOOrderCreationDto.value> valueList = routeIdToValueMap.get(key);
            if(valueList.size() > 0){
                BAFCOOrderCreationDto.value orderData =valueList[0];
                Order__c orderObj = new Order__c();
                orderObj.Account_Order__c = orderData.accountId;
                orderObj.Opportunity_Order__c = orderData.enquiryId;
                orderObj.Leadc_Order__c = orderData.leadId;
                orderObj.Quotation__c = orderData.quotationId;
                orderObj.Order_Validity__c = date.valueOf(validityDate);
                orderObj.recordtypeId = orderData.recordtypeId == QUOTE_EXPORT_RECORDTYPE_Id ? ORDER_EXPORT_RECORDTYPE_Id : ORDER_IMPORT_RECORDTYPE_Id;
                orderObj.Customer_Reference_Number__c = custRefNumber;
                orderObj.Booking_Reference_Number__c = bookRefNumber;
                orderObj.Order_Item_Link__c = key;
                orderObj.isLCL__c = orderData.isLCL == true ? true : false;
                orderObj.isAir__c = orderData.isAir == true ? true : false;
                orderObj.Order_Type__c = orderData.quotationType;
                orderList.add(orderObj);
            }
        }
        if(orderList.size() > 0){
            insert orderList;
            for(Order__c ord : orderList){
                orderIdToOrderData.put(ord.Order_Item_Link__c,ord.Id);
            }
            for(BAFCOOrderCreationDto routeDto : orderCreationList){
                if(routeDto.equipment.size()>0){
                    for(BAFCOOrderCreationDto.equipment equipData : routeDto.equipment){
                        for(BAFCOOrderCreationDto.value orderDto : equipData.value){
                            Order_Item__c orderItem =  new Order_Item__c();
                            if(orderDto.isLCL == true || orderDto.isAir == true) orderItem.Tab_View__c = orderDto.tabView;
                            orderItem.BAF_Order__c = orderDto.baf;
                            orderItem.Bayan_Order__c = orderDto.bayan;
                            orderItem.Bayan_cancellation_charge_Order__c = orderDto.bayanCancellation;
                            orderItem.Bunker_surcharge_Order__c = orderDto.bunkerSurcharge;
                            orderItem.Cleaning_charges_Order__c = orderDto.cleaningCharges;
                            orderItem.Container_Lashing_Charges_Order__c = orderDto.containerLashing;
                            orderItem.CMC_Order__c = orderDto.containerMaintenance;
                            orderITem.Container_movement_charges_Order__c = orderDto.containerMovement;
                            orderItem.Container_stripping_Order__c = orderDto.containerStripping;
                            orderItem.Destination_Customs_Clearance_Order__c  =orderDto.destinationCustomClearnace;
                            orderItem.Destination_Loading_Charges_Order__c = orderDto.destinationLoading;
                            orderItem.DTHC_Order__c = orderDto.dthc;
                            orderItem.EIC_Order__c = orderDto.eic;
                            orderItem.Route__c = orderDto.routeID;
                            orderITem.Equipment_Type_Order__c = orderDto.equipmentType;
                            orderItem.Fasah_fee_Order__c = orderDto.fasahFee;
                            orderItem.Free_time_certificate_charges_Order__c = orderDto.freeTimeCertification;
                            orderItem.Fumigation_Order__c =orderDto.fumigation;
                            orderItem.Inspection_Order__c = orderDto.inspection;
                            orderItem.Insurance_charges_Order__c = orderDto.insurance;
                            orderItem.ISPS_Order__c = orderDto.isps;
                            orderItem.Lift_on_Lift_off_Order__c = orderDto.liftOnOff;
                            orderItem.Loading_Charges_Order__c = orderDto.loadingCharges;
                            orderItem.MCCFOOGC_Order__c = orderDto.ministryClearance;
                            orderItem.Miscellaneous_Order__c = orderDto.miscallenous;
                            orderItem.MOT_fine_charges_Order__c = orderDto.mot;
                            orderItem.Non_Palletized_Surcharge_Order__c = orderDto.nonPatellized;
                            orderItem.Order__c = orderIdToOrderData.get(orderDto.routeID+'-'+orderDto.shippLine);
                            orderItem.Origin_Customs_clearance_Order__c=orderDto.originCustomClearance;
                            orderItem.Origin_Loading_Charges_Order__c = orderDto.originloadingCharges;
                            orderItem.OTHC_Order__c = orderDto.othc;
                            orderItem.Pest_control_Order__c = orderDto.pestController;
                            if(orderDto.isAir == true){
                                orderItem.Airport_of_Destination__c = orderDto.postOfDischarge;
                                orderItem.Airport_of_Loading__c = orderDto.postOfLoading;
                            }
                            else{
                                orderItem.Port_of_Discharge_Order__c = orderDto.postOfDischarge;
                                orderItem.Port_of_Loading_Order__c = orderDto.postOfLoading;
                            }
                            orderitem.Port_Shuttling_Order__c = orderDto.portShuttling;
                            orderItem.Re_palletization_Order__c = orderDto.rePalletization;
                            orderItem.Reefer_cntr_plug_in_charges_Order__c = orderDto.refeerCentr;
                            orderItem.Reefer_PTI_charges_Order__c = orderDto.refeerPTI;
                            orderItem.Reefer_steam_wash_Order__c = orderDto.refeerSteamWash;
                            orderItem.RMS_Order__c = orderDto.rmsID;
                            orderItem.Route_Order__c = orderDto.routeID;
                            orderItem.Sea_Freight_Order__c = orderDto.seaFreight;
                            orderItem.Seal_Charges_Order__c = orderDto.sealCharges;
                            orderItem.Stuffing_Charges_Order__c = orderDto.stuffingCharges;
                            orderItem.Sweeping_Cleaning_Order__c = orderDto.sweepingCleaning;
                            orderItem.Tabadul_Order__c = orderDto.tabadul;
                            orderItem.Tarpauline_charge_Order__c = orderDto.tarapulin;
                            orderItem.Total_INCO_Order__c = orderDto.totalInco;
                            orderItem.Total_Order__c = orderDto.sellingRate;
                            orderItem.Total_SL_Order__c = orderDto.totalSL;
                            orderItem.Truck_Head_charges_Order__c = orderDto.truckHead;
                            orderItem.Truck_idling_charges_Order__c = orderDto.truckIdealing;
                            orderItem.Vessel_certificate_charges_Order__c = orderDto.vesselCertificate;
                            orderItem.Wrapping_packing_charges_Order__c = orderDto.wrappingPacking;
                            orderItem.Xray_Order__c = orderDto.xRay;
                            orderItem.Quantity__c = orderDto.Qty;
                            
                            orderItem.Bayan_Charges__c = orderDto.bayanCharges;
                            orderItem.BL_Fees__c = orderDto.blFees;
                            orderItem.Carriage_Congestion_Surcharge__c = orderDto.carriageCongestionSurcharge;
                            orderItem.DG_Surcharge__c = orderDto.dgSurcharge;
                            orderItem.Export_Service_Fees__c = orderDto.exportServiceFees;
                            orderItem.Fasah_Charges__c = orderDto.fasahCharges;
                            orderItem.Fuel_Surcharge__c = orderDto.fuelSurcharges;
                            orderItem.Gate_pass_charges__c = orderDto.gatePassCharges;
                            orderItem.Inland_Fuel_Surcharge__c = orderDto.inlandFuelSurcharges;
                            orderItem.Inland_Handling_Fees__c = orderDto.inlandHandlingFees;
                            orderItem.Inland_haulage__c = orderDto.inlandHaulage;
                            orderItem.Low_Sulphur_Surcharge__c = orderDto.lowSulpherSurcharge;
                            orderItem.Operational_Recovery_Surcharge__c = orderDto.operationalRecoverySurcharge;
                            orderItem.Lashing_Charges__c = orderDto.lashingCharges;
                            orderItem.Origin_Detention_Demurrage_Charges__c = orderDto.originDetentionCharges;
                            orderItem.Overweight_Overheight_surcharge__c = orderDto.overWeightSurcharge;
                            orderItem.Pickup_Charges__c = orderDto.pickupCharges;
                            orderItem.Total_Destination_c__c = orderDto.totalDestination;
                            orderItem.VGM__c = orderDto.vgm;
                            orderItem.War_Risk_Surcharge__c = orderDto.warRiskCharges;
                            orderItem.Total_Additional__c = orderDto.totalAdditional;
                            orderItem.Remarks_Additional_Charges__c = orderDto.remarksAdditionalCharges;
                            orderItem.Remarks_Destination_Charges__c = orderDto.remarksDesinationCharges;
                            orderItem.Remarks_Origin_Charges__c = orderDto.remarksoriginCharges;
                            orderItem.Remarks_SL_Charges__c = orderDto.remarksSLCharges;
                            orderitem.Container_Lashing_Charges_Order__c = orderDto.containerLashingCharges;
                            orderitem.DO_charges__c = orderDto.dOcharges;
                            orderitem.LOLO_Charges__c = orderDto.lOLOCharges;
                            orderitem.Carrier_Security_Fees__c = orderDto.carrierSecurityFees;
                            orderitem.Pickup_Place__c = orderDto.pickupPlace;
                            orderitem.Discharge_Place__c = orderDto.dischargePlace;
                            orderitem.Add_to_Buying_ShippingLine__c = orderDto.addServiceCharge;
                            orderitem.Add_to_Buying_Origin__c = orderDto.addOriginCharge;
                            orderitem.Add_to_Buying_Destination__c = orderDto.addDestinCharge;
                            orderitem.Add_to_Buying_Additional__c = orderDto.addAdditionalCharge;
                            orderitem.Add_to_Buying_Ex_works__c = orderDto.addExWorksCharge;
                            orderitem.Included_PDF_ShippingLine__c = orderDto.includeServiceCharge ;
                            orderitem.Included_PDF_Origin__c = orderDto.includeOriginCharge;
                            orderitem.Included_PDF_Destination__c = orderDto.includeDestinCharge;
                            orderitem.Included_PDF_Additional__c = orderDto.includeAdditionalCharge;
                            orderitem.Included_PDF_Ex_works__c = orderDto.includeExWorksCharge;
                            orderitem.Ex_Works_Charge_Name__c = orderDto.exWorksId;
                            orderitem.Ex_Works_Charge__c = orderDto.exWorksCharge;
                            orderitem.Alternate_depot_release_charges__c = orderDto.AlternateDepotReleaseCharges;
                            orderitem.Freight_Difference_FD__c = orderDto.FreightDifference;
                            orderitem.Carrier_container_repositioning_charges__c = orderDto.CarrierContainerRepositioningCharges ;
                            orderitem.Buying_Rate__c = orderDto.orderBuyingRate;
                            orderitem.Tank_Rental_Charges__c = orderDto.tankRentalCharge;
                            orderItem.Shipping_Line__c = orderDto.shippLine;
                            orderItem.Quotation_Item__c = orderDto.quoteItemId;
                            orderItem.Agent__c = orderDto.agentId;
                            orderItem.INCO_Term__c = orderDto.incoTermId;
                            orderItem.Charges_Included__c = orderDto.chargesIncluded;
                            orderItem.Selling_Charges_Included__c = orderDto.sellingChargesIncluded;
                            if(orderDto.checkBoxSelected == true) orderItemList.add(orderItem);
                        }
                    }
                }
            }
            ////
            system.debug('orderItemList '+orderItemList.size());
            if(orderItemList.size()>0){
                insert orderItemList;
                List<Consignee__c> conList = new List<Consignee__c>();
                List<Shipper__c> shipList = new List<Shipper__c>();
                for(Order_Item__c item : orderItemList){
                    if(consigneeList.size() > 0){
                        for(consigneeList consObj : consigneeList){
                            if(consObj.consigneeId != null){
                                Consignee__c coObj = new Consignee__c();
                                //coObj.name= consObj.consigneeName;
                                coObj.Consignee__c=consObj.consigneeId;
                                coObj.Order_Item__c = item.id;
                                conList.add(coObj);
                            }
                        }
                    }
                    if(shipperList.size() > 0){
                        for(shipperList ssObj : shipperList){
                            Shipper__c shipObj = new Shipper__c();
                            //shipObj.name =ssObj.shipperName;
                            shipObj.Shipper__c = ssObj.shipperId;
                            shipObj.Order_Item__c= item.id;
                            shipList.add(shipObj);
                        }
                    }
                }
                if(conList.size() > 0) insert conList;
                if(shipList.size() > 0) insert shipList;
            }
        } 
        if(orderList.size() > 0){
            return orderList[0];
        }
        return null;
    }
    public class EquipData{
        @AuraEnabled
        public String quotationType { get; set; }
        @AuraEnabled
        public String shipName { get; set; }
        @AuraEnabled
        public Boolean isLCL { get; set; }
        @AuraEnabled
        public Boolean isAir { get; set; }
        @AuraEnabled
        public String recordtypeId { get; set; }
        @AuraEnabled
        public String chargesIncluded { get; set; }
        @AuraEnabled
        public String quotationId { get; set; }
        @AuraEnabled
        public String enquiryId { get; set; }
        @AuraEnabled
        public String sellingChargesIncluded { get; set; }
        @AuraEnabled
        public String accountId { get; set; }
        @AuraEnabled
        public String leadId { get; set; }
        @AuraEnabled
        public Decimal sellingRate { get; set; }
        @AuraEnabled
        public Decimal baf { get; set; }
        @AuraEnabled
        public Decimal bayan { get; set; }
        @AuraEnabled
        public Decimal bayanCancellation { get; set; }
        @AuraEnabled
        public Decimal bunkerSurcharge { get; set; }
        @AuraEnabled
        public Decimal cleaningCharges { get; set; }
        @AuraEnabled
        public Decimal containerLashing { get; set; }
        @AuraEnabled
        public Decimal containerMaintenance { get; set; }
        @AuraEnabled
        public Decimal containerMovement { get; set; }
        @AuraEnabled
        public Decimal containerStripping { get; set; }
        @AuraEnabled
        public Decimal destinationCustomClearnace { get; set; }
        @AuraEnabled
        public Decimal destinationLoading { get; set; }
        @AuraEnabled
        public Decimal dthc { get; set; }
        @AuraEnabled
        public Decimal eic { get; set; }
        @AuraEnabled
        public String equipmentType { get; set; }
        @AuraEnabled
        public Decimal fasahFee { get; set; }
        @AuraEnabled
        public Decimal freeTimeCertification { get; set; }
        @AuraEnabled
        public Decimal fumigation { get; set; }
        @AuraEnabled
        public Decimal inspection { get; set; }
        @AuraEnabled
        public Decimal insurance { get; set; }
        @AuraEnabled
        public Decimal isps { get; set; }
        @AuraEnabled
        public Decimal liftOnOff { get; set; }
        @AuraEnabled
        public Decimal loadingCharges { get; set; }
        @AuraEnabled
        public Decimal ministryClearance { get; set; }
        @AuraEnabled
        public Decimal miscallenous { get; set; }
        @AuraEnabled
        public Decimal mot { get; set; }
        @AuraEnabled
        public Decimal nonPatellized { get; set; }
        @AuraEnabled
        public Decimal originCustomClearance { get; set; }
        @AuraEnabled
        public Decimal originloadingCharges { get; set; }
        @AuraEnabled
        public Decimal othc { get; set; }
        @AuraEnabled
        public Decimal pestController { get; set; }
        @AuraEnabled
        public String postOfDischarge { get; set; }
        @AuraEnabled
        public String postOfLoading { get; set; }
        @AuraEnabled
        public Decimal portShuttling { get; set; }
        @AuraEnabled
        public Decimal rePalletization { get; set; }
        @AuraEnabled
        public Decimal refeerCentr { get; set; }
        @AuraEnabled
        public Decimal refeerPTI { get; set; }
        @AuraEnabled
        public Decimal refeerSteamWash { get; set; }
        @AuraEnabled
        public String rmsID{ get; set; }
        @AuraEnabled
        public String routeID{ get; set; }
        @AuraEnabled
        public Decimal seaFreight{ get; set; }
        @AuraEnabled
        public Decimal sealCharges{ get; set; }
        @AuraEnabled
        public Decimal stuffingCharges{ get; set; }
        @AuraEnabled
        public Decimal sweepingCleaning{ get; set; }
        @AuraEnabled
        public Decimal tabadul{ get; set; }
        @AuraEnabled
        public Decimal tarapulin{ get; set; }
        @AuraEnabled
        public Decimal totalInco{ get; set; }
        @AuraEnabled
        public Decimal totalSL{ get; set; }
        @AuraEnabled
        public Decimal truckHead{ get; set; }
        @AuraEnabled
        public Decimal truckIdealing{ get; set; }
        @AuraEnabled
        public Decimal vesselCertificate{ get; set; }
        @AuraEnabled
        public Decimal wrappingPacking{ get; set; }
        @AuraEnabled
        public Decimal Qty{ get; set; }
        @AuraEnabled
        public Decimal xRay{ get; set; }
        @AuraEnabled
        public Boolean checkBoxSelected { get; set; }
        
        
        @AuraEnabled public Decimal bayanCharges{ get; set; }
        @AuraEnabled public Decimal blFees{ get; set; }
        @AuraEnabled public Decimal carriageCongestionSurcharge{ get; set; }
        @AuraEnabled public Decimal dgSurcharge{ get; set; }
        @AuraEnabled public Decimal exportServiceFees{ get; set; }
        @AuraEnabled public Decimal fasahCharges{ get; set; }
        @AuraEnabled public Decimal fuelSurcharges{ get; set; }
        @AuraEnabled public Decimal gatePassCharges{ get; set; }
        @AuraEnabled public Decimal inlandFuelSurcharges{ get; set; }
        @AuraEnabled public Decimal inlandHandlingFees{ get; set; }
        @AuraEnabled public Decimal inlandHaulage{ get; set; }
        @AuraEnabled public Decimal lowSulpherSurcharge{ get; set; }
        @AuraEnabled public Decimal operationalRecoverySurcharge{ get; set; }
        @AuraEnabled public Decimal lashingCharges{ get; set; }
        @AuraEnabled public Decimal originDetentionCharges{ get; set; }
        @AuraEnabled public Decimal overWeightSurcharge{ get; set; }
        @AuraEnabled public Decimal pickupCharges{ get; set; }
        @AuraEnabled public Decimal totalDestination{ get; set; }
        @AuraEnabled public Decimal vgm{ get; set; }
        @AuraEnabled public Decimal warRiskCharges{ get; set; }
        @AuraEnabled public Decimal totalAdditional{ get; set; }
        @AuraEnabled public String remarksAdditionalCharges{ get; set; }
        @AuraEnabled public String remarksDesinationCharges{ get; set; }
        @AuraEnabled public String remarksoriginCharges{ get; set; }
        @AuraEnabled public String remarksSLCharges{ get; set; }
        
        @AuraEnabled public Decimal containerLashingCharges{ get; set; }
        @AuraEnabled public Decimal dOcharges{ get; set; }
        @AuraEnabled public Decimal lOLOCharges{ get; set; }
        @AuraEnabled public Decimal carrierSecurityFees{ get; set; }
        @AuraEnabled public String pickupPlace { get; set; }
        @AuraEnabled public String dischargePlace { get; set; }
        @AuraEnabled public boolean addServiceCharge {get;set;}
        @AuraEnabled public boolean addOriginCharge {get;set;}
        @AuraEnabled public boolean addDestinCharge {get;set;}
        @AuraEnabled public boolean addAdditionalCharge {get;set;}
        @AuraEnabled public boolean addExWorksCharge {get;set;}
        @AuraEnabled public boolean includeServiceCharge {get;set;}
        @AuraEnabled public boolean includeOriginCharge {get;set;}
        @AuraEnabled public boolean includeDestinCharge {get;set;}
        @AuraEnabled public boolean includeAdditionalCharge {get;set;}
        @AuraEnabled public boolean includeExWorksCharge {get;set;}
        @AuraEnabled public String exWorksId {get;set;}
        @AuraEnabled public Decimal exWorksCharge {get;set;}
        @AuraEnabled public decimal AlternateDepotReleaseCharges {get; set;}
        @AuraEnabled public decimal FreightDifference {get; set;}
        @AuraEnabled public decimal CarrierContainerRepositioningCharges {get; set;}
        @AuraEnabled public decimal orderBuyingRate {get; set;}
        @AuraEnabled public decimal tankRentalCharge {get; set;}
        @AuraEnabled public String shippLine {get; set;}
        @AuraEnabled public String quoteItemId {get; set;}
        @AuraEnabled public String agentId {get; set;}
        @AuraEnabled public String incoTermId { get; set; }
    }
    public class consigneeList{
        @AuraEnabled public String consigneeId {get; set;}
        @AuraEnabled public String consigneeName {get; set;}
    }
    public class shipperList{
        @AuraEnabled public String shipperId {get; set;}
        @AuraEnabled public String shipperName {get; set;}
    }
}