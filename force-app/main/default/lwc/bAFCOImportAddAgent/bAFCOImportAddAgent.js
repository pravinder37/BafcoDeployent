import { LightningElement,track } from 'lwc';
import getAgentsRecords from '@salesforce/apex/BAFCOImportQuoteController.getAgentsRecords';
export default class BAFCOImportAddAgent extends LightningElement {

    selectedAgent='';
    @track agentOption= [];
    @track agentOption2 =[];
    @track totalList = [];
    connectedCallback(){
        this.getRecords();
    }
    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }
    addAgent(){
        let selectedAgentName = '';  
        this.totalList.forEach(elem=>{
            if(elem.Id == this.selectedAgent){
                selectedAgentName = elem.Name
            }
        })
        let obj={
            'Name':selectedAgentName,
            'Id':this.selectedAgent
        }
        this.dispatchEvent(new CustomEvent('addagent', { detail: obj }));
    }
    handleSelectedShippline(e){
        this.selectedAgent = e.target.value;
    }
    getRecords(){
        getAgentsRecords()
        .then(result =>{
            this.shiplineOption = result;            
            let templist = [];
            result.forEach(m => {
            templist.push({
                label: m.Name, value: m.Id
            })
           });
            this.totalList = result;
            let middleIndex = Math.ceil(templist.length / 2);
            let firstHalf = templist.splice(0, middleIndex);   
            let secondHalf = templist.splice(-middleIndex);
            this.agentOption = firstHalf;
            this.agentOption2 = secondHalf;
        })
        .catch(error =>{
            console.log('get shippLine Error '+JSON.stringify(error,null,2))
        });
    }
}