import { LightningElement,api,wire } from 'lwc';
import getQuoteDataOnLoad from '@salesforce/apex/BAFCOQuoteCopyContentController.getQuoteDataOnLoad';
import {CurrentPageReference} from 'lightning/navigation';
export default class BAFCOCopyQuoteItem extends LightningElement {
    @api recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    @api invoke() {
        this.getQuoteDataOnLoad();
      }
    getQuoteDataOnLoad(){
        getQuoteDataOnLoad({quoteId : this.recordId})
        .then(result=>{
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
                    let recordtype = result[0].recordtypeName;
                    if(recordtype == 'Export'){
                        content +='\n\nExclusions:\n\n'
                        content += result[0].exportHeader+':\n';
                        content +=result[0].exportHeaderList
                        content +='\n\nInclusions:\n\n'
                        content +=result[0].header+':\n';
                        content +=result[0].headerList
                    }
                    else if(recordtype == 'Import'){
                        content +='\n\nTerms & Conditions:\n\n';
                        if(result[0].header != undefined) content +=result[0].header+':\n';
                        if(result[0].headerList != undefined)  content +=result[0].headerList
                    }
                }
                if (navigator.clipboard && window.isSecureContext) {
                    return navigator.clipboard.writeText(content);
                    } else {
                        let textArea = document.createElement("textarea");
                        textArea.value = content;
                        textArea.style.position = "fixed";
                        textArea.style.left = "-999999px";
                        textArea.style.top = "-999999px";
                        document.body.appendChild(textArea);
                        textArea.focus();
                        textArea.select();
                        return new Promise((res, rej) => {
                        document.execCommand("copy") ? res() : rej();
                        textArea.remove();
                        this.disableWhatsApp = true;
                        });
                    }
            }
        })
        .catch(error=>{
            console.log('getQuoteDataOnLoad error'+JSON.stringify(error,null,2))
        })
    }
}