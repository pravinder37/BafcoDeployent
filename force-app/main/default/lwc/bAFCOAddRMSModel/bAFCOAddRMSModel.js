import { LightningElement ,api,track,wire} from 'lwc';
import RATE_TYPE_FIELD from '@salesforce/schema/RMS__c.Rate_Type__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import addRates from '@salesforce/apex/BAFCOLRoutingDetailsController.addRates';
import getRouteEquipType from '@salesforce/apex/BAFCOLRoutingDetailsController.getRouteEquipType';
import getLoadingCharges from '@salesforce/apex/BAFCOLRoutingDetailsController.getLoadingCharges';
import getExchangeRate from '@salesforce/apex/BAFCOLRoutingDetailsController.getExchangeRate';
import DIRECTION_FIELD from '@salesforce/schema/Loading_Charge__c.Direction__c';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/RMS__c.Business_Type__c';
import getDefualtValueForRMS from '@salesforce/apex/BAFCOLRoutingDetailsController.getDefualtValueForRMS';
import getDefaultImportAddRate from '@salesforce/apex/BAFCOLRoutingDetailsController.getDefaultImportAddRate';
import addRouteEquipment from '@salesforce/apex/BAFCOLRoutingDetailsController.addRouteEquipment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BAFCOAddRMSModel
 extends LightningElement {
    @api portLoading ='';
    @api portDestination ='';
    @track commodity = '';
    @api shippingLine ='';
    @api equipmentType = '';
    @api routeId ='';
    @api leadId = '';
    @api pickupPlace ='';
    @api dischargePlace = '';
    @api portLoadingId='';
    @api incoTerm = '';
    @track incoTermId = '';
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
    @track isLoading = false;

    bayan = null;                
    destinationCustomsClearance = null; 
    destinationLoadingCharges = null; 
    fasahFee = null; 
    inspection = null;              
    liftOnLiftOff = null;                  
    originCustomsclearance = null;               
    originLoadingCharges = null;              
    portShuttling = null;                    
    tabadul = null;                 
    xray = null;               
    total = null;
    @track incoTotal = null ;
    loadingCharge = null;
    
    BAF = null;
    BunkerSurcharge = null;
    ISPS = null;
    OTHC = null;
    CMC = null;
    EIC = null;
    sealCharges = null;
    DTHC = null;
    Total = null;
    shippTotal =null;

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

    //Container Var
    @track displayAddRouteEquip = false;
    @track containerRecord = [];
    @track contrIndex = 0;
    @track noRecord = false;
    @track toDeleteRecord = [];


    @track commodityError = '';
    @track incoTermError = '';
    @track equipmentTypeError = '';
    @track rateTypeError = '';
    @track validityError = '';
    @track seaFreightError = '';

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
        this.getRouteEquipType();
        this.getExchangeRate();
        this.getDefualtValueForRMS();
        let templist = {
            'BAF':null,
            'BunkerSurcharge':null,
            'ISPS':null,
            'OTHC':null,
            'CMC':null,
            'EIC':null,
            'sealCharges':null,
            'DTHC':null,
            'Total':null,
            'currencyCode':'USD',
            'carriageCongestionSurcharg':null,
            'carrierSecurityFees':null,
            'cleaningCharges':null,
            'DGSurcharge':null,
            'inlandFuelSurcharge':null,
            'inlandHandlingFees':null,
            'inlandhaulage':null,
            'lowSulphurSurcharge':null,
            'operationalRecoverySurcharge':null,
            'overweightsurcharge':null,
            'warRiskSurcharge':null,
            'offSet':null   
        }
        this.shipp = templist;

        let tempList2 = {             
            'bayan' : null,           
            'fasahFee' : null,
            'inspection' : null,                
            'liftOnLiftOff' : null,                    
            'originCustomsclearance' : null,                
            'originLoadingCharges' : null,                
            'portShuttling' : null,                    
            'tabadul' : null,                
            'xray' : null,                
            'total' : null,
            'loadingCharge':null,
            'loadingChargeId':'',
            'currencyCode':'USD',
            'bLFees':null,
            'exportServiceFees':null,
            'fuelSurcharge':null,
            'insuranceCharges':null,
            'originDetentionDemurrageCharges':null,
            'OTHC':null,
            'pickupCharges':null,
            'reeferPluginCharges':null,
            'tarpaulinCharges':null,
            'truckidlingCharges':null,
            'vGM':null,
            'lashingCharges':null,
            'offSet':null        
        }
        this.incoCharges = tempList2;

        let templist3 = {
            'bayanCharges':null,
            'customClearance':null,
            'doCharges':null,
            'DTHC':null,
            'fasahCharges':null,
            'gatePassCharges':null,
            'LOLOCharges':null,
            'total':null,
            'transportation':null,
            'currencyCode':'USD',
            'offSet':null   
        }
        this.destinCharges = templist3;

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
        this.validityError = '';
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
            let ddd = new Date();
            let year = ddd.getFullYear();
            let month = ddd.getMonth();
            let lastdate = new Date(year, month +1, 0);
            this.validity = this.formatDate(lastdate,0)
        }
        this.rmsDetail.validity = this.validity 
        this.rateTypeError = '';
        this.validityError = '';
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
        if(e.target.value != '') this.seaFreight = parseInt(e.target.value);
        else this.seaFreight = 0;
        this.rmsDetail.seaFreight = this.seaFreight;
        this.seaFreightError = '';
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
        this.isLoading = true
        let allValid = true;
        if(this.rmsDetail.commodity == ''){
            allValid = false;
            this.commodityError = 'slds-has-error';
        }
        if(this.rmsDetail.incoTermId == ''){
            allValid = false;
            this.incoTermError = 'slds-has-error';
        }
        if(this.rmsDetail.equipmentId == ''){
            allValid = false;
            this.equipmentTypeError = 'slds-has-error';
        }
        if(this.rmsDetail.rateType == ''){
            allValid = false;
            this.rateTypeError = 'slds-has-error';
        }
        if(this.rmsDetail.validity == null){
            allValid = false;
            this.validityError = 'slds-has-error';
        }
        if(this.rmsDetail.seaFreight == null || this.rmsDetail.seaFreight <= 0 ){
            allValid = false;
            this.seaFreightError = 'slds-has-error';
        }
        console.log('rms '+JSON.stringify(this.rmsDetail,null,2))
        if(allValid){
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
            this.isLoading = false
            console.log('result  '+JSON.stringify(result))
            this.dispatchEvent(new CustomEvent('success'));
        }).catch(error=>{
            this.isLoading = false
            console.log('error add rate : ', JSON.stringify(error));
        });
    }
    else{
        this.isLoading = false
    }
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
        //Total = Total +  this.incoCharges.loadingCharge ;
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
            let tempList =[];
            this.contrIndex = 0;
            result.forEach(element => {
                temp.push({
                    label : element.Equipment_Type__r.Name,
                    value:element.Equipment_Type__r.Name
                })
                let obj={
                    'index':this.contrIndex++,
                    'containerType':element.Equipment_Type__c,
                    'containerTypeName':element.Equipment_Type__r.Name,
                    'containerTypeErrorClass':'',
                    'containerQuantityErrorClass':'',
                    'id':element.Id,
                    'quantity':element.Quantity__c
                }
                tempList.push(obj);
            });
            this.pickListvalues = temp;
            this.equipmentType = this.pickListvalues[0].value;
            this.containerRecord = tempList;
            if(this.containerRecord.length > 0) this.noRecord = false 
            else this.noRecord = true 
        })
        .catch(error =>{
            console.log('get equip Error '+JSON.stringify(error))
        })
    }
    handleEquipSelection(e){
        this.equipmentType = e.detail.value;
        this.equipmentTypeError = '';
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
               //this.loadingCharge = result[0].Loading_Charge__c;
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
    handleCommoditySelection(e){
        this.rmsDetail.commodity =e.detail.Id
        this.commodityError = '';
    }
    handleCommodityRemoved(e){
        this.rmsDetail.commodity = ''
    }
    handleIncoTermSelection(e){
        this.rmsDetail.incoTermId =e.detail.Id
        this.incoTermError = '';
    }
    handleIncoRemoved(e){
        this.rmsDetail.incoTermId = ''
    }
    getDefualtValueForRMS(){
        this.isLoading =true;
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
            'incoTermId':'',
            'customerName':'',
            'commodity':''
        }
        this.rmsDetail = rmsDetail;
        this.todaysDate = new Date().toISOString();
        this.validity = this.formatDate(this.todaysDate,0)
        this.rmsDetail.validity = this.validity;
        if(this.cameFromImport == 'true'){
            this.agentName = this.agentObject.Name;
            this.rmsDetail.agentName = this.agentObject.Id;
            this.getDefaultImportAddRate();
        }
        getDefualtValueForRMS()
        .then(result=>{
            console.log('getDefualtValueForRMS result',JSON.stringify(result))
            if(result != null){
                if(result.commodityId != undefined){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                    let Obj={Id:result.commodityId,Name:result.commodityName}
                    field.handleDefaultSelected(Obj);
                }
                if(result.incoTermId != undefined && this.cameFromImport != 'true'){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
                    let Obj={Id:result.incoTermId,Name:result.incoTermName}
                    field.handleDefaultSelected(Obj);
                }
            }
            this.isLoading = false
        })
        .catch(error=>{
            this.isLoading = false
            console.log('getDefualtValueForRMS error',JSON.stringify(error))
        })
    }
    getDefaultImportAddRate(){
        getDefaultImportAddRate({routeId : this.routeId})
        .then(result=>{
            console.log('getDefaultImportAddRate result',JSON.stringify(result))
            if(result != null){
                if(result.incoTermId != undefined){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
                    let Obj={Id:result.incoTermId,Name:result.incoTermName}
                    field.handleDefaultSelected(Obj);
                }
            }
        })
        .catch(error=>{
            console.log('getDefaultImportAddRate error',JSON.stringify(error))
        })
    }
    handleAddRouteEuip(){
        this.displayAddRouteEquip = true;
    }
    hideModalBox(){
        this.getRouteEquipType();
        this.displayAddRouteEquip = false;
    }
    hideAddRoute(){
        let allValid = true;
        console.log('toDelete '+JSON.stringify(this.toDeleteRecord,null,2));
        console.log('containerRecord '+JSON.stringify(this.containerRecord,null,2));
        if(this.containerRecord.length > 0){
            this.containerRecord.forEach(elem2=>{
                if(elem2.containerType == '' ){
                    elem2.containerTypeErrorClass = 'slds-has-error';
                    allValid = false
                }
                if(elem2.quantity <= 0){
                    elem2.containerQuantityErrorClass = 'slds-has-error';
                    allValid = false
                }
            })
        }
        else{
            allValid = false
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please add route equipment.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        if(allValid){
            addRouteEquipment({
                containerList : this.containerRecord,
                toDeleteRecord : this.toDeleteRecord,
                routeId : this.routeId
            })
            .then(result=>{
                console.log('addRouteEquipment result '+result)
                this.getRouteEquipType();
                this.displayAddRouteEquip = false;
            })
            .catch(error=>{
                console.log('addRouteEquipment error '+JSON.stringify(error,null,2))
            })
        }
    }
    handleContainerTypeSelection(e){
        let dto = JSON.parse(JSON.stringify(e.detail.dto))
        let index = this.containerRecord.findIndex(x=>x.index == dto.index)
        if(index != -1){
            this.containerRecord[index].containerType = dto.containerTypeID
            this.containerRecord[index].containerTypeName = dto.containerTypeName
        }
    }
    handleQuantityChange(e){
        let dto = JSON.parse(JSON.stringify(e.detail.dto))
        let index = this.containerRecord.findIndex(x=>x.index == dto.index)
        if(index != -1){
            this.containerRecord[index].quantity = dto.quantity
        }
    }
    handleRemoveContainer(e){
        let index = JSON.parse(JSON.stringify(e.detail))
        let removeIndex = this.containerRecord.findIndex(x=>x.index == index)
        if(index != -1){
            if(this.containerRecord[removeIndex].id != ''){
                this.toDeleteRecord.push(this.containerRecord[removeIndex].id);
            }
            this.containerRecord.splice(removeIndex,1)
            if(this.containerRecord.length == 0) this.noRecord = true
        }
    }
    handleAddRouteClicked(){
        let tempList = JSON.parse(JSON.stringify(this.containerRecord))
        let obj={
            'index':this.contrIndex++,
            'containerType':'',
            'containerTypeName':'',
            'containerTypeErrorClass':'',
            'containerQuantityErrorClass':'',
            'quantity':null,
            'id':''
        }
        tempList.push(obj);
        this.containerRecord = JSON.parse(JSON.stringify(tempList));
        this.noRecord = false
    }
}