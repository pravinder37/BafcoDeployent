import { LightningElement,api } from 'lwc';

export default class BafcoLeadEnquiryEntryQty extends LightningElement {
    @api index;
    @api containerType;
    @api quantity;
    @api contr;
    @api containerTypeName;
    @api containerTypeErrorClass = '';
    @api containerQuantityErrorClass = '';
    connectedCallback(){
        console.log('index '+this.index)
        console.log('containerType '+this.containerType)
        console.log('quantity '+this.quantity)
        console.log('quantity '+this.containerTypeName)
        console.log('contr '+JSON.stringify(this.contr,null,2))
    }
    handleContainerTypeSelection(event){
        console.log('came '+JSON.stringify(event.detail))
        let index = event.detail.index;
        let containerTypeID = event.detail.Id;
        let containerTypeName = event.detail.Name;
        this.containerTypeErrorClass = '';
        let obj={
            'index':index,
            'containerTypeID':containerTypeID,
            'containerTypeName':containerTypeName
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containertypeupdate', { detail: { dto: containerDto } }));
    }
    handleContainerTypeRemoved(e){
        let index = e.detail.index;
        let obj={
            'index':index,
            'containerTypeID':'',
            'containerTypeName':'',
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containertypeupdate', { detail: { dto: containerDto } }));
    }
    handleQuantityChange(e){
        let index = e.target.dataset.recordId;
        this.containerQuantityErrorClass = '';
        let quantityValue = e.detail.value;
        let obj={
            'index':index,
            'quantity':quantityValue,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containerqtyupdate', { detail: { dto: containerDto } }));
    }
    handleRemoveContainer(e){
        let strIndex = e.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('removecontainertype', { detail:  strIndex}));
    }
    @api handleCopyData(containerRecord,i){
        console.log('# containerRecord' +JSON.stringify(containerRecord,null,2))
        let containerType = containerRecord.containerType;
        let quantity =  containerRecord.quantity;
        let containerTypeName =  containerRecord.containerTypeName;
        let initalIndex = containerRecord.index;
        let spitInitalIndex = initalIndex.split('.');
        let cameIndex = i;
        let finalIndex = cameIndex+'.'+spitInitalIndex[1]
        if(containerType != ''){
            let field = this.template.querySelector('c-b-a-f-c-o-custom-look-up-component');
            let Obj={Id:containerType,Name:containerTypeName,index:finalIndex}
            if(field != null) field.handleDefaultSelected(Obj);
        }
       let obj={
            'index':finalIndex,
            'quantity':quantity,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containerqtyupdate', { detail: { dto: containerDto } }));
        setTimeout(() => {
            let quantityField = this.template.querySelector("[data-field='quantityField']");
            quantityField.value = quantity
        }, 100);
    }
}