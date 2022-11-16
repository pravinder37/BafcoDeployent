import { LightningElement,api } from 'lwc';
export default class BAFCOLeadCreationParentComponent extends LightningElement {
    @api quoteID;
    
    connectedCallback(){
        console.log('quoteID',this.quoteID);
        document.title ='Create Enquiry'
    }
    

}