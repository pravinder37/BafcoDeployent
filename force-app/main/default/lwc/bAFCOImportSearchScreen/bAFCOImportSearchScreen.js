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
    displayModal = false;
    @track fromVesselETD = null;
    @track toVesselETD = null;
    handleAgentSelection(e){
        this.agentId = e.detail.Id;
        this.selectedAgentError = '';
        this.removeError();
    }
    handleSearchItem(){
        this.isLoading = true;
        let allValid = false;
        if(this.agentId != '' || (this.fromVesselETD != null && this.toVesselETD != null)){
            allValid = true;
        }
        if(allValid){
            getImportItem({agentId :this.agentId,fromVesselETD:this.fromVesselETD,toVesselETD:this.toVesselETD})
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
        else{
            if(this.agentId == ''){
                this.selectedAgentError = 'slds-has-error'
            }
            if(this.fromVesselETD == null){
                let fromVesselETD = this.template.querySelector("[data-field='fromVesselETD']");
                fromVesselETD.setCustomValidity("Complete this field.");
                fromVesselETD.reportValidity();
            }
            if(this.toVesselETD == null){
                let toVesselETD = this.template.querySelector("[data-field='toVesselETD']");
                toVesselETD.setCustomValidity("Complete this field.");
                toVesselETD.reportValidity();
            }
            this.isLoading = false;
        }
    }
    handleAgentRemoved(e){
        this.agentId = '';
    }
    handleEditItem(e){
       this.quoteItemId = e.target.value;
       let item = this.quoteList.filter(x=>x.Id == this.quoteItemId);
       this.buyingRate = item[0].Buying_Rate__c;
       this.totalSellingRate = item[0].Total_Order__c;
       this.displayModal = true;
    }
    handleNewQuote(e){
        this.isLoading =true
        let quoteId = e.target.value;
        let item = this.quoteList.filter(x=>x.Order__r.Quotation__c == quoteId);
        let accId = item[0].Order__r.Account_Order__c;
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ImportReviseQuoteTab"
            },
            state: {
                c__refRecordId: quoteId,
                c__leadId: accId
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
    handleOrderItemClicked(e){
        let Id = e.target.dataset.value
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                actionName: 'view'
            },
        }).then(url => { window.open(url,'_blank') });
    }
    handleQuotationClicked(e){
        let Id = e.target.dataset.value
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                actionName: 'view'
            },
        }).then(url => { window.open(url,'_blank') });
    }
    handleFromVesselETDChange(e){
        this.fromVesselETD = e.target.value
        this.removeError();
    }
    handleToVesselETDChange(e){
        this.toVesselETD = e.target.value
        this.removeError();
    }
    removeError(){
        this.selectedAgentError = ''
        let fromVesselETD = this.template.querySelector("[data-field='fromVesselETD']");
        fromVesselETD.setCustomValidity("");
        fromVesselETD.reportValidity();
        let toVesselETD = this.template.querySelector("[data-field='toVesselETD']");
        toVesselETD.setCustomValidity("");
        toVesselETD.reportValidity();
    }
}