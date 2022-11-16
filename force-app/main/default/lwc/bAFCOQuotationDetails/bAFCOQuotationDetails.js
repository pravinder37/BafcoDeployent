import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class BAFCOQuotationDetails extends NavigationMixin(LightningElement) {
    @api quotationList = [];

    handleAddNewShippingLine(){
        this.dispatchEvent(new CustomEvent('addnewshippingline'));
    }
    renderedCallback(){
        console.log('qutoad '+JSON.stringify(this.quotationList,null,2))
    }
    handleGotoQuotation(){
        //this.dispatchEvent(new CustomEvent('gotoquote'));
        console.log('quotationId '+JSON.stringify(this.quotationList,null,2))
        if(this.quotationList.quotationId != ''){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.quotationId,
                    objectApiName: 'Quotation__c',
                    actionName: 'view'
                }
            });
        }
    }
}