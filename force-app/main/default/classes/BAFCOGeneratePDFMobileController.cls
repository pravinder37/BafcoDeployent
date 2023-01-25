public class BAFCOGeneratePDFMobileController {
    
    public String recordId {get;set;}
    public BAFCOGeneratePDFMobileController(ApexPages.StandardController controller){
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        String recordId = pageParameters.get('recordId');
        this.recordId = recordId;
        system.debug('this.recordId '+this.recordId);
    }
    public PageReference savePdf() {
        PageReference pdf =  Page.BAFCOGeneratePdf;
        pdf.getParameters().put('recordId',(String)this.recordId);
        pdf.getParameters().put('showShippLine','true');
        pdf.getParameters().put('showCharges','true');
        pdf.getParameters().put('nooverride', '1');
        pdf.setRedirect(true);
        Blob b = null;
        if(test.isRunningTest())  b = blob.valueOf('Unit.Test');
        else b = pdf.getContentAsPdf();
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Quotation.pdf';
        conVer.Title = 'Quotation.pdf';
        conVer.VersionData = b;
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = this.recordId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
       // insert conDocLink;
        PageReference pg = new PageReference('/'+this.recordId);
        pg.setRedirect(true);
        return pg;  
    }
}