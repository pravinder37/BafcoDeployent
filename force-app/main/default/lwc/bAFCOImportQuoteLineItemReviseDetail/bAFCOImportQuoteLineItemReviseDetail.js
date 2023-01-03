import { LightningElement,api,track } from 'lwc';
import getQuoteLineItemDetails from '@salesforce/apex/BAFCOImportQuotationReviseController.getQuoteLineItemDetails';
export default class BAFCOImportQuoteLineItemReviseDetail extends LightningElement {
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
    @track agentName = '';
    @track quotationDate ='';
    @api equipmentType ='';
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
            if(Object.keys(result).length == 0){
                this.routlistNotfound = true;
            }
            else{
                this.routlistNotfound = false;
                let conts = result;
                this.quoteLineItemMap = result;
                for(let key in conts){
                    let tempList = [];
                    for(let key2 in conts[key]){
                        tempList.push({
                            key2:key2,
                            value2: conts[key][key2]})
                    }
                    this.quoteLineItemList.push({value:tempList, key:key});
                }
                for(let key in conts){
                    for(let key2 in conts[key]){
                        let templist = [];  
                        for(let key3 in conts[key][key2]){
                            templist.push({
                                'sellingRate': 0,
                                'profit' : 0,
                                'margin':0,
                                'validity':conts[key][key2][key3].validity,
                                'quantity':conts[key][key2][key3].quantity,
                                'quotationId':conts[key][key2][key3].quotationId,
                                'currencyCode':conts[key][key2][key3].currencyCode,
                                'equipment' : conts[key][key2][key3].equipmentName,
                                'cssClass':'',
                                savedClicked:false
                            })
                            let parentKey = key+'-'+key2+'-'+conts[key][key2][key3].equipmentName+'-'+this.routeName;
                            let existingIndex = this.quotationMap.findIndex(x=>x.key==parentKey);
                            let newTempListIndex = templist.findIndex(x=>x.equipment==conts[key][key2][key3].equipmentName);
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
                this.shippingEquipTabSelected = this.quoteLineItemList[0].value[0].value2[0].equipmentName;
                this.shippingTabSelected = this.quoteLineItemList[0].value[0].key2;
            }
        })
        .catch(error=>{
            console.log('getQuoteLineItemDetail error',JSON.stringify(error))
            
        })
    }
    handleAgentActive(e){
        this.agentName = e.target.value
        let dedicatedObj = this.quoteLineItemMap[this.agentName];
        let templist = [];
        for(let key in dedicatedObj){
            templist.push({key:key, data: dedicatedObj[key]})
        }
        let elem = 0;
        this.shippingTabSelected = templist[elem].key;
        let data =templist[elem].data;
        console.log('data ',JSON.stringify(data,null,2))
        this.shippingEquipTabSelected = data[elem].equipmentName; 
        let totalSelling = 0;
        if(data[elem].totalSellingRate > 0) totalSelling=totalSelling+data[elem].totalSellingRate;
        //if(data[elem].totaladditionalCharge > 0) totalSelling=totalSelling+data[elem].totaladditionalCharge;
       // if(data[elem].TotalOrigincharges > 0) totalSelling=totalSelling+data[elem].TotalOrigincharges;
       // if(data[elem].totalSl > 0) totalSelling=totalSelling+data[elem].totalSl;
       // if(data[elem].destinTotalCharges > 0) totalSelling=totalSelling+data[elem].destinTotalCharges;
        this.buyingRate = data[elem].totalBuyingRate;
        this.sellingRate = totalSelling;
        this.quotationDate = data[elem].quotationDate;
        this.currencyCode = data[elem].currencyCode;
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
        let key = this.agentName+'-'+this.shippingTabSelected+'-'+this.shippingEquipTabSelected+'-'+this.routeName         
        tempMap.forEach(elem=>{
            if(elem.key == key){
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
    handleshippingLineActive(e){
        this.shippingTabSelected = e.target.value
        let dedicatedObj = this.quoteLineItemMap[this.agentName];
        let templist = [];
        for(let key in dedicatedObj){
            templist.push({key:key, data: dedicatedObj[key]})
        }
        let data = [];
        templist.forEach(elem=>{
            if(elem.key == this.shippingTabSelected){
                data= elem.data
            }
        })
        let elem  = 0;
        this.shippingEquipTabSelected  =  data[elem].equipmentName;
        let totalSelling = 0;
        if(data[elem].totalSellingRate > 0) totalSelling=totalSelling+data[elem].totalSellingRate;
        //if(data[elem].totaladditionalCharge > 0) totalSelling=totalSelling+data[elem].totaladditionalCharge;
       // if(data[elem].TotalOrigincharges > 0) totalSelling=totalSelling+data[elem].TotalOrigincharges;
       // if(data[elem].totalSl > 0) totalSelling=totalSelling+data[elem].totalSl;
       // if(data[elem].destinTotalCharges > 0) totalSelling=totalSelling+data[elem].destinTotalCharges;
        this.buyingRate = data[elem].totalBuyingRate;
        this.quotationDate = data[elem].quotationDate;
        this.currencyCode = data[elem].currencyCode
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
        let key = this.agentName+'-'+this.shippingTabSelected+'-'+this.shippingEquipTabSelected+'-'+this.routeName
            tempMap.forEach(elem=>{
                if(elem.key == key){
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
        this.shippingEquipTabSelected = e.target.value
        let dedicatedObj = this.quoteLineItemMap[this.agentName];
        let templist = [];
        for(let key in dedicatedObj){
            templist.push({key:key, data: dedicatedObj[key]})
        }
        let data = [];
        templist.forEach(elem=>{
            if(elem.key == this.shippingTabSelected){
                data= elem.data
            }
        })
        data.forEach(ele =>{
            if(ele.equipmentName == this.shippingEquipTabSelected){
                let totalSelling = 0;
                if(ele.totalSellingRate > 0) totalSelling=totalSelling+ele.totalSellingRate;
                //if(ele.totaladditionalCharge > 0) totalSelling=totalSelling+ele.totaladditionalCharge;
                //if(ele.TotalOrigincharges > 0) totalSelling=totalSelling+ele.TotalOrigincharges;
               // if(ele.totalSl > 0) totalSelling=totalSelling+ele.totalSl;
               // if(ele.destinTotalCharges > 0) totalSelling=totalSelling+ele.destinTotalCharges;
                this.buyingRate = ele.totalBuyingRate;
                this.quotationDate = ele.quotationDate;
                this.sellingRate =totalSelling;
                this.rmsId = ele.rmsId;
                this.currencyCode = ele.currencyCode;
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
                let key = this.agentName+'-'+this.shippingTabSelected+'-'+this.shippingEquipTabSelected+'-'+this.routeName
                tempMap.forEach(elem=>{
                    if(elem.key == key){
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
        })
    }
    handleShowServiceCharge(){
        this.showServiceChargeModal = true; 
    }
    handleCloseModal(){
        this.showServiceChargeModal = false; 
    }
}