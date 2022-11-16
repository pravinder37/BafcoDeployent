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
    }
}