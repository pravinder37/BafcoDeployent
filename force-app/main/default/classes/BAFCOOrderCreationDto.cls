public class BAFCOOrderCreationDto {
    @AuraEnabled
    public String routeName { get; set; }
    @AuraEnabled
    public String routeId { get; set; }
    @AuraEnabled
    public List<equipment> equipment { get; set; }
    
    public class equipment{
        @AuraEnabled
        public String key { get; set; }
        @AuraEnabled
        public List<value> value { get; set; }
    }
    public class value{
        @AuraEnabled
        public String recordtypeId { get; set; }
        @AuraEnabled
        public String shipName { get; set; }
        @AuraEnabled
        public Decimal Qty { get; set; }
        @AuraEnabled
        public Decimal sellingTotal { get; set; }
        @AuraEnabled
        public String accountId { get; set; }
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
        public String enquiryId { get; set; }
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
        public String leadId { get; set; }
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
        public Decimal portShuttling { get; set; }
        @AuraEnabled
        public String postOfDischarge { get; set; }
        @AuraEnabled
        public String postOfLoading { get; set; }
        @AuraEnabled
        public String quotationId { get; set; }
        @AuraEnabled
        public Decimal refeerCentr { get; set; }
        @AuraEnabled
        public Decimal refeerPTI { get; set; }
        @AuraEnabled
        public Decimal refeerSteamWash { get; set; }
        @AuraEnabled
        public Decimal rePalletization { get; set; }
        @AuraEnabled
        public String rmsID { get; set; }
        @AuraEnabled
        public String routeID { get; set; }
        @AuraEnabled
        public Decimal seaFreight { get; set; }
        @AuraEnabled
        public Decimal sealCharges { get; set; }
        @AuraEnabled
        public Decimal sellingRate { get; set; }
        @AuraEnabled
        public Decimal stuffingCharges { get; set; }
        @AuraEnabled
        public Decimal sweepingCleaning { get; set; }
        @AuraEnabled
        public Decimal tabadul { get; set; }
        @AuraEnabled
        public Decimal tarapulin { get; set; }
        @AuraEnabled
        public Decimal totalInco { get; set; }
        @AuraEnabled
        public Decimal totalSL { get; set; }
        @AuraEnabled
        public Decimal truckHead { get; set; }
        @AuraEnabled
        public Decimal truckIdealing { get; set; }
        @AuraEnabled
        public Decimal vesselCertificate { get; set; }
        @AuraEnabled
        public Decimal wrappingPacking { get; set; }
        @AuraEnabled
        public Decimal xRay { get; set; }
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
    }
   
}