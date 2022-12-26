import { LightningElement,track,api } from 'lwc';
import getEnqueryDetails from '@salesforce/apex/BAFCOLRoutingDetailsController.getEnqueryDetails';
import VECTOR from '@salesforce/resourceUrl/Vector';
export default class BAFCOParentComponent extends LightningElement {
    @track routingDetailsList = [];
    @api enquiryID;
    @api cameReviseCompt=false;
    @track leadId;
    @track accountAvgMargin = 0;
    @track accountBestMargin = 0;
    @track accountAvgCreditDays = 0;
    @track section = ''
    @track showQuoteButton = false;
    @track validityDate = '';
    @track quoteId = '';
    vectorPng = VECTOR;

    entryIntVar = 1;
    @track displayQuotationlist= [];    
    connectedCallback(){
        console.log('record id '+this.enquiryID)
        document.title = 'Create Export Quote'
        this.getEnqueryDetailsOnInit();
    }
    getEnqueryDetailsOnInit(){
        getEnqueryDetails({enquiryID : this.enquiryID})
        .then(result =>{
            console.log('enquery  result : ', JSON.stringify(result,null,2));
            this.routingDetailsList = result;
            this.leadId = this.routingDetailsList[0].leadId;
            this.accountAvgMargin = this.routingDetailsList[0].accountAvgMargin;
            this.accountBestMargin = this.routingDetailsList[0].accountBestMargin;
            this.accountAvgCreditDays = this.routingDetailsList[0].accountAvgCreditDays;
        }).catch(error=>{
            console.log('error lead: ', JSON.stringify(error));
        });
    }
    handleUpdateCalculation(e){
        //console.log('calculation '+JSON.stringify(e.detail.quotationMap,null,2));
        let templist = [];
        let tempList2 = [];
        e.detail.quotationMap.forEach(elem =>{
            tempList2.push({value:elem.key,data:elem.value})
        })
        templist.push({key:e.detail.routeName,value:tempList2})        
        this.displayQuotationlist = templist;
        //console.log('map '+JSON.stringify(this.displayQuotationlist,null,2))
    }
    addNewShippingline(){
        this.template.querySelectorAll("c-b-a-f-c-o-routing-details-intake-form")[0].handleAddShippingline();
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
                this.template.querySelectorAll("c-b-a-f-c-o-routing-details-intake-form")[index].handleUpdateCalculation();
            }, 200);
            
        }
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
                setTimeout(() => {
                    this.template.querySelectorAll("c-b-a-f-c-o-routing-details-intake-form")[index].handleGotoQuotation(this.validityDate);
                }, 200);
                
            }
        }
    }
    handleShowquoteBtn(e){
        this.quoteId = e.detail.quoteId;
        console.log('thise quoteID '+this.quoteId);
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
    
}