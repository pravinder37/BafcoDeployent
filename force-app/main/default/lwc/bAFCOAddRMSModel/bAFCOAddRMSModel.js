import { LightningElement ,api,track,wire} from 'lwc';
import RATE_TYPE_FIELD from '@salesforce/schema/RMS__c.Rate_Type__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import addRates from '@salesforce/apex/BAFCOLRoutingDetailsController.addRates';
import getRouteEquipType from '@salesforce/apex/BAFCOLRoutingDetailsController.getRouteEquipType';
import getLoadingCharges from '@salesforce/apex/BAFCOLRoutingDetailsController.getLoadingCharges';
import getExchangeRate from '@salesforce/apex/BAFCOLRoutingDetailsController.getExchangeRate';
import DIRECTION_FIELD from '@salesforce/schema/Loading_Charge__c.Direction__c';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/RMS__c.Business_Type__c';
export default class 
 extends LightningElement {
    @api portLoading ='';
    @api portDestination ='';
    @api commodity = '';
    @api shippingLine ='';
    @api equipmentType = '';
    @api routeId ='';
    @api leadId = '';
    @api pickupPlace ='';
    @api dischargePlace = '';
    @api portLoadingId='';
    @api incoTerm = '';
    @api incoTermId = '';
    @api agentObject;
    @api cameFromImport = false;

    @track validity = '';
    @track rateType = '';
    @track rateTypeOption =[];
    @track seaFreight = '';
    @track emptyEquipType = true;
    @track pickListvalues =[];
    @api businessType = '';
    @track todaysDate = '';
    @track allInRate = false;
    @track FOBAllIn = false;
    @track ExWorksIn = false;
    @track oceanfreightCheckbox = false;
    @track displayOriginCharge = true;
    @track displayShippingCharge = true;
    @track displayDestinCharge = true;
    @track FreeTime = 0;
    @track FreeTimePOD = 0;
    @track remarks ='';
    @track curencyCodeOption = [];
    @track shippExchangeRate = '';
    @track shippOffSet = '';
    @track incoExchangeRate = '';
    @track incoOffSet = '';
    @track destinExchangeRate = '';
    @track destinOffSet = '';

    bayan = 0;                
    destinationCustomsClearance = 0; 
    destinationLoadingCharges = 0; 
    fasahFee = 0; 
    inspection = 0;              
    liftOnLiftOff = 0;                  
    originCustomsclearance = 0;               
    originLoadingCharges = 0;              
    portShuttling = 0;                    
    tabadul = 0;                 
    xray = 0;               
    total = 0;
    @track incoTotal = 0 ;
    loadingCharge = 0;
    
    BAF = 0;
    BunkerSurcharge = 0;
    ISPS = 0;
    OTHC = 0;
    CMC = 0;
    EIC = 0;
    sealCharges = 0;
    DTHC = 0;
    Total = 0;
    shippTotal =0;

    @track shipp = {};
    @track incoCharges ={};
    @track destinCharges ={};
    @track rmsDetail ={};
    @track pickListvaluesBusinessType = [];

    @track incoChargeTotalChange = false; 
    @track shippTotalChanged = false; 
    @track DirectionOptions = [];
    @track directionValue = '';
    @track destinTotalChanged = false;
    @track disableShippOffSet = true;
    @track disableIncoOffSet = true;
    @track disableDestinOffSet = true;
    @track agentName ='';

    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : DIRECTION_FIELD
    })directionPickListValue({ data, error }){
            if(data){
                //console.log(` DIRECTION_FIELD values are `, data.values);
                this.DirectionOptions = data.values;
                this.directionValue = this.DirectionOptions[0].value;
                this.getLoadingCharges();
                this.error = undefined;
            }
            if(error){
                console.log(` Error while fetching DIRECTION_FIELD Picklist values  ${error}`);
                this.error = error;
                this.DirectionOptions = undefined;
            }
    }

    connectedCallback(){
        console.log('*equipmentType '+JSON.stringify(this.equipmentType))
        console.log('*route '+JSON.stringify(this.routeId))
        this.getRouteEquipType();
        this.getExchangeRate();
        let templist = {
            'BAF':0,
            'BunkerSurcharge':0,
            'ISPS':0,
            'OTHC':0,
            'CMC':0,
            'EIC':0,
            'sealCharges':0,
            'DTHC':0,
            'Total':0,
            'currencyCode':'USD',
            'carriageCongestionSurcharg':0,
            'carrierSecurityFees':0,
            'cleaningCharges':0,
            'DGSurcharge':0,
            'inlandFuelSurcharge':0,
            'inlandHandlingFees':0,
            'inlandhaulage':0,
            'lowSulphurSurcharge':0,
            'operationalRecoverySurcharge':0,
            'overweightsurcharge':0,
            'warRiskSurcharge':0,
            'offSet':0   
        }
        this.shipp = templist;

        let tempList2 = {             
            'bayan' : 0,           
            'fasahFee' : 0,
            'inspection' : 0,                
            'liftOnLiftOff' : 0,                    
            'originCustomsclearance' : 0,                
            'originLoadingCharges' : 0,                
            'portShuttling' : 0,                    
            'tabadul' : 0,                
            'xray' : 0,                
            'total' : 0,
            'loadingCharge':0,
            'loadingChargeId':'',
            'currencyCode':'USD',
            'bLFees':0,
            'exportServiceFees':0,
            'fuelSurcharge':0,
            'insuranceCharges':0,
            'originDetentionDemurrageCharges':0,
            'OTHC':0,
            'pickupCharges':0,
            'reeferPluginCharges':0,
            'tarpaulinCharges':0,
            'truckidlingCharges':0,
            'vGM':0,
            'lashingCharges':0,
            'offSet':0        
        }
        this.incoCharges = tempList2;

        let templist3 = {
            'bayanCharges':0,
            'customClearance':0,
            'doCharges':0,
            'DTHC':0,
            'fasahCharges':0,
            'gatePassCharges':0,
            'LOLOCharges':0,
            'total':0,
            'transportation':0,
            'currencyCode':'USD',
            'offSet':0   
        }
        this.destinCharges = templist3;

        let rmsDetail = {
            'rateType':'',
            'validity':'',
            'businessType':this.businessType,
            'seaFreight':0,
            'allInRate':false,
            'FOBAllIn':false,
            'ExWorksIn':false,
            'oceanfreightCheckbox':false,
            'remarks':'',
            'agentName':'',
            'incoTermId':this.incoTermId,
            'customerName':''
        }
        this.rmsDetail = rmsDetail;
        this.todaysDate = new Date().toISOString();
        this.validity = this.formatDate(this.todaysDate,0)
        this.rmsDetail.validity = this.validity;
        if(this.cameFromImport == 'true'){
            this.agentName = this.agentObject.Name;
            this.rmsDetail.agentName = this.agentObject.Id;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : RATE_TYPE_FIELD
    })wiredPickListValue({ data, error }){
            if(data){
                //console.log(` Picklist values are `, data.values);
                this.rateTypeOption = data.values;
            }
            if(error){
                console.log(` Error while fetching Picklist values  ${error}`);
                this.rateTypeOption = undefined;
            }
        }

      
        @wire(getPicklistValues, {
            recordTypeId : '012000000000000AAA',
            fieldApiName : BUSINESS_TYPE_FIELD
        })wiredBussinessPickListValue({ data, error }){
                if(data){
                    //console.log(` business Picklist values are `, data.values);
                    this.pickListvaluesBusinessType = data.values;
                }
                if(error){
                    console.log(` Error business while fetching Picklist values  ${error}`);
                    this.pickListvaluesBusinessType = undefined;
                }
            }
    
    
    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }
    handleValidityChange(e){
        this.validity = e.target.value;
        this.rmsDetail.validity = this.validity;
    }    
    handleShippCurrencyCodeSelection(e){
        this.shipp.currencyCode = e.target.value;
        this.curencyCodeOption.forEach(elem=>{
            if(elem.value == e.target.value){
                this.shippExchangeRate = elem.exchangeRate
                this.shippOffSet = elem.offSet
                this.shipp.offSet = elem.offSet
            }
        })
        if(this.shipp.currencyCode == 'USD') {
            this.disableShippOffSet = true;
            this.shipp.offSet = 0;
        }
        else{
            this.disableShippOffSet = false;
        }
        
    }
    handleShippOffestChange(e){
        this.shipp.offSet = e.target.value;
    }
    handleINCOCurrencyCodeSelection(e){
        this.incoCharges.currencyCode = e.target.value;
        this.curencyCodeOption.forEach(elem=>{
            if(elem.value == e.target.value){
                this.incoExchangeRate = elem.exchangeRate
                this.incoOffSet = elem.offSet
                this.incoCharges.offSet = elem.offSet
            }
        })
        if(this.incoCharges.currencyCode == 'USD') {
            this.disableIncoOffSet = true;
            this.incoCharges.offSet = 0;
        }
        else{
            this.disableIncoOffSet = false;
        }
    }
    handleIncoOffsetChange(e){
        this.incoCharges.offSet = e.target.value;
    }
    handleDestinCurrencyCodeSelection(e){
        this.destinCharges.currencyCode = e.target.value;
        this.curencyCodeOption.forEach(elem=>{
            if(elem.value == e.target.value){
                this.destinExchangeRate = elem.exchangeRate
                this.destinOffSet = elem.offSet
                this.destinCharges.offSet = elem.offSet
            }
        })
        if(this.destinCharges.currencyCode == 'USD') {
            this.disableDestinOffSet = true;
            this.destinCharges.offSet = 0;
        }
        else{
            this.disableDestinOffSet = false;
        }
    }
    handleDestinOffSetChange(e){
        this.destinCharges.offSet = e.target.value;
    }
    handleAllInRateChange(e){
        this.FOBAllIn = false;
        this.ExWorksIn = false;
        this.oceanfreightCheckbox = false;
        this.allInRate = e.target.checked;
        this.updateRMSCheckBox();
    }
    handleFOBAllInChange(e){
        this.allInRate = false;
        this.ExWorksIn = false;
        this.oceanfreightCheckbox = false;
        this.FOBAllIn = e.target.checked;
        this.updateRMSCheckBox();
    }
    handleExWorksChange(e){
        this.FOBAllIn = false;
        this.allInRate = false;
        this.oceanfreightCheckbox = false;
        this.ExWorksIn = e.target.checked;
        this.updateRMSCheckBox();
    }
    handleoceanfreightCheckboxChange(e){
        this.FOBAllIn = false;
        this.allInRate = false;
        this.ExWorksIn = false;
        this.oceanfreightCheckbox = e.target.checked;
        this.updateRMSCheckBox();
    }
    updateRMSCheckBox(){
        if(this.allInRate == true){
            this.FOBAllIn = false;
            this.ExWorksIn = false;
            this.oceanfreightCheckbox = false;
            this.displayOriginCharge = false;
            this.displayShippingCharge = false;
            this.displayDestinCharge= true;
        }
        else if(this.FOBAllIn == true){
            this.allInRate = false;
            this.ExWorksIn = false;
            this.oceanfreightCheckbox = false;
            this.displayShippingCharge = false;
            this.displayOriginCharge = false;
            this.displayDestinCharge= true;
        }
        else if(this.ExWorksIn == true){
            this.FOBAllIn = false;
            this.allInRate = false;
            this.oceanfreightCheckbox = false;
            this.displayShippingCharge = false;
            this.displayOriginCharge = false;
            this.displayDestinCharge= true;
        }else if(this.oceanfreightCheckbox == true){
            this.FOBAllIn = false;
            this.allInRate = false;
            this.displayShippingCharge = true;
            this.displayOriginCharge = false;
            this.displayDestinCharge= false;
        }
        else if(this.allInRate == false &&  this.FOBAllIn == false && this.ExWorksIn == false && this.oceanfreightCheckbox == false){
            this.displayShippingCharge = true;
            this.displayOriginCharge = true;
            this.displayDestinCharge= true;
        }
        this.rmsDetail.allInRate = this.allInRate;
        this.rmsDetail.FOBAllIn = this.FOBAllIn;
        this.rmsDetail.ExWorksIn = this.ExWorksIn;
        this.rmsDetail.oceanfreightCheckbox = this.oceanfreightCheckbox;
        //console.log('rms  '+JSON.stringify(this.rmsDetail,null,2))
    }
    handleRemarksChange(e){
        this.remarks = e.target.value;
        this.rmsDetail.remarks = this.remarks
    }
    handleFreeTimeChange(e){
        this.FreeTime = e.target.value
        this.rmsDetail.FreeTime = this.FreeTime
    }
    handleFreeTimePODChange(e){
        this.FreeTimePOD = e.target.value
        this.rmsDetail.FreeTimePOD = this.FreeTimePOD
    }
    handleRateTypeChange(e){
        this.rateType = e.target.value;
        this.rmsDetail.rateType = this.rateType;
        if(this.rateType == 'Spot'){
            this.validity = this.formatDate(this.todaysDate,0)
        }
        else if(this.rateType == 'Contract'){
            this.validity = this.formatDate(this.todaysDate,15)
        }
        this.rmsDetail.validity = this.validity 
    }
    formatDate(date,days) {
        let date1 = new Date(date);
        date1.setDate(date1.getDate() + days)
        let d = new Date(date1),
            month = '' + (d.getMonth() + 1),
            day = '' + (d.getDate()),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    }
    handleSeaFreightChange(e){
        this.seaFreight = parseInt(e.target.value);
        this.rmsDetail.seaFreight = this.seaFreight;
    }
    handleBusinessTypeChange(e){
        this.businessType = e.target.value;
        this.rmsDetail.businessType = this.businessType;
    }
    handletotalChange(e){
        this.incoCharges.total = parseInt(e.target.value);
        if(!isNaN(this.incoCharges.total)) this.incoChargeTotalChange = true;
        else this.incoChargeTotalChange = false;
    }
    submitDetails(){
        addRates({
            rmsDetail: this.rmsDetail,
            routeId : this.routeId,
            shippingChargeDto : this.shipp,
            incocharges : this.incoCharges,
            totalShippChanged : this.shippTotalChanged,
            totalIncoChanged : this.incoChargeTotalChange,
            equipmentType : this.equipmentType,
            shippingLine : this.shippingLine,
            leadId : this.leadId,
            destinTotalChanged : this.destinTotalChanged,
            destinCharges:this.destinCharges

        }).then(result =>{
            console.log('result  '+JSON.stringify(result))
            this.dispatchEvent(new CustomEvent('success'));
        }).catch(error=>{
            console.log('error add rate : ', JSON.stringify(error));
        });
    }
    handleBAFChange(e){
        this.shipp.BAF = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleBunkerSurchargeChange(e){
        this.shipp.BunkerSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleISPSChange(e){
        this.shipp.ISPS = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleOTHCChange(e){
        this.shipp.OTHC = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleCMCChange(e){
        this.shipp.CMC = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleEICChange(e){
        this.shipp.EIC = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlesealChargesChange(e){
        this.shipp.sealCharges = parseInt(e.target.value);
        this.updateShippingTotal();
    }    
    handleshippTotalChange(e){
        this.shipp.Total = e.target.value;
        if(!this.shipp.Total == '') this.shippTotalChanged = true;
        else this.shippTotalChanged = false;
    }
    handleDTHCChange(e){
        this.shipp.DTHC = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlebayanChange(e){
        this.incoCharges.bayan = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlefasahFeeChange(e){
        this.incoCharges.fasahFee = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleinspectionChange(e){
        this.incoCharges.inspection = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleliftOnLiftOffChange(e){
        this.incoCharges.liftOnLiftOff = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleoriginCustomsclearanceChange(e){
        this.incoCharges.originCustomsclearance = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleoriginLoadingChargesChange(e){
        this.incoCharges.originLoadingCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleportShuttlingChange(e){
        this.incoCharges.portShuttling = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handletabadulChange(e){
        this.incoCharges.tabadul = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlexrayChange(e){
        this.incoCharges.xray = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleLoadingChargeChange(e){
        this.incoCharges.loadingCharge = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    updaTeIncoChargeTotal(){
        let Total = 0 ;
        Total = Total + this.incoCharges.bayan  ;    
        Total = Total + this.incoCharges.fasahFee ;
        Total = Total + this.incoCharges.inspection   ;        
        Total = Total + this.incoCharges.liftOnLiftOff    ;           
        Total = Total +  this.incoCharges.originCustomsclearance   ;         
        Total = Total +  this.incoCharges.originLoadingCharges    ; 
        Total = Total +  this.incoCharges.portShuttling  ;                 
        Total = Total +  this.incoCharges.tabadul  ;               
        Total = Total +  this.incoCharges.xray ;
        Total = Total +  this.incoCharges.loadingCharge ;
        Total = Total +  this.incoCharges.bLFees ;
        Total = Total + this.incoCharges.fuelSurcharge;
        Total = Total +  this.incoCharges.exportServiceFees ;
        Total = Total +  this.incoCharges.insuranceCharges ;
        Total = Total +  this.incoCharges.lashingCharges ;
        Total = Total +  this.incoCharges.originDetentionDemurrageCharges ;
        Total = Total +  this.incoCharges.OTHC ;
        Total = Total +  this.incoCharges.pickupCharges ;
        Total = Total +  this.incoCharges.reeferPluginCharges ;
        Total = Total +  this.incoCharges.tarpaulinCharges ;
        Total = Total +  this.incoCharges.truckidlingCharges ;
        Total = Total +  this.incoCharges.vGM ;
        this.incoCharges.total = parseInt(Total);
        this.incoTotal = parseInt(Total);
    }
    updateShippingTotal(){
        let Total = 0 ;
        Total = Total + this.shipp.BAF;
        Total = Total +   this.shipp.BunkerSurcharge;
        Total = Total +   this.shipp.ISPS;
        Total = Total +   this.shipp.OTHC;
        Total = Total +   this.shipp.CMC;
        Total = Total +   this.shipp.EIC;
        Total = Total +   this.shipp.sealCharges;
        Total = Total +   this.shipp.DTHC;
        Total = Total +   this.shipp.carriageCongestionSurcharg;
        Total = Total +   this.shipp.carrierSecurityFees;
        Total = Total +   this.shipp.cleaningCharges;
        Total = Total +   this.shipp.DGSurcharge;
        Total = Total +   this.shipp.inlandFuelSurcharge;
        Total = Total +   this.shipp.inlandHandlingFees;
        Total = Total +   this.shipp.inlandhaulage;
        Total = Total +   this.shipp.lowSulphurSurcharge;
        Total = Total +   this.shipp.operationalRecoverySurcharge;
        Total = Total +   this.shipp.overweightsurcharge;
        Total = Total +   this.shipp.warRiskSurcharge;

        this.shipp.total = parseInt( Total);
        this.shippTotal = parseInt(Total)

    }
    getRouteEquipType(){
        getRouteEquipType({routeId : this.routeId})
        .then(result =>{
            //console.log('getRouteEquipType '+JSON.stringify(result,null,2));
            let temp = [];
            result.forEach(element => {
                temp.push({
                    label : element.Equipment_Type__r.Name,
                    value:element.Equipment_Type__r.Name
                })
            });
            this.pickListvalues = temp;
            this.equipmentType = this.pickListvalues[0].value;
        })
        .catch(error =>{
            console.log('get equip Error '+JSON.stringify(error))
        })
    }
    handleEquipSelection(e){
        this.equipmentType = e.detail.value;
    }
    handleDirectionChange(event){
        this.directionValue  = event.target.value;
        this.getLoadingCharges();
    }
    getLoadingCharges(){
        if(this.pickupPlace != undefined && this.portLoadingId != undefined && this.directionValue != undefined){
            getLoadingCharges({
                pickupPlace:this.pickupPlace,
                portLoading:this.portLoadingId,
                directionValue:this.directionValue
            })
            .then(result =>{
               console.log('result '+JSON.stringify(result));
               this.incoCharges.loadingCharge = result[0].Loading_Charge__c;
               this.loadingCharge = result[0].Loading_Charge__c;
               this.incoCharges.loadingChargeId = result[0].Id;
               this.updaTeIncoChargeTotal();
            })
            .catch(error =>{
                console.log('get equip Error '+JSON.stringify(error))
            })
        }
    }
    handleDestinbayanChargesChange(e){
        this.destinCharges.bayanCharges = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestincustomClearanceChange(e){
        this.destinCharges.customClearance = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestindoChargesChange(e){
        this.destinCharges.doCharges = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    /*handleDestinDTHCChange(e){
        this.destinCharges.DTHC = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }*/
    handleDestinfasahChargesChange(e){
        this.destinCharges.fasahCharges = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestingatePassChargesChange(e){
        this.destinCharges.gatePassCharges = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestinLOLOChargesChange(e){
        this.destinCharges.LOLOCharges = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestintransportationChange(e){
        this.destinCharges.transportation = parseInt(e.target.value);
        this.updaTeDetinChargesChargeTotal();
    }
    handleDestitotalChange(e){
        this.destinCharges.total = parseInt(e.target.value);
        if(!isNaN(this.destinCharges.total)) this.destinTotalChanged = true;
        else this.destinTotalChanged =false;
    }
    updaTeDetinChargesChargeTotal(){
        let Total = 0;
        Total = Total + (this.destinCharges.transportation != null ? this.destinCharges.transportation : 0);
        Total = Total + (this.destinCharges.LOLOCharges != null ? this.destinCharges.LOLOCharges : 0)
        Total = Total + (this.destinCharges.gatePassCharges != null ? this.destinCharges.gatePassCharges : 0)
        Total = Total + (this.destinCharges.fasahCharges != null ? this.destinCharges.fasahCharges : 0)
        Total = Total + (this.destinCharges.doCharges != null ? this.destinCharges.doCharges : 0)
        Total = Total + (this.destinCharges.customClearance != null ? this.destinCharges.customClearance : 0)
        Total = Total + (this.destinCharges.bayanCharges != null ? this.destinCharges.bayanCharges : 0)
        this.destinCharges.total = parseInt( Total);

        console.log('this.destinCharges '+JSON.stringify(this.destinCharges,null,2))
    }
    getExchangeRate(){
        getExchangeRate()
        .then(result=>{
            let templist = [];
            //console.log('getExchangeRate res',JSON.stringify(result,null,2))
            if(result != null){
                result.forEach(elem => {
                    templist.push({
                        label:elem.Currency_Code__c,
                        value:elem.Currency_Code__c,
                        exchangeRate:elem.Final_Rate__c,
                        offSet:elem.Offset_Value__c != undefined ? elem.Offset_Value__c : 0
                    })
                });
            }
            this.curencyCodeOption = templist;
        })
        .catch(error=>{
            console.log('getExchangeRate err',JSON.stringify(error,null,2))
        })
    }
    handleAgentSelection(e){
        this.rmsDetail.agentName = e.detail.Id;
    }
    handleAgentRemoved(e){
        this.rmsDetail.agentName = '';
    }
    handlecarriageCongestionSurchargChange(e){
        this.shipp.carriageCongestionSurcharg = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlewarRiskSurchargeChange(e){
        this.shipp.warRiskSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlecarrierSecurityFeesChange(e){
        this.shipp.carrierSecurityFees = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleDGSurchargehange(e){
        this.shipp.DGSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleinlandFuelSurchargeChange(e){
        this.shipp.inlandFuelSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleinlandHandlingFeesChange(e){
        this.shipp.inlandHandlingFees = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleinlandhaulageChange(e){
        this.shipp.inlandhaulage = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleLSSChange(e){
        this.shipp.lowSulphurSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleORSChange(e){
        this.shipp.operationalRecoverySurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleoverweightsurchargeChange(e){
        this.shipp.overweightsurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlecleaningChargesChange(e){
        this.shipp.cleaningCharges = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handlebLFeesChange(e){
        this.incoCharges.bLFees = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleexportServiceFeesChange(e){
        this.incoCharges.exportServiceFees = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlefuelSurchargeChange(e){
        this.incoCharges.fuelSurcharge = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleinsuranceChargesChange(e){
        this.incoCharges.insuranceCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlelashingChargesChange(e){
        this.incoCharges.lashingCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleoriginDetentionDemurrageChargesChange(e){
        this.incoCharges.originDetentionDemurrageCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleOTHChange(e){
        this.incoCharges.OTHC = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlepickupChargesChange(e){
        this.incoCharges.pickupCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlereeferPluginChargesChange(e){
        this.incoCharges.reeferPluginCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handletarpaulinChargesChange(e){
        this.incoCharges.tarpaulinCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handletruckidlingChargesChange(e){
        this.incoCharges.truckidlingCharges = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handlevGMChange(e){
        this.incoCharges.vGM = parseInt(e.target.value);
        this.updaTeIncoChargeTotal();
    }
    handleCustomerSelection(e){
        this.rmsDetail.customerName = e.detail.Id;
    }
    handleCustomerRemoved(e){
        this.rmsDetail.customerName = '';
    }
}