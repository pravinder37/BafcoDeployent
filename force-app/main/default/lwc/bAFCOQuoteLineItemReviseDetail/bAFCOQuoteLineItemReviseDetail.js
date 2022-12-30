import { LightningElement,api,track } from 'lwc';
import getQuoteLineItemDetails from '@salesforce/apex/BAFCOQuotationReviseController.getQuoteLineItemDetails';
export default class BAFCOQuoteLineItemReviseDetail extends LightningElement {
    @api routeName;
    @api routingRegular;
    @api shipmentKind;
    @api serviceType;
    @api portLoading;
    @api portDestination;
    @api shippingLine;
    @api commodity;
    @api cargoWeights;
    @api dangerousGoods;
    @api remarks;
    @api routeId;
    @api pickupPlaceName = '';
    @api dischargePlaceName = '';
    @track quoteLineItemList = [];
    @track quoteLineItemMap = [];
    @api activeQuoteId = '';
    @track routlistNotfound = false;
    @track shippingEquipTabSelected = '';
    @track shippingTabSelected ='';
    @track buyingRate ;
    @track sellingRate;
    @track profitLabel;
    @track margin;
    @track quotationMap=[];
    @track showServiceChargeModal = false;
    @track rmsId = '';
    @track quotationDate = '';
    @api equipmentType =''


    connectedCallback(){
        this.getQuoteLineItemDetails();
    }
    getQuoteLineItemDetails(){
        getQuoteLineItemDetails({
            quoteId : this.activeQuoteId,
            portLoading : this.portLoading,
            portDestination : this.portDestination,
            commodity : this.commodity,
            routeId : this.routeId
        })
        .then(result=>{
            console.log('getQuoteLineItemDetail result',JSON.stringify(result,null,2));
            this.quoteLineItemMap = result;
            if(Object.keys(result).length == 0){
                this.routlistNotfound = true;
            }
            else{
                this.routlistNotfound = false;
                let conts = result;
                for(let key in conts){
                    if(conts[key].length > 0){
                        this.quoteLineItemList.push({value:conts[key], key:key});
                        let templist = [];
                        templist.push({
                            'sellingRate': 0,
                            'profit' : 0,
                            'margin':0,
                            'validity':conts[key][0].validity,
                            'quantity':0,
                            'quotationId':0,
                            'cssClass':''
                        })
                        this.quotationMap.push({value : templist,key:key})
                        let toBeSend = {
                            'routeName':this.routeName,
                            'quotationMap':this.quotationMap
                        }
                        this.dispatchEvent(new CustomEvent('updatecalculation', { detail: toBeSend }));
                    }
                }
                console.log('quoteLineItemList '+JSON.stringify(this.quoteLineItemList,null,2));
                this.shippingEquipTabSelected = this.quoteLineItemList[0].value[0].equipmentName;
            }
        })
        .catch(error=>{
            console.log('getQuoteLineItemDetail error',JSON.stringify(error))
        })
    }

    handleshippingLineActive(e){
        this.shippingTabSelected = e.target.value;
        let dedicatedObj = this.quoteLineItemMap[this.shippingTabSelected];
        console.log('handleshippingLineActive '+JSON.stringify(dedicatedObj,null,2))
        let elem  = 0;
        this.shippingEquipTabSelected = dedicatedObj[elem].equipmentName; 
        this.buyingRate = dedicatedObj[elem].totalBuyingRate;
        this.quotationDate = elem.quotationDate;
        let totalSelling = 0;
        if(dedicatedObj[elem].totalSellingRate > 0) totalSelling=totalSelling+dedicatedObj[elem].totalSellingRate;
        //if(dedicatedObj[elem].totaladditionalCharge > 0) totalSelling=totalSelling+dedicatedObj[elem].totaladditionalCharge;
        //if(dedicatedObj[elem].TotalOrigincharges > 0) totalSelling=totalSelling+dedicatedObj[elem].TotalOrigincharges;
        //if(dedicatedObj[elem].totalSl > 0) totalSelling=totalSelling+dedicatedObj[elem].totalSl;
       // if(dedicatedObj[elem].destinTotalCharges > 0) totalSelling=totalSelling+dedicatedObj[elem].destinTotalCharges;
        this.sellingRate = totalSelling;
        let profit = 0;
            if(this.sellingRate > 0 && !isNaN(this.sellingRate)){
            profit = this.sellingRate - this.buyingRate;
            let margin  = profit/this.sellingRate;
            this.margin = isNaN(margin) ? 0 : margin * 100;
            this.margin = this.margin.toFixed(2);
            profit = isNaN(profit) ? 0 : profit;
            }
            else if(this.sellingRate <= 0 && isNaN(this.sellingRate)){
                this.margin = 0;
                profit = 0;
            }
        this.profitLabel = '$ '+profit +' Profit.';
        let tempMap = this.quotationMap;
            tempMap.forEach(elem=>{
                if(elem.key == this.shippingTabSelected){
                    elem.value.forEach(el =>{
                            el.sellingRate = parseInt(this.sellingRate) 
                            el.profit = parseInt(profit)
                            el.margin =  parseInt(this.margin)
                            el.validity = el.validity
                            el.quantity = 0
                    })
                }
            })
            this.quotationMap = tempMap;
            let toBeSend = {
                'routeName':this.routeName,
                'quotationMap':this.quotationMap
            }
            this.dispatchEvent(new CustomEvent('updatecalculation', { detail: toBeSend }));
        setTimeout(() => {
                let profitButton =  this.template.querySelector('.profitButton');
                if(profitButton != undefined){
                    if(profit > 0){
                        profitButton.style = "background:#4CAF50;height: 50px;border-radius: 4px;"
                    }
                    else{
                        profitButton.style = "background:#FF9800;height: 50px;border-radius: 4px;"
                    }
                }
            }, 100);
            
    }
    handleEquipmentActive(e){
        let profitButton =  this.template.querySelector('.profitButton');
        if(profitButton != undefined){
            profitButton.style = "background:#FF9800;height: 50px;border-radius: 4px;"
        }
        let tabSelected = e.target.value;
        this.shippingEquipTabSelected = tabSelected;
        let dedicatedRoutingObj = this.quoteLineItemMap[this.shippingTabSelected];
        console.log('dedicatedRoutingObj 2'+JSON.stringify(dedicatedRoutingObj,null,2));
        dedicatedRoutingObj.forEach(elem =>{
            if(elem.equipmentName == tabSelected){
                console.log('came '+JSON.stringify(elem,null,2))
                this.rmsId = elem.rmsId;
                this.buyingRate = elem.totalBuyingRate;
                this.quotationDate = elem.quotationDate;
                let totalSelling = 0;
                if(elem.totalSellingRate > 0) totalSelling=totalSelling+elem.totalSellingRate;
                //if(elem.totaladditionalCharge > 0) totalSelling=totalSelling+elem.totaladditionalCharge;
                //if(elem.TotalOrigincharges > 0) totalSelling=totalSelling+elem.TotalOrigincharges;
               // if(elem.totalSl > 0) totalSelling=totalSelling+elem.totalSl;
               // if(elem.destinTotalCharges > 0) totalSelling=totalSelling+elem.destinTotalCharges;
                this.sellingRate = totalSelling;
                let profit = 0;
                if(this.sellingRate > 0 && !isNaN(this.sellingRate)){
                    profit = this.sellingRate - this.buyingRate;
                    let margin  = profit/this.sellingRate;
                    this.margin = isNaN(margin) ? 0 : margin * 100;
                    this.margin = this.margin.toFixed(2);
                    profit = isNaN(profit) ? 0 : profit;
                }
                else if(this.sellingRate <= 0 && isNaN(this.sellingRate)){
                    this.margin = 0;
                    profit = 0;
                }
                this.profitLabel = '$ '+profit +' Profit.';
                let tempMap = this.quotationMap;
                tempMap.forEach(elem=>{
                    if(elem.key == this.shippingTabSelected){
                        elem.value.forEach(el =>{
                                el.sellingRate = parseInt(this.sellingRate) 
                                el.profit = parseInt(profit)
                                el.margin =  parseInt(this.margin)
                                el.validity = el.validity
                                el.quantity = 0
                        })
                    }
                })
                this.quotationMap = tempMap;0
                let toBeSend = {
                    'routeName':this.routeName,
                    'quotationMap':this.quotationMap
                }
                this.dispatchEvent(new CustomEvent('updatecalculation', { detail: toBeSend }));
                setTimeout(() => {
                    let profitButton =  this.template.querySelector('.profitButton');
                    if(profitButton != undefined){
                        if(profit > 0){
                            profitButton.style = "background:#4CAF50;height: 50px;border-radius: 4px;"
                        }
                        else{
                            profitButton.style = "background:#FF9800;height: 50px;border-radius: 4px;"
                        }
                    }
                }, 100);
            }
        });
    }
    handleShowServiceCharge(){
        this.showServiceChargeModal = true; 
    }
    handleCloseModal(){
        this.showServiceChargeModal = false; 
    }
}