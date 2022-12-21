public class BAFCOGeneratePDFDto {
    @AuraEnabled public string customerName{get;set;}
    @AuraEnabled public string contactPerson{get;set;}
    @AuraEnabled public string address{get;set;}
    @AuraEnabled public string phone{get;set;}
    @AuraEnabled public string email{get;set;}
    @AuraEnabled public string quoteNumber{get;set;}
    @AuraEnabled public string quoteIssued{get;set;}
    @AuraEnabled public string preparedBy{get;set;}
    @AuraEnabled public string salesResponsible{get;set;}
    @AuraEnabled public string effectiveFrom{get;set;}
    @AuraEnabled public string validityTo{get;set;}
    @AuraEnabled public string serviceType{get;set;}
    @AuraEnabled public string shippingTerm{get;set;}
    @AuraEnabled public string paymentTerm{get;set;}
    @AuraEnabled public string remarks{get;set;}
    @AuraEnabled public string recordTypeName{get;set;}
    @AuraEnabled public string exclusionHeader{get;set;}
    @AuraEnabled public List<string> exclusionList{get;set;}
    @AuraEnabled public string inclusionHeader{get;set;}
    @AuraEnabled public List<string> inclusionList{get;set;}
    @AuraEnabled public string termsNConditionHeader{get;set;}
    @AuraEnabled public List<string> termsNConditionList{get;set;}
    @AuraEnabled public List<serviceChargeList> serviceChargeList{get;set;}
    
    public class serviceChargeList{
        @AuraEnabled public string shippingLine{get;set;}
        @AuraEnabled public string transitTime{get;set;}
        @AuraEnabled public string placeOfPickup{get;set;}
        @AuraEnabled public string placeOfDischarge{get;set;}
        @AuraEnabled public string portOfLoading{get;set;}
        @AuraEnabled public string portOfDestination{get;set;}
        @AuraEnabled public string equipmentType{get;set;}
        @AuraEnabled public decimal total{get;set;}
        @AuraEnabled public decimal totalDC{get;set;}
        @AuraEnabled public Boolean ShowtotalDC{get;set;}
        @AuraEnabled public string equipmentTypeDC{get;set;}
        @AuraEnabled public string serviceType{get;set;}
        @AuraEnabled
        public BAFCOImportRMSDto.destinChargeObj destinChargeObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.originChargesObj originChargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.servichargesObj servichargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.additionalChargesObj additionalChargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.exWorksObj exWorksObj { get; set; }
        @AuraEnabled
        public DC20Charges dc20Charges { get; set; }
    }
    public class DC20Charges{
        @AuraEnabled
        public BAFCOImportRMSDto.destinChargeObj destinChargeObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.originChargesObj originChargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.servichargesObj servichargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.additionalChargesObj additionalChargesObj { get; set; }
        @AuraEnabled
        public BAFCOImportRMSDto.exWorksObj exWorksObj { get; set; }
    }
}