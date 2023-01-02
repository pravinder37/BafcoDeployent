import { LightningElement,track } from 'lwc';
import getImportItem from '@salesforce/apex/BAFCOImportSearchController.getImportItem';
export default class BAFCOImportSearchScreen extends LightningElement {
    isLoading = false;
    selectedAgentError = '';
    agentId = '';
    noRecord = true;
    @track quoteList = [];
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
}