import { LightningElement,api,track } from 'lwc';
import getOrderItem from '@salesforce/apex/BAFCOImportSearchController.getOrderItemValue';
import updateOrderItem from '@salesforce/apex/BAFCOImportSearchController.updateOrderItemValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BAFCOUpdateRatesOnVessleUpdates extends LightningElement {
    @api recordId;
    isLoading2 = false;
    @track buyingRate ;
    @track totalSellingRate ;
    @track shippingLineId = '';
    @track shippingLineName = '';
    @track quotationValidity;
    orderItemRecordDetails;

    connectedCallback(){
        console.log('recordId'+this.recordId);
        this.getOrderItemOnLoad();
    }

    getOrderItemOnLoad(){
        this.isLoading2 = true;
        getOrderItem({orderItemID :this.recordId})
        .then(result=>{
            this.isLoading2 = false;
            this.orderItemRecordDetails = result;
            console.log('this.orderItemRecordDetails',this.orderItemRecordDetails);
            console.log('this.orderItemRecordDetails.buyingRate'+this.orderItemRecordDetails.Buying_Rate__c);
            this.buyingRate=this.orderItemRecordDetails.Buying_Rate__c;
            this.shippingLineId = result.Shipping_Line__c;
            this.shippingLineName = result.Shipping_Line__r.Name;
            this.totalSellingRate = result.Total_Order__c;
            this.quotationValidity = result.Order__r.Quotation__r.Quotation_Validity__c;
            if(this.shippingLineId != ''){
                let obj={Id: this.shippingLineId,Name: this.shippingLineName}
                let ChildObj = this.template.querySelector('c-b-a-f-c-o-custom-look-up-component');
                ChildObj.handleDefaultSelected(obj);
            }
        })
        .catch(error=>{
            console.log('getOrderItemOnLoad error',JSON.stringify(error,null,2));
            this.isLoading2 = false;
        })
    }

    handleShippingLineSelection(e){
        this.shippingLineId = e.detail.Id;
        this.shippingLineName = e.detail.Name;
        this.selectedShippLineError = '';
    }

    handleShippingLineRemoved(e){
        this.shippingLineId = '';
        this.shippingLineName = '';
        this.selectedShippLineError = 'slds-has-error';
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

    handleQuotationValidityChange(e){
        this.quotationValidity = e.target.value;
        let quotationValidityField = this.template.querySelector("[data-field='quotationValidityField']");
        quotationValidityField.setCustomValidity("");
        quotationValidityField.reportValidity();  
    }

    handleUpdateItemClicked(){
        this.isLoading2 = true;
        let allValid = true;
        if(this.buyingRate <= 0) {
            allValid = false
            let buyingRateField = this.template.querySelector("[data-field='buyingRateField']");
            buyingRateField.setCustomValidity("Buying Rate must be greater than 0.");
            buyingRateField.reportValidity();
            this.isLoading2 = false;
        }
        if(this.totalSellingRate <= 0){
            allValid = false
            let totalRateField = this.template.querySelector("[data-field='totalRateField']");
            totalRateField.setCustomValidity("Total must be greater than 0.");
            totalRateField.reportValidity();
            this.isLoading2 = false;  
        }
        if(this.shippingLineId == ''){
            allValid = false;
            this.selectedShippLineError = 'slds-has-error';
            this.isLoading2 = false;
        }
        if(allValid){
            updateOrderItem({
                buyingRate : this.buyingRate,
                sellingRate: this.totalSellingRate,
                shippingLineId : this.shippingLineId,
                quotationValidity : this.quotationValidity,
                orderItemID :this.recordId
            }).then(result=>{
                this.quoteList = [];
                console.log('result '+result);
                const evt = new ShowToastEvent({
                    title: 'Updated Successfully',
                    message: 'Order item is updated successfully.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.isLoading2 = false;
                this.dispatchEvent(new CustomEvent('close'));
                //this.getImportItemOnLoad();
            })
            .catch(error=>{console.log('error '+JSON.stringify(error));this.isLoading2 = false;})
        }
    }

    hideModalBox(){
        this.dispatchEvent(new CustomEvent('close'));
    }


}