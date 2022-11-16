import { LightningElement,api } from 'lwc';
import createOrder from '@salesforce/apex/BAFCOSalesOrderController.createOrder';
import { NavigationMixin } from 'lightning/navigation';
export default class BAFCOSalesOrderList extends NavigationMixin(LightningElement) {
    @api displaySelectedQuoteItem = [];
    @api activeSection;
    @api quantityData = [];
    isLoading = false;
    validityDate = '';
    errorMsg = '';
    hideCreateOrder(){
       if(this.validityDate == '' || this.validityDate == null){
            let dateField = this.template.querySelector("[data-field='dateField']");
            dateField.setCustomValidity("Complete this field.");
            dateField.reportValidity();
        }
        else{
            let hasValue = false;
            this.displaySelectedQuoteItem.forEach(ele=>{
                if(ele.equipment.length > 0) hasValue = true; 
            });
           console.log('hasValue ',hasValue)
            if(!hasValue){
                this.errorMsg='Please select atleast one item to create order';
            }
            else{
                this.isLoading = true;
                let saveDto = [];
                saveDto = JSON.parse(JSON.stringify(this.displaySelectedQuoteItem))                
                createOrder({orderCreationList : saveDto, validityDate:this.validityDate})
                .then(result=>{
                    console.log('createOrder result',JSON.stringify(result,null,2))
                    this.isLoading = false;
                    if(result != null ){
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result.Id,
                                actionName: 'view'
                            }
                        });
                    }
                })
                .catch(error=>{
                    this.isLoading = false;
                    console.log('createOrder error',JSON.stringify(error,null,2))
                })
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
    @api
    handlecheckBoxSelected(){
        this.errorMsg = '';
    }
}