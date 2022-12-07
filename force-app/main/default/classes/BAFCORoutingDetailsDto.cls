public class BAFCORoutingDetailsDto {
    public BAFCORoutingDetailsDto(){
        containerRecord = new List<BAFCORoutingDetailsDto.containerRecord>();
    }
    @AuraEnabled
    public String routeId { get; set; }
    @AuraEnabled
    public String routeName { get; set; }
    @AuraEnabled
    public String routingRegular { get; set; }
    @AuraEnabled
    public String shipmentKind { get; set; }
    @AuraEnabled
    public String serviceType { get; set; }
    @AuraEnabled
    public String incoTerm { get; set; }
    @AuraEnabled
    public String incoTermId { get; set; }
    @AuraEnabled
    public String portLoading { get; set; }
     @AuraEnabled
    public String portLoadingId { get; set; }
    @AuraEnabled
    public String placeOfPickup { get; set; }
    @AuraEnabled
    public String placeOfDischarge { get; set; }
    @AuraEnabled
    public String placeOfPickupName { get; set; }
    @AuraEnabled
    public String placeOfDischargeName { get; set; }
    @AuraEnabled
    public String dgClass { get; set; }
    @AuraEnabled
    public String portDestination { get; set; }
    @AuraEnabled
    public String shippingLine { get; set; }
    @AuraEnabled
    public String commodity { get; set; }
    @AuraEnabled
    public Decimal cargoWeights { get; set; }
    @AuraEnabled
    public Boolean dangerousGoods { get; set; }
    @AuraEnabled
    public String remarks { get; set; }
    @AuraEnabled
    public String leadIndex { get; set; }
    @AuraEnabled
    public String leadId { get; set; }
    @AuraEnabled
    public String businessType { get; set; }
    @AuraEnabled
    public String enquiryId { get; set; }
    @AuraEnabled
    public Decimal accountAvgMargin { get; set; }
    @AuraEnabled
    public Decimal accountBestMargin { get; set; }
    @AuraEnabled
    public Decimal accountAvgCreditDays { get; set; }
    @AuraEnabled
    public String parentId { get; set; }
    @AuraEnabled
    public List<BAFCORoutingDetailsDto.containerRecord> containerRecord { get; set; }
    
    public class containerRecord{
        @AuraEnabled
        public String containerType { get; set; }
        @AuraEnabled
        public Decimal quantity { get; set; }
        @AuraEnabled
        public String index { get; set; }
    }
}