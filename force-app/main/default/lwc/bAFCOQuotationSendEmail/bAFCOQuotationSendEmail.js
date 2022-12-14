import { LightningElement,api,wire,track } from 'lwc';
import getQuoteDataOnLoad from '@salesforce/apex/BAFCOQuoteCopyContentController.getQuoteDataOnLoad';
import sendEmail from '@salesforce/apex/BAFCOQuoteCopyContentController.sendEmail';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
export default class BAFCOQuotationSendEmail extends LightningElement {
    @api recordId;
    @track toSend = '';
    @track toCCSend = '';
    @track toBCCSend = '';
    @track subject = '';
    @track body ='';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log('recordId && '+this.recordId)
    }
    connectedCallback(){
        console.log('recordId * '+this.recordId)
        if(this.recordId != undefined) this.getQuoteDataOnLoad();
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    getQuoteDataOnLoad(){
        this.isLoading = true;
        getQuoteDataOnLoad({quoteId : this.recordId})
        .then(result=>{
            this.isLoading = false
            console.log('getQuoteDataOnLoad result @@ '+JSON.stringify(result,null,2))
            if(result != null){
                let content = 'Dear Valued Client,\n\nThank you for giving Bafco International the opportunity to quote for your order.';
                content +='\n\nPlease find below the details:\n';

                if(result.length > 0){
                    result.forEach(elem => {
                        content += 'Port of Loading: '+elem.loadingPort;
                        content += '\nPort of Discharge: '+elem.dischargePort;
                        content += '\nEquipment Type: '+elem.equipmentType;
                        content += '\nTotal: '+elem.total;
                        content += '\n\n'
                    });
                    content +='\nWe look forward to a positive response from your end.';
                    this.body = content;
                }
            }
        })
        .catch(error=>{
            this.isLoading = false
            console.log('getQuoteDataOnLoad error @@ '+JSON.stringify(error,null,2))
        })
    }
    handletoSend(e){
        this.toSend = e.target.value;
        let toSendField =  this.template.querySelector("[data-field='toSendField']")
        toSendField.setCustomValidity('')
        toSendField.reportValidity();
    }
    handletoCCSend(e){
        this.toCCSend = e.target.value;
        let toCCSendField =  this.template.querySelector("[data-field='toCCSendField']")
        toCCSendField.setCustomValidity('')
        toCCSendField.reportValidity();
    }
    handletoBCCSend(e){
        this.toBCCSend = e.target.value;
        let toBCCField =  this.template.querySelector("[data-field='toBCCField']")
        toBCCField.setCustomValidity('')
        toBCCField.reportValidity();
    }
    handlesubject(e){
        this.subject = e.target.value;
        let subjectField =  this.template.querySelector("[data-field='subjectField']")
        subjectField.setCustomValidity('')
        subjectField.reportValidity();
    }
    handleBodychange(e){
        this.body = e.target.value;
        let bodyField =  this.template.querySelector("[data-field='bodyField']")
        bodyField.setCustomValidity('')
        bodyField.reportValidity();
    }
    sendEmailClicked(){
        let allValid = true;
        this.isLoading = true;
        let toSendField =  this.template.querySelector("[data-field='toSendField']")
        let subjectField =  this.template.querySelector("[data-field='subjectField']")
        let bodyField =  this.template.querySelector("[data-field='bodyField']")
        if(this.toSend == ''){
            allValid = false;
            toSendField.setCustomValidity('Complete this field.')
            toSendField.reportValidity();
        }
        if(this.subject == ''){
            allValid = false;
            subjectField.setCustomValidity('Complete this field.')
            subjectField.reportValidity();
        }
        if(this.body == ''){
            allValid = false;
            bodyField.setCustomValidity('Complete this field.')
            bodyField.reportValidity();
        }
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        let stringAsHtml =this.body.replace(/\n/g, "<br />\r\n");
        if(allValid && allValid2){
            sendEmail({
                toSend : this.toSend,
                toCCSend : this.toCCSend,
                toBCCSend : this.toBCCSend,
                subject : this.subject,
                body : stringAsHtml,
            }).then(result=>{
                console.log('sendEmail result '+result)
                this.isLoading = false
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error=>{
                this.isLoading = false
                console.log('sendEmail error '+JSON.stringify(error,null,2))
            })
        }
        else{
            this.isLoading = false
        }
    }
    
}