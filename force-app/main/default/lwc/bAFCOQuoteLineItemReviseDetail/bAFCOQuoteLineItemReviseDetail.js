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
    @track currencyCode='USD'


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
                        for(let equip in conts[key]){
                            let profit = conts[key][equip].totalSellingRate - conts[key][equip].totalBuyingRate
                            templist.push({
                            'sellingRate': conts[key][equip].totalSellingRate,
                            'profit' : profit,
                            'margin':0,
                            'validity':conts[key][equip].validity,
                            'quantity':0,
                            'quotationId':0,
                            'currencyCode':conts[key][equip].currencyCode,
                            'equipment' : conts[key][equip].equipmentName,
                            'cssClass':''
                        })
                        let parentKey = key+'-'+conts[key][equip].equipmentName+'-'+this.routeName;
                        let existingIndex = this.quotationMap.findIndex(x=>x.key==parentKey);
                        let newTempListIndex = templist.findIndex(x=>x.equipment==conts[key][equip].equipmentName);
                        let NewTempList = [];
                        NewTempList.push(templist[newTempListIndex])
                        if(existingIndex == -1) this.quotationMap.push({value : NewTempList,key:parentKey})
                        let toBeSend = {
                            'routeName':this.routeName,
                            'quotationMap':this.quotationMap
                        }
                        this.dispatchEvent(new CustomEvent('updatecalculation', { detail: toBeSend }));
                    }
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
        this.currencyCode = dedicatedObj[elem].currencyCode;
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
        this.profitLabel = this.currencyCode+' '+profit +' Profit.';
        let tempMap = JSON.parse(JSON.stringify(this.quotationMap));
        let parentKey = this.shippingTabSelected+'-'+this.shippingEquipTabSelected+'-'+this.routeName;
        tempMap.forEach(elem=>{
                if(elem.key == parentKey){
                    elem.value.forEach(el =>{
                            el.sellingRate = parseInt(this.sellingRate) 
                            el.profit = parseInt(profit)
                            el.margin =  parseInt(this.margin)
                            el.validity = el.validity
                            el.quantity = 0
                    })
                }
            })
            this.quotationMap = JSON.parse(JSON.stringify(tempMap));
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
                this.currencyCode = elem.currencyCode
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
                this.profitLabel = this.currencyCode+' '+profit +' Profit.';
                let tempMap = this.quotationMap;
                let parentKey = this.shippingTabSelected+'-'+this.shippingEquipTabSelected+'-'+this.routeName;
                tempMap.forEach(elem=>{
                    if(elem.key == parentKey){
                        elem.value.forEach(el =>{
                                el.sellingRate = parseInt(this.sellingRate) 
                                el.profit = parseInt(profit)
                                el.margin =  parseInt(this.margin)
                                el.validity = el.validity
                                el.currencyCode = el.currencyCode
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