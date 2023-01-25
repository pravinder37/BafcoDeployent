import { LightningElement,api,track } from 'lwc';
import getquoteDetails from '@salesforce/apex/BAFCOQuotationReviseController.getquoteDetails';
import getquoteList from '@salesforce/apex/BAFCOQuotationReviseController.getquoteList';
import getEnqueryDetails from '@salesforce/apex/BAFCOLRoutingDetailsController.getEnqueryDetails';
import getQuoteLineItemRoute from '@salesforce/apex/BAFCOQuotationReviseController.getQuoteLineItemRoute';
import VECTOR from '@salesforce/resourceUrl/Vector';
export default class BAFCOLocalOperationReviseParent extends LightningElement {
    @api accId = '';
    @api quoteID ='';
    @track quoteObj = {};
    @track quoteList;
    vectorPng = VECTOR;
    @track activeTab ='';
    @track routingDetailsList;
    @track activeQuoteId = '';
    @track displayQuotationlist= [];
    @track enquiryList = [];
    @track enquiryId = '';
    @track cameReviseCompt = true;
    @track sameRoute = true;
    @track  showQuoteButton = false;
    @track section = 'Route 1';
    @track recordtypeName = '';
    @track validityDate = '';
    connectedCallback(){        
        this.getquoteDetails();
    }
    getquoteDetails(){
        console.log('this.quoteID '+this.quoteID)
        getquoteDetails({quoteId : this.quoteID}).then(result =>{
            console.log('getquoteDetails  result : ', JSON.stringify(result,null,2));
            if(result != null){
                this.quoteObj= result;
                this.getquoteList();
            }            
        }).catch(error=>{
            console.log('getquoteDetails error: ', JSON.stringify(error));
        });
    }
    getquoteList(){
        console.log('camere herer 1 ' +this.quoteID)
        getquoteList({quoteId : this.quoteID}).then(result =>{     
            console.log('camere herer 2')   
            console.log('getquoteList  result : ', JSON.stringify(result,null,2));     
            if(result != null && result.length > 0){
                console.log('camere herer 3')   
                this.quoteList=result;
                console.log('camere herer 4')   
                this.activeTab = result[0].Id;
                console.log('camere herer 5')   
                this.recordtypeName = result.RecordType.Name;
                console.log('camere herer 6') 
            }         
        }).catch(error=>{
            console.log('getquoteList error: ', JSON.stringify(error));
        });
    }
    handleQuoteActive(event){
        let quoteId = event.target.value;
        this.activeQuoteId = quoteId;
        console.log('this.activeQuoteId '+this.activeQuoteId);
        this.getQuoteLineItemRoute();
    }
    getQuoteLineItemRoute(){
        getQuoteLineItemRoute({quoteId : this.activeQuoteId})
        .then(result =>{
            console.log('getQuoteLineItemRoute result: ', JSON.stringify(result,null,2));
            if(result.length > 0){
                this.routingDetailsList = result;
                this.enquiryId = result[0].enquiryId;
                this.section = result[0].routeName;
                this.getEnqueryDetails(); // new qoute generation
            }
            
        })
        .catch(error=>{
            console.log('getQuoteLineItemRoute error: ', JSON.stringify(error));
        });
    }
    handleSectionToggle01(){}
    getEnqueryDetails(){

        getEnqueryDetails({enquiryID : this.enquiryId})
        .then(result =>{
            this.enquiryList = result; 
            console.log('enquiry  result : ', JSON.stringify(this.enquiryList,null,2)); 
        }).catch(error=>{
            console.log('error lead: ', JSON.stringify(error));
        });
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
    handleUpdateCalculation(){}
    handleShowquoteBtn(e){
        this.quoteID = e.detail.quoteId;
        this.sameRoute = false;
        this.showQuoteButton = true;
    }
    handleNewQuoteActive(){
        this.quoteID = '';
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