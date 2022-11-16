public class BAFCOSalesOrderController {
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
            for(Route__c routeObj : [SELECT Enquiry__c ,Port_of_loading__c,Place_of_Discharge__c,Place_of_Pickup__c,Id, Regular_Routing__c,INCO_Term__r.name, Kind_Of_Shipment__c, Service_Type__c, Port_of_loading__r.Name, 
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
        for(Route_Equipment__c re : [Select quantity__c, Equipment_Type__r.name from Route_Equipment__c where route__c =:routeId ]){
            mapequipNameToQty.put(re.Equipment_Type__r.name,re.Quantity__c);
        }
        Integer index = 1;
        for(Quotation_Item__c item : [Select BAF__c,Bayan__c,Bayan_cancellation_charge__c,Bunker_surcharge__c,Cleaning_charges__c,
                                      /*Container_Lashing_Charges__c,*/CMC__c,Container_movement_charges__c,Container_stripping__c,
                                      Destination_Customs_Clearance__c,Destination_Loading_Charges__c,DTHC__c,EIC__c,Equipment_Type__c,
                                      Fasah_fee__c,Free_time_certificate_charges__c,Fumigation__c,Inspection__c,Insurance_charges__c,
                                      ISPS__c,Lift_on_Lift_off__c,Loading_Charges__c,Ministry_clearnce_charge_for_OOG_cargo__c,
                                      Miscellaneous__c,MOT_fine_charges__c,Non_Palletized_Surcharge__c,Origin_Customs_clearance__c,
                                      Origin_Loading_Charges__c,OTHC__c,Pest_control__c,Port_of_Discharge__c,Port_of_Loading__c,
                                      Port_Shuttling__c,Re_palletization__c,Reefer_cntr_plug_in_charges__c,Reefer_PTI_charges__c,
                                      Reefer_steam_wash__c,RMS__c,Route__c,Sea_Freight__c,Seal_Charges__c,Stuffing_Charges__c,
                                      SweepingCleaning__c,Tabadul__c,Tarpauline_charge__c,Total_INCO__c,Total_SL__c,Truck_Head_charges__c,
                                      Truck_idling_charges__c,Vessel_certificate_charges__c,Wrappingpacking_charges__c,Xray__c,
                                      Quotation__r.Leadc__c,Quotation__r.Enquiry__c,Quotation__r.Account__c,Total__c,
                                      Shipping_Line__c,Equipment_Type__r.Name 
                                      from Quotation_Item__c 
                                      where Quotation__c =: quoteId 
                                      And Route__c =:routeId]){
                                          system.debug('item.Equipment_Type__c '+item.Equipment_Type__c+' - '+item.Equipment_Type__r.name);
            if(item.Equipment_Type__c != null){
                if(mapequipNameToQty.containsKey(item.Equipment_Type__r.Name)){
                String equipName = item.Equipment_Type__r.Name;
                if(!equipLineToShipData.containsKey(equipName)){
                    equipLineToShipData.put(equipName,new List<EquipData>());
                }
                EquipData dto = new EquipData();
                dto.Qty = mapequipNameToQty.get(item.Equipment_Type__r.Name);
                dto.shipName = item.Shipping_Line__c;
                dto.sellingRate = item.Total__c;
                dto.checkBoxSelected = false;
                dto.accountId = item.Quotation__r.Account__c;
                dto.enquiryId = item.Quotation__r.Enquiry__c;
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
                dto.postOfDischarge =item.Port_of_Discharge__c ;
                dto.postOfLoading =item.Port_of_Loading__c ;
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
                if(item.Total__c > 0) equipLineToShipData.get(equipName).add(dto);
            }
            }
        }
        return equipLineToShipData;
    }
    @AuraEnabled
    public static Order__c createOrder(List<BAFCOOrderCreationDto> orderCreationList, String validityDate){
       // creating order
       Order__c orderObj = new Order__c();
       List<Order_Item__c> orderItemList = new List<Order_Item__c>();
        if(orderCreationList.size() > 0){
            Integer index = -1;
            for(Integer i = 0; i<orderCreationList.size();i++){
                if(orderCreationList[i].equipment.size() > 0) {index = i; break;}
            }
            BAFCOOrderCreationDto firstRouteData = orderCreationList[index];
            BAFCOOrderCreationDto.equipment firstEquipmentData = firstRouteData.equipment[0];
                if(firstEquipmentData.value.size() > 0){
                	BAFCOOrderCreationDto.value orderData = firstEquipmentData.value[0]; 
                    system.debug('orderData '+orderData);
                    orderObj.Account_Order__c = orderData.accountId;
                    orderObj.Enquiry_Order__c = orderData.enquiryId;
                    orderObj.Leadc_Order__c = orderData.leadId;
                    orderObj.Quotation__c = orderData.quotationId;
                    orderObj.Order_Validity__c = date.valueOf(validityDate);
                    insert orderObj;
                }
            // creating OrderItem
            for(BAFCOOrderCreationDto routeDto : orderCreationList){
                if(routeDto.equipment.size()>0){
                    for(BAFCOOrderCreationDto.equipment equipData : routeDto.equipment){
                        for(BAFCOOrderCreationDto.value orderDto : equipData.value){
                            Order_Item__c orderItem =  new Order_Item__c();
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
                            orderItem.Order__c = orderObj.id;
                            orderItem.Origin_Customs_clearance_Order__c=orderDto.originCustomClearance;
                            orderItem.Origin_Loading_Charges_Order__c = orderDto.originloadingCharges;
                            orderItem.OTHC_Order__c = orderDto.othc;
                            orderItem.Pest_control_Order__c = orderDto.pestController;
                            orderItem.Port_of_Discharge_Order__c = orderDto.postOfDischarge;
                            orderItem.Port_of_Loading_Order__c = orderDto.postOfLoading;
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
                            if(orderDto.checkBoxSelected == true) orderItemList.add(orderItem);
                        }
                    }
                }
            }
            if(orderItemList.size()>0){
                insert orderItemList;
            }
        }
        return orderObj;
    }
    public class EquipData{
        @AuraEnabled
        public String shipName { get; set; }
        @AuraEnabled
        public String quotationId { get; set; }
        @AuraEnabled
        public String enquiryId { get; set; }
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
    }
}