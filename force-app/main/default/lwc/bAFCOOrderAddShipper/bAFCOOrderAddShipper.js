import { LightningElement,track,api } from 'lwc';

export default class BAFCOOrderAddShipper extends LightningElement {
    @track shipperList = [];
    @track shipperIndex = 0;
    @api parentShipperList = [];
    isLoading = false;
    connectedCallback(){
        if(this.parentShipperList.length > 0){
            this.isLoading = true;
            this.shipperList = JSON.parse(JSON.stringify(this.parentShipperList))
            console.log('this.shipperList** '+JSON.stringify(this.shipperList,null,2))
            setTimeout(() => {
                for(let i = 0; i<this.shipperList.length; i++){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[i];
                    if(this.shipperList[i].shipperId != null){
                        let Obj = {Id:this.shipperList[i].shipperId,Name:this.shipperList[i].shipperName}
                        if(field != undefined) field.handleDefaultSelected(Obj)
                    }
                }
                this.isLoading = false;
            }, 100);
        }
        else{
            this.shipperIndex =  0
            this.addShipper();
        }
    }
    addShipper(){
        this.isLoading = true;
        let shipperObj = {
            'shipperId':null,
            'shipperName':null,
            'index':this.shipperIndex++
        }
        if(this.shipperList.length < 3)
        this.shipperList.push(shipperObj);
        this.dispatchUpdate();
        this.isLoading = false;
    }
    handleShipperSelection(e){
        let index  = e.detail.index;
        let shipperIndex = this.shipperList.findIndex(x=>x.index == index)
        if(shipperIndex != -1){
            this.shipperList[shipperIndex].shipperId = e.detail.Id;
            this.shipperList[shipperIndex].shipperName = e.detail.Name;
        }
        this.dispatchUpdate();
    }
    handleShipperRemoved(e){
        let index  = e.detail.index;
        let shipperIndex = this.shipperList.findIndex(x=>x.index == index)
        if(shipperIndex != -1){
            console.log('shipperIndex '+shipperIndex)
            this.shipperList[shipperIndex].shipperId = null;
            this.shipperList[shipperIndex].shipperName = null;
        }
        this.dispatchUpdate();
    }
    handleRemoveShipper(e){
        let index = e.target.dataset.recordId;
        let shipperIndex = this.shipperList.findIndex(x=>x.index == index)
        if(shipperIndex != -1){
            this.shipperList.splice(shipperIndex,1)
        }
        this.assignDefault();
        this.dispatchUpdate();
    }
    dispatchUpdate(){
        let shipperList = JSON.parse(JSON.stringify(this.shipperList));
        this.dispatchEvent(new CustomEvent('shipperupdate', { detail: shipperList }));
    }
    assignDefault(){
        this.isLoading = true
        setTimeout(() => {
            for(let i = 0; i<this.shipperList.length; i++){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[i];
                if(this.shipperList[i].shipperId != null){
                    let Obj = {Id:this.shipperList[i].shipperId,Name:this.shipperList[i].shipperName}
                    if(field != undefined) field.handleDefaultSelected(Obj)
                }
            }
        }, 100);
        this.isLoading = false
    }
}