public class BAFCOGenerateOrderPDFMobileController {
public String recordId {get;set;}
    public String subject { get; set; }
    public String body { get; set; }
    public String emailid{get; set;}
    public BAFCOGenerateOrderPDFMobileController(ApexPages.StandardController controller){
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        String recordId = pageParameters.get('recordId');
        this.recordId = recordId;
        system.debug('this.recordId' +this.recordId);
    }
    public PageReference send() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        PageReference pdf =  Page.BAFCOOrderPDFPage;
        pdf.getParameters().put('recordId',(String)this.recordId);
        pdf.getParameters().put('showShippLine','true');
        pdf.getParameters().put('showCharges','true');
        pdf.getParameters().put('nooverride', '1');
        pdf.setRedirect(true);
        Blob b = null;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        }
        else{
            b = pdf.getContentAsPdf();
        }
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('application/pdf');
        efa.setFileName('Order.pdf');
        efa.setBody(b);
        String addresses;
        addresses=emailid;
        String[] toAddresses = addresses.split(':', 0);
        email.setSubject( subject );
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Find the Attachment');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        // Sends the email
        Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        PageReference pg = new PageReference('/'+this.recordId);
        pg.setRedirect(true);
        return pg;  
    }
}