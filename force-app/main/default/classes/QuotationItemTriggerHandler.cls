public class QuotationItemTriggerHandler {
    public static void updateChargesIncluded(List<Quotation_Item__c> quoteItemList){
        for(Quotation_Item__c quote:quoteItemList){
            String chargesIncluded = '';
            //Shipping Line Charges Computation
            if(quote.BAF__c!=0.0 && quote.BAF__c!=NULL){
                chargesIncluded +='BAF : '+quote.BAF__c + quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Bunker_surcharge__c!=0.0 && quote.Bunker_surcharge__c!=NULL){
                chargesIncluded +='Bunker surcharge : '+quote.Bunker_surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Cleaning_charges__c!=0.0 && quote.Cleaning_charges__c	!=NULL){
                chargesIncluded +='Cleaning Charges : '+quote.Cleaning_charges__c	 +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.CMC__c!=0.0 && quote.CMC__c!=null){
                chargesIncluded +='Container Maintenance Charge : '+quote.CMC__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Carriage_Congestion_Surcharge__c!=0.0 && quote.Carriage_Congestion_Surcharge__c!=NULL){
                chargesIncluded +='Carriage Congestion Surcharge : '+quote.Carriage_Congestion_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Carrier_Security_Fees__c	!=0.0 && quote.Carrier_Security_Fees__c	!=NULL){
                chargesIncluded +='Carrier Security Fees : '+quote.Carrier_Security_Fees__c	 +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.DG_Surcharge__c!=0.0 && quote.DG_Surcharge__c!=NULL){
                chargesIncluded +='DG Surcharge : '+quote.DG_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.DTHC__c!=0.0 && quote.DTHC__c!=NULL){
                chargesIncluded +='DTHC : '+quote.DTHC__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.EIC__c!=0.0 && quote.EIC__c!=NULL){
                chargesIncluded +='Equipment Imbalance Charge : '+quote.EIC__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Inland_Fuel_Surcharge__c!=0.0 && quote.Inland_Fuel_Surcharge__c!=NULL){
                chargesIncluded +='Inland Fuel Surcharge : '+quote.Inland_Fuel_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Inland_Handling_Fees__c!=0.0 && quote.Inland_Handling_Fees__c!=NULL){
                chargesIncluded +='Inland Handling Fees : '+quote.Inland_Handling_Fees__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Inland_haulage__c!=0.0 && quote.Inland_haulage__c!=NULL){
                chargesIncluded +='Inland haulage : '+quote.Inland_haulage__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.ISPS__c!=0.0 && quote.ISPS__c!=NULL){
                chargesIncluded +='ISPS : '+quote.ISPS__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Low_Sulphur_Surcharge__c!=0.0 && quote.Low_Sulphur_Surcharge__c!=NULL){
                chargesIncluded +='Low Sulphur Surcharge : '+quote.Low_Sulphur_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Operational_Recovery_Surcharge__c!=0.0 && quote.Operational_Recovery_Surcharge__c!=NULL){
                chargesIncluded +='Operational Recovery Surcharge : '+quote.Operational_Recovery_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.OTHC__c!=0.0 && quote.OTHC__c!=NULL){
                chargesIncluded +='OTHC : '+quote.OTHC__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Overweight_surcharge__c!=0.0 && quote.Overweight_surcharge__c!=NULL){
                chargesIncluded +='Overweight/Overheight surcharge : '+quote.Overweight_surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Seal_Charges__c!=0.0 && quote.Seal_Charges__c!=NULL){
                chargesIncluded +='Seal Charges : '+quote.Seal_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.War_Risk_Surcharge__c!=0.0 && quote.War_Risk_Surcharge__c!=NULL){
                chargesIncluded +='War Risk Surcharge : '+quote.War_Risk_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            
            //Origin Charges Computation
            if(quote.BAF__c!=0.0 && quote.BAF__c!=NULL){
                chargesIncluded +='BAF : '+quote.BAF__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.BL_Fees__c!=0.0 && quote.BL_Fees__c!=NULL){
                chargesIncluded +='BL Fees : '+quote.BL_Fees__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Origin_Customs_clearance__c!=0.0 && quote.Origin_Customs_clearance__c!=NULL){
                chargesIncluded +='Origin Customs clearance : '+quote.Origin_Customs_clearance__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Export_Service_Fees__c!=0.0 && quote.Export_Service_Fees__c!=NULL){
                chargesIncluded +='Export Service Fees : '+quote.Export_Service_Fees__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Fasah_fee__c!=0.0 && quote.Fasah_fee__c!=NULL){
                chargesIncluded +='Fasah Fee : '+quote.Fasah_fee__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Fuel_Surcharge__c	!=0.0 && quote.Fuel_Surcharge__c	!=NULL){
                chargesIncluded +='Fuel Surcharge : '+quote.Fuel_Surcharge__c	 +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Inspection__c!=0.0 && quote.Inspection__c!=NULL){
                chargesIncluded +='Inspection : '+quote.Inspection__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Insurance_charges__c!=0.0 && quote.Insurance_charges__c!=NULL){
                chargesIncluded +='Insurance charges : '+quote.Insurance_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Lashing_Charges__c!=0.0 && quote.Lashing_Charges__c!=NULL){
                chargesIncluded +='Lashing Charges : '+quote.Lashing_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Lift_on_Lift_off__c!=0.0 && quote.Lift_on_Lift_off__c!=NULL){
                chargesIncluded +='Lift on-Lift off : '+quote.Lift_on_Lift_off__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Origin_Detention_Demurrage_Charges__c!=0.0 && quote.Origin_Detention_Demurrage_Charges__c!=NULL){
                chargesIncluded +='Origin Detention/Demurrage Charges : '+quote.Origin_Detention_Demurrage_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Origin_Loading_Charges__c!=0.0 && quote.Origin_Loading_Charges__c!=NULL){
                chargesIncluded +='Origin Loading Charges (Dock Stuffing) : '+quote.Origin_Loading_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Pickup_Charges__c!=0.0 && quote.Pickup_Charges__c!=NULL){
                chargesIncluded +='Pickup Charges(Transportation) : '+quote.Pickup_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Reefer_cntr_plug_in_charges__c!=0.0 && quote.Reefer_cntr_plug_in_charges__c!=NULL){
                chargesIncluded +='Reefer Plugin Charges : '+quote.Reefer_cntr_plug_in_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Tabadul__c!=0.0 && quote.Tabadul__c!=NULL){
                chargesIncluded +='Tabadul : '+quote.Tabadul__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Tarpauline_charge__c!=0.0 && quote.Tarpauline_charge__c!=NULL){
                chargesIncluded +='Tarpauline charge : '+quote.Tarpauline_charge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Truck_idling_charges__c!=0.0 && quote.Truck_idling_charges__c!=NULL){
                chargesIncluded +='Truck idling charges : '+quote.Truck_idling_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.VGM__c!=0.0 && quote.VGM__c!=NULL){
                chargesIncluded +='VGM : '+quote.VGM__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Xray__c!=0.0 && quote.Xray__c!=NULL){
                chargesIncluded +='Xray : '+quote.Xray__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            
            //Destination Charges Computation
            if(quote.Bayan_Charges__c!=0.0 && quote.Bayan_Charges__c!=NULL){
                chargesIncluded +='Bayan Charges : '+quote.Bayan_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Destination_Customs_Clearance__c!=0.0 && quote.Destination_Customs_Clearance__c!=NULL){
                chargesIncluded +='Destination Customs Clearance : '+quote.Destination_Customs_Clearance__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Destination_Loading_Charges__c!=0.0 && quote.Destination_Loading_Charges__c!=NULL){
                chargesIncluded +='Destination Loading Charges : '+quote.Destination_Loading_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.DO_charges__c!=0.0 && quote.DO_charges__c!=NULL){
                chargesIncluded +='DO charges : '+quote.DO_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Fasah_Charges__c!=0.0 && quote.Fasah_Charges__c!=NULL){
                chargesIncluded +='Fasah Charges : '+quote.Fasah_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Gate_pass_charges__c	!=0.0 && quote.Gate_pass_charges__c	!=NULL){
                chargesIncluded +='Gate pass charges : '+quote.Gate_pass_charges__c	 +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.LOLO_Charges__c!=0.0 && quote.LOLO_Charges__c!=NULL){
                chargesIncluded +='LOLO Charges : '+quote.LOLO_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            
            //Additional Charges Computation
            if(quote.Bayan_cancellation_charge__c!=0.0 && quote.Bayan_cancellation_charge__c!=NULL){
                chargesIncluded +='Bayan cancellation charge : '+quote.Bayan_cancellation_charge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            /*if(quote.Container_Lashing_Charges__c!=0.0 && quote.Container_Lashing_Charges__c!=NULL){
                chargesIncluded +='Container Lashing Charges : '+quote.Container_Lashing_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }*/
            if(quote.Container_movement_charges__c!=0.0 && quote.Container_movement_charges__c!=NULL){
                chargesIncluded +='Container movement charges : '+quote.Container_movement_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Container_stripping__c!=0.0 && quote.Container_stripping__c!=NULL){
                chargesIncluded +='Container stripping : '+quote.Container_stripping__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Free_time_certificate_charges__c!=0.0 && quote.Free_time_certificate_charges__c!=NULL){
                chargesIncluded +='Free time certificate charges : '+quote.Free_time_certificate_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Fumigation__c!=0.0 && quote.Fumigation__c!=NULL){
                chargesIncluded +='Fumigation : '+quote.Fumigation__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Ministry_clearnce_charge_for_OOG_cargo__c!=0.0 && quote.Ministry_clearnce_charge_for_OOG_cargo__c!=NULL){
                chargesIncluded +='Ministry clearnce charge for OOG cargo : '+quote.Ministry_clearnce_charge_for_OOG_cargo__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Miscellaneous__c!=0.0 && quote.Miscellaneous__c!=NULL){
                chargesIncluded +='Miscellaneous : '+quote.Miscellaneous__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.MOT_fine_charges__c!=0.0 && quote.MOT_fine_charges__c!=NULL){
                chargesIncluded +='MOT fine charges : '+quote.MOT_fine_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Non_Palletized_Surcharge__c!=0.0 && quote.Non_Palletized_Surcharge__c!=NULL){
                chargesIncluded +='Non Palletized Surcharge : '+quote.Non_Palletized_Surcharge__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Pest_control__c!=0.0 && quote.Pest_control__c!=NULL){
                chargesIncluded +='Pest control : '+quote.Pest_control__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Reefer_PTI_charges__c!=0.0 && quote.Reefer_PTI_charges__c!=NULL){
                chargesIncluded +='Reefer PTI charges : '+quote.Reefer_PTI_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Reefer_steam_wash__c!=0.0 && quote.Reefer_steam_wash__c!=NULL){
                chargesIncluded +='Reefer steam wash : '+quote.Reefer_steam_wash__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Re_palletization__c!=0.0 && quote.Re_palletization__c!=NULL){
                chargesIncluded +='Re palletization : '+quote.Re_palletization__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Stuffing_Charges__c!=0.0 && quote.Stuffing_Charges__c!=NULL){
                chargesIncluded +='Stuffing Charges : '+quote.Stuffing_Charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.SweepingCleaning__c!=0.0 && quote.SweepingCleaning__c!=NULL){
                chargesIncluded +='Sweeping/Cleaning : '+quote.SweepingCleaning__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Truck_Head_charges__c!=0.0 && quote.Truck_Head_charges__c!=NULL){
                chargesIncluded +='Truck Head charges : '+quote.Truck_Head_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Vessel_certificate_charges__c	!=0.0 && quote.Vessel_certificate_charges__c	!=NULL){
                chargesIncluded +='Vessel certificate charges : '+quote.Vessel_certificate_charges__c	 +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            if(quote.Wrappingpacking_charges__c!=0.0 && quote.Wrappingpacking_charges__c!=NULL){
                chargesIncluded +='Wrapping/packing charges : '+quote.Wrappingpacking_charges__c +' '+ quote.CurrencyIsoCode + '\r\n';
            }
            
            quote.Charges_Included__c = chargesIncluded;
            system.debug('chargesIncluded'+chargesIncluded);
            
        }
        
    }
    
}