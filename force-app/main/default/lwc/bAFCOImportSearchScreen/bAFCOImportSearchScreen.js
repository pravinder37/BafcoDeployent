import { LightningElement,track } from 'lwc';
import getImportItem from '@salesforce/apex/BAFCOImportSearchController.getImportItem';
import updateQuoteItem from '@salesforce/apex/BAFCOImportSearchController.updateQuoteItem';
import { NavigationMixin } from 'lightning/navigation';
export default class BAFCOImportSearchScreen extends NavigationMixin(LightningElement) {
    isLoading = false;
    selectedAgentError = '';
    agentId = '';
    noRecord = true;
    @track quoteList = [];
    @track quoteItemId = '';
    @track buyingRate ;
    @track totalSellingRate ;
    displayModal = false
    handleAgentSelection(e){
        this.agentId = e.detail.Id;
        this.selectedAgentError = '';
    }
    handleSearchItem(){
        if(this.agentId != ''){
            this.isLoading = true;
            getImportItem({agentId :this.agentId})
            .then(result=>{
                console.log('result '+JSON.stringify(result,null,2));
                this.quoteList = result;
                if(this.quoteList.length > 0) this.noRecord = false
                else this.noRecord = true
                this.isLoading = false;
            })
            .catch(error=>{
                console.log('error '+JSON.stringify(error,null,2));
                this.isLoading = false;
            })
        }
        else this.selectedAgentError = 'slds-has-error';
    }
    handleAgentRemoved(e){
        this.agentId = '';
    }
    handleEditItem(e){
       this.quoteItemId = e.target.value;
       let item = this.quoteList.filter(x=>x.Id == this.quoteItemId);
       this.buyingRate = item[0].Buying_Rate__c;
       this.totalSellingRate = item[0].Total__c;
       this.displayModal = true;
    }
    handleNewQuote(e){
        let quoteId = e.target.value;
        let item = this.quoteList.filter(x=>x.Quotation__c == quoteId);
        let accId = item[0].Quotation__r.Opportunity__r.AccountId;
        console.log('e.target.value; '+quoteId)
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ImportReviseQuoteTab"
            },
            state: {
                c__refRecordId: quoteId,
                c__leadId:accId
            }
        });
    }
    hideModalBox(){
        this.displayModal= false;
    }
    handleBuyingRateChange(e){
        this.buyingRate = e.target.value;
        let buyingRateField = this.template.querySelector("[data-field='buyingRateField']");
        buyingRateField.setCustomValidity("");
        buyingRateField.reportValidity();  
    }
    handleSellingTotalChange(e){
        this.totalSellingRate = e.target.value;
        let totalRateField = this.template.querySelector("[data-field='totalRateField']");
        totalRateField.setCustomValidity("");
        totalRateField.reportValidity();  
    }
    handleUpdateItemClicked(){
        let allValid = true;
        if(this.buyingRate <= 0) {
            allValid = false
            let buyingRateField = this.template.querySelector("[data-field='buyingRateField']");
            buyingRateField.setCustomValidity("Buying Rate must be greater than 0.");
            buyingRateField.reportValidity();
        }
        if(this.totalSellingRate <= 0){
            allValid = false
            let totalRateField = this.template.querySelector("[data-field='totalRateField']");
            totalRateField.setCustomValidity("Total must be greater than 0.");
            totalRateField.reportValidity();  
        }
        if(allValid){
            updateQuoteItem({
                buyingRate : this.buyingRate,
                sellingRate: this.totalSellingRate,
                recordId : this.quoteItemId,
            }).then(result=>{
                console.log('result '+result);
                this.displayModal= false;
                this.handleSearchItem();
            })
            .catch(error=>{console.log('error '+JSON.stringify(error));})
        }
    }
}