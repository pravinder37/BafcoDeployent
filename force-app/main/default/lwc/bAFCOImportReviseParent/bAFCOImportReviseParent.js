import { LightningElement,api,track } from 'lwc';
import getquoteDetails from '@salesforce/apex/BAFCOQuotationReviseController.getquoteDetails';
import getquoteList from '@salesforce/apex/BAFCOImportQuotationReviseController.getquoteList';
import getQuoteLineItemRoute from '@salesforce/apex/BAFCOQuotationReviseController.getQuoteLineItemRoute';
import getEnqueryDetails from '@salesforce/apex/BAFCOLRoutingDetailsController.getEnqueryDetails';
import VECTOR from '@salesforce/resourceUrl/Vector';
export default class BAFCOImportReviseParent extends LightningElement {
    @api quoteID
    @api leadId
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
    @track section = '';
    @track recordtypeName = '';
    @track validityDate = '';
    connectedCallback(){
        document.title = 'Revise Import Quote';
        this.getquoteDetails();
    }
    getquoteDetails(){
        getquoteDetails({quoteId : this.quoteID}).then(result =>{
            console.log('getquoteDetails  result : ', JSON.stringify(result,null,2));
            if(result != null){
                this.quoteObj= result;
                this.getquoteList();
            }            
        }).catch(error=>{
            console.log('getquoteDetails lead: ', JSON.stringify(error));
        });
    }
    getquoteList(){
        getquoteList({quoteId : this.quoteID}).then(result =>{
            console.log('getquoteList  result : ', JSON.stringify(result,null,2));
            if(result != null){
                this.quoteList=result;
                this.activeTab = result[0].Id;
                this.recordtypeName = result.RecordType.Name;
            }            
        }).catch(error=>{
            console.log('getquoteList lead: ', JSON.stringify(error));
        });
    }
    handleQuoteActive(event){
        let quoteId = event.target.value;
        this.activeQuoteId = quoteId;
        this.getQuoteLineItemRoute();
    }
    getQuoteLineItemRoute(){
        getQuoteLineItemRoute({quoteId : this.activeQuoteId})
        .then(result =>{
            console.log('getQuoteLineItemRoute result: ', JSON.stringify(result,null,2));
            if(result.length > 0){
                this.routingDetailsList = result;
                this.enquiryId = result[0].enquiryId;
                this.getEnqueryDetails(); // new qoute generation
            }
            
        })
        .catch(error=>{
            console.log('getQuoteLineItemRoute error: ', JSON.stringify(error));
        });
    }
    handleUpdateCalculation(e){
        let templist = [];
        let tempList2 = [];
        e.detail.quotationMap.forEach(elem =>{
            tempList2.push({value:elem.key,data:elem.value})
        })
        templist.push({key:e.detail.routeName,value:tempList2})        
        this.displayQuotationlist = templist;
    }
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
    }
    handleShowquoteBtn(e){
        this.quoteID = e.detail.quoteId;
        this.sameRoute = false;
        this.showQuoteButton = true;
    }
    handleNewQuoteActive(){
        this.quoteID = '';
    }
    handleGotoQuote(){
        console.log('Section '+this.section)
        console.log('validityDate '+this.validityDate)
        if(this.validityDate == '' || this.validityDate == null){
            let dateField = this.template.querySelector("[data-field='dateField']");
            dateField.setCustomValidity("Complete this field.");
            dateField.reportValidity();
        }
        else{
        let index = -1;
        for(let i = 0 ; i< this.enquiryList.length ; i++){
            if(this.enquiryList[i].routeName == this.section)
            index = i;
        }
        if(index != -1){
            setTimeout(() => {
                this.template.querySelectorAll("c-b-a-f-c-o-import-route-details")[index].handleGotoQuotation();
            }, 200);
            
        }
        }
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