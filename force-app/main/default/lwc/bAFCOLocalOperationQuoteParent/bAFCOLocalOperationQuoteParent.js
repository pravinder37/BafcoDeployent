import { LightningElement,api,track } from 'lwc';
import getEnqueryDetails from '@salesforce/apex/BAFCOLRoutingDetailsController.getEnqueryDetails';
import VECTOR from '@salesforce/resourceUrl/Vector';
export default class BAFCOLocalOperationQuoteParent extends LightningElement {
    @api optyId = '';
    @api businessType ='';
    @track routingDetailsList = [];
    @track accountId;
    @track accountAvgMargin = 0;
    @track accountBestMargin = 0;
    @track accountAvgCreditDays = 0;
    @track section = ''
    @track showQuoteButton = false;
    @track validityDate = '';
    @track quoteId = '';
    vectorPng = VECTOR;
    connectedCallback(){
        this.getEnqueryDetailsOnInit();
    }
    getEnqueryDetailsOnInit(){
        getEnqueryDetails({enquiryID : this.optyId})
        .then(result =>{
            console.log('enquery  result : ', JSON.stringify(result,null,2));
            this.routingDetailsList = result;
            this.accountId = this.routingDetailsList[0].leadId;
            this.accountAvgMargin = this.routingDetailsList[0].accountAvgMargin;
            this.accountBestMargin = this.routingDetailsList[0].accountBestMargin;
            this.accountAvgCreditDays = this.routingDetailsList[0].accountAvgCreditDays;
        }).catch(error=>{
            console.log('error lead: ', JSON.stringify(error));
        });
    }
    handleShowquoteBtn(e){
        this.quoteId = e.detail.quoteId;
        this.showQuoteButton = true;
    }
    handleValidityChange(e){
        this.validityDate = e.target.value;
        let dateField = this.template.querySelector("[data-field='dateField']");
        if(this.validityDate == ''){            
            dateField.setCustomValidity("Complete this field.");            
        }
        else{
            dateField.setCustomValidity("");  
        }
        dateField.reportValidity();
    }
    handleSectionToggle(event){
        let section = event.detail.openSections;
        this.section = section
        let index = -1;
        for(let i = 0 ; i< this.routingDetailsList.length ; i++){
            if(this.routingDetailsList[i].routeName == section)
            index = i;
        }
        if(index != -1){
            setTimeout(() => {
                this.template.querySelectorAll("c-b-a-f-c-o-local-operation-quote-intake-form")[index].handleUpdateCalculation();
            }, 200);
            
        }
    }
    handleShowquoteBtn(e){
        this.quoteId = e.detail.quoteId;
        console.log('thise quoteID '+this.quoteId);
        this.showQuoteButton = true;
    }
    handleGotoQuote(e){
        if(this.validityDate == '' || this.validityDate == null){
            let dateField = this.template.querySelector("[data-field='dateField']");
            dateField.setCustomValidity("Complete this field.");
            dateField.reportValidity();
        }
        else{
            let index = -1;
            for(let i = 0 ; i< this.routingDetailsList.length ; i++){
                if(this.routingDetailsList[i].routeName == this.section)
                index = i;
            }
            if(index != -1){
                this.template.querySelectorAll("c-b-a-f-c-o-local-operation-quote-intake-form")[index].handleGotoQuotation(this.validityDate);
            }
        }
    }
}