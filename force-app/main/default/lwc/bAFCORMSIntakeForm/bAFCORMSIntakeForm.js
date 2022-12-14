import { LightningElement,track,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DIRECTION_FIELD from '@salesforce/schema/Loading_Charge__c.Direction__c';
import RATE_TYPE_FIELD from '@salesforce/schema/RMS__c.Rate_Type__c';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/RMS__c.Business_Type__c';
import submitRMS from '@salesforce/apex/BAFCOLeadDetailsController.submitRMS';
import getExchangeRate from '@salesforce/apex/BAFCOLRoutingDetailsController.getExchangeRate';
import getDefualtValueForRMS from '@salesforce/apex/BAFCOLRoutingDetailsController.getDefualtValueForRMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BAFCORMSIntakeForm extends LightningElement {
    
    @track shippTotalChanged = false; 
    @track shipp = {};
    @track incoCharges ={};
    @track DirectionOptions = [];
    @track directionValue = 'One Way';
    @track rateTypeOption = [];
    @track rateType = '';    
    @track rmsDetail ={};
    @track validity ='';
    @track seaFreight;
    @track businessTypeOption = [];
    @track businessType = '';
    @track incoChargeTotalChange = false;
    @track shippTotal = 0;
    @track incoTotal = 0;
    @track curencyCodeOption = [];
    @track allInRate = false;
    @track FOBAllIn = false;
    @track ExWorksIn = false;
    @track displayOriginCharge = true;
    @track displayShippingCharge = true;
    @track displayDestinCharge = true;
    @track FreeTime;
    @track FreeTimePOD;
    @track remarks = '';
    @track destinCharges ={};
    @track destinOffSet = 0;
    @track destinExchangeRate = 0;
    @track incoExchangeRate = 0;
    @track incoOffSet = 0;
    @track shippExchangeRate = 0;
    @track shippOffSet = 0;
    @track todaysDate = '';
    @track destinTotalChanged = false;
    @track disableShippOffSet = true;
    @track disableIncoOffSet = true;
    @track disableDestinOffSet = true;
    @track isLoading = false;
    @track displayAgentField = false;
    @track equipmentTypeOption =[];
    @track equipmentType = '';
    @track oceanfreightCheckbox = false;


    @track loadingPortError = '';
    @track loadingDischargeError = '';
    @track commodityError = '';
    @track shippingLineError = '';
    @track incoTermError = '';
    @track equipmentTypeError = '';
    @track rateTypeError = '';
    @track validityError = '';
    @track seaFreightError = '';
    @track businessTypeError = '';

    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : DIRECTION_FIELD
    })directionPickListValue({ data, error }){
            if(data){
                console.log(` DIRECTION_FIELD values are `, data.values);
                this.DirectionOptions = data.values;
                this.directionValue = this.DirectionOptions[0].value;
                //this.getLoadingCharges();
                this.error = undefined;
            }
            if(error){
                console.log(` Error while fetching DIRECTION_FIELD Picklist values  ${error}`);
                this.error = error;
                this.DirectionOptions = undefined;
            }
    }
    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : RATE_TYPE_FIELD
    })rateTypePropertyValue({ data, error }){
            if(data){
                console.log(`  rate type option `, data.values);
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
    })wiredPickListValue({ data, error }){
            if(data){
                console.log(` Picklist values are `, data.values);
                this.businessTypeOption = data.values;
            }
            if(error){
                console.log(` Error while fetching Picklist values  ${error}`);
                this.businessTypeOption = undefined;
            }
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }
    connectedCallback(){
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
            'warRiskSurcharge':null
        }
        this.shipp = templist;

        let tempList2 = {             
            'bayan' : null,                
            'destinationCustomsClearance' : null, 
            'destinationLoadingCharges' : null,
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
            'lashingCharges':null        
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
            'currencyCode':'USD'
        }
        this.destinCharges = templist3;
        this.todaysDate = new Date().toISOString();
        
    }
    getDefualtValueForRMS(){
        this.isLoading = true
        getDefualtValueForRMS()
        .then(result=>{
            console.log('getDefualtValueForRMS result',JSON.stringify(result))
            if(result != null){
                if(result.commodityId != undefined){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[2];
                    let Obj={Id:result.commodityId,Name:result.commodityName}
                    setTimeout(() => {
                        field.handleDefaultSelected(Obj);
                    }, 100);
                    
                }
                if(result.businessType != undefined){
                    this.businessType = result.businessType != null ? result.businessType : '';
                    if(this.businessType == 'Import') this.displayAgentField = true;
                    else {
                        this.displayAgentField = false;
                        if(result.incoTermId != undefined && this.businessType == 'Export'){
                            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                            let Obj={Id:result.incoTermId,Name:result.incoTermName}
                            setTimeout(() => {
                                field.handleDefaultSelected(Obj);
                            }, 100);
                        }
                        
                    }
                }
                if(result.polId != undefined){
                    if(result.polId != null){
                        let Obj={Id:result.polId,Name:result.polName}
                        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                        if(result.businessType == 'Export') {
                            setTimeout(() => {
                                field.handleDefaultSelected(Obj);
                            }, 100);
                        }
                        let field2 = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
                        if(result.businessType =='Import') {
                            setTimeout(() => {
                                field2.handleDefaultSelected(Obj);
                            }, 100);
                        }
                    }
                }
                if(result.equipmentList != null){
                    let templist = [];
                    result.equipmentList.forEach(elem=>{
                        templist.push({
                            label:elem.Name,
                            value:elem.Id
                        })
                    })
                    this.equipmentTypeOption = templist
                }
                let rmsDetail = {
                    'rateType':'',
                    'validity':'',
                    'seaFreight':null,
                    'loadingPortId':'',
                    'loadingDestinationId':'',
                    'commodityName':'',
                    'shippingLineId':'',
                    'equipmentId':'',
                    'agentName':'',
                    'businessType':this.businessType,
                    'loadingPortName':'',
                    'loadingDestinationName':'',
                    'allInRate':false,
                    'FOBAllIn':false,
                    'ExWorksIn':false,
                    'FreeTime':null,
                    'FreeTimePOD':null,
                    'remarks':'',
                    'currencyCode':'',
                    'customerName':'',
                    'incoTermId':null,
                    'oceanfreightCheckbox':false
                }
                this.rmsDetail = rmsDetail;
                this.validity = this.formatDate(this.todaysDate,0)
                this.rmsDetail.validity = this.validity;
                let index = this.equipmentTypeOption.findIndex((x) => x.label =='40HC')
                this.rmsDetail.equipmentId = this.equipmentTypeOption[index].value
                this.equipmentType = this.equipmentTypeOption[index].value;
                if(result.businessType == 'Export') {
                    this.rmsDetail.loadingPortId = result.polId != undefined ? result.polId : null;
                    this.rmsDetail.loadingPortName = result.polId != undefined ? result.polName : null;
                }
                if(result.businessType =='Import'){
                    this.rmsDetail.loadingDestinationId = result.polId != undefined ? result.polId : null;
                    this.rmsDetail.loadingDestinationName = result.polId != undefined ? result.polName : null;
                }
                this.isLoading = false
            }
        })
        .catch(error=>{
            this.isLoading = false
            console.log('getDefualtValueForRMS error',JSON.stringify(error))
        })
    }
    handleFreeTimeChange(e){
        this.FreeTime = e.target.value
        this.rmsDetail.FreeTime = this.FreeTime
    }
    handleFreeTimePODChange(e){
        this.FreeTimePOD = e.target.value
        this.rmsDetail.FreeTimePOD = this.FreeTimePOD
    }
    handleBusinessTypeChange(e){
        this.rmsDetail.businessType = e.target.value;
        if(this.rmsDetail.businessType =='Import') {
            this.displayAgentField = true;
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
            field.handleRemovePill();
        }
        else this.displayAgentField = false;
        this.businessTypeError = '';
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
    updateShippingTotal(){
        let Total = 0 ;
        console.log('total '+Total)
        Total = Total + this.shipp.BAF;
        Total = Total +   this.shipp.BunkerSurcharge;
        Total = Total +   this.shipp. ISPS;
        Total = Total +   this.shipp.OTHC;
        Total = Total +   this.shipp.CMC;
        Total = Total +   this.shipp. EIC;
        Total = Total +   this.shipp.sealCharges;
        Total = Total +   this.shipp. DTHC;
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
        this.shippTotal = parseInt(Total);
        console.log('total 2'+Total)

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
        Total = Total +  this.incoCharges.inspection   ;   
        Total = Total +  this.incoCharges.liftOnLiftOff    ; 
        Total = Total +  this.incoCharges.originCustomsclearance   ;
        Total = Total +  this.incoCharges.originLoadingCharges    ; 
        Total = Total +  this.incoCharges.portShuttling  ;    
        Total = Total +   this.incoCharges.tabadul  ;  
        Total = Total +  this.incoCharges.xray ;
        Total = Total +  this.incoCharges.loadingCharge ;
        Total = Total +  this.incoCharges.bLFees ;
        Total = Total +  this.incoCharges.exportServiceFees ;
        Total = Total +  this.incoCharges.insuranceCharges ;
        Total = Total +  this.incoCharges.lashingCharges ;
        Total = Total +  this.incoCharges.originDetentionDemurrageCharges ;
        Total = Total +  this.incoCharges.OTHC ;
        Total = Total + this.incoCharges.fuelSurcharge;
        Total = Total +  this.incoCharges.pickupCharges ;
        Total = Total +  this.incoCharges.reeferPluginCharges ;
        Total = Total +  this.incoCharges.tarpaulinCharges ;
        Total = Total +  this.incoCharges.truckidlingCharges ;
        Total = Total +  this.incoCharges.vGM ;
        this.incoCharges.total = parseInt(Total);
        this.incoTotal = parseInt(Total);
    }
    submitDetails(){
        this.isLoading = true;
        let allValid = true;
        console.log('rms '+JSON.stringify(this.rmsDetail,null,2))
        if(this.rmsDetail.loadingPortId == ''){
            allValid = false;
            this.loadingPortError = 'slds-has-error';
        }
        if(this.rmsDetail.loadingDestinationId == ''){
            allValid = false;
            this.loadingDischargeError = 'slds-has-error';
        }
        if(this.rmsDetail.commodityName == ''){
            allValid = false;
            this.commodityError = 'slds-has-error';
        }
        if(this.rmsDetail.shippingLineId == ''){
            allValid = false;
            this.shippingLineError = 'slds-has-error';
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
        if(this.rmsDetail.seaFreight <= 0){
            allValid = false;
            this.seaFreightError = 'slds-has-error';
        }
        if(this.rmsDetail.businessType == ''){
            allValid = false;
            this.businessTypeError = 'slds-has-error';
        }
        if(allValid){
            submitRMS({
                rmsDetail : this.rmsDetail,
                shippingChargeDto : this.shipp,
                incocharges : this.incoCharges,
                totalShippChanged : this.shippTotalChanged,
                totalIncoChanged : this.incoChargeTotalChange,
                destinTotalChanged : this.destinTotalChanged,
                destinCharges:this.destinCharges
            })
            .then(result =>{
                console.log('submitRMS result',JSON.stringify(result));
                this.isLoading = false;
            let disPatchObj = {
                    loadingPort : result.loadingPortName,
                    loadingDestination : result.loadingDestinationName,
                    validity : result.validity,
                    loadingPortId:result.loadingPortId,
                    loadingDestinationId : result.loadingDestinationId
                }
                const selectedEvent = new CustomEvent('success', { detail: {disPatchObj}});
                this.dispatchEvent(selectedEvent);

            })
            .catch(error=>{
                console.log('submitRMS ',JSON.stringify(error,null,2))
                this.isLoading = false;
                let err = error.body.pageErrors[0].message
                const evt = new ShowToastEvent({
                    title: 'Missing Field :',
                    message: err,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            })
        }
        else{
            this.isLoading = false;
        }
    }
    handletotalChange(e){
        this.incoCharges.total = parseInt(e.target.value);
        if(!isNaN(this.incoCharges.total)) this.incoChargeTotalChange = true;
        else this.incoChargeTotalChange = false;
    }
    handleDirectionChange(event){
        this.directionValue  = event.target.value;
        //this.getLoadingCharges();
    }
    handleValidityChange(e){
        this.validity = e.target.value;
        this.rmsDetail.validity = this.validity;
        this.validityError = '';
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
        this.seaFreightError ='';
    }    
    handlePortSelection(e){
        this.rmsDetail.loadingPortId = e.detail.Id;
        this.rmsDetail.loadingPortName = e.detail.Name;
        this.loadingPortError = '';
    }
    handlePortRemoved(e){
        this.rmsDetail.loadingPortId = '';
        this.rmsDetail.loadingPortName = '';
    }
    handleDestinationSelection(e){
        this.rmsDetail.loadingDestinationId = e.detail.Id;
        this.rmsDetail.loadingDestinationName = e.detail.Name;
        this.loadingDischargeError = '';
    }
    handleDestinationRemoved(e){
        this.rmsDetail.loadingDestinationId = '';
        this.rmsDetail.loadingDestinationName = '';
    }
    handleCommoditySelection(e){
        this.rmsDetail.commodityName = e.detail.Id;
        this.commodityError = '';
    }
    handleCommodityRemoved(e){
        this.rmsDetail.commodityName = '';
    }
    handleShippingLineSelection(e){
        this.rmsDetail.shippingLineId = e.detail.Id;
        this.shippingLineError = '';
    }
    handleShippingRemoved(e){
        this.rmsDetail.shippingLineId = '';
    }
    handleEquipmentSelection(e){
        this.rmsDetail.equipmentId = e.detail.Id;
    }
    handleEquipmentChange(e){
        this.rmsDetail.equipmentId = e.target.value;
        this.equipmentType = e.target.value;
        this.equipmentTypeError = '';
    }
    handleEquipmentRemoved(e){
        this.rmsDetail.equipmentId = '';
    }
    handleAgentSelection(e){
        this.rmsDetail.agentName = e.detail.Id;
    }
    handleAgentRemoved(e){
        this.rmsDetail.agentName = '';
    }
    getExchangeRate(){
        getExchangeRate()
        .then(result=>{
            let templist = [];
            console.log('getExchangeRate res',JSON.stringify(result,null,2))
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
            this.shipp.currencyCode = 'USD';
            this.incoCharges.currencyCode = 'USD';
            this.destinCharges.currencyCode = 'USD';
        })
        .catch(error=>{
            console.log('getExchangeRate err',JSON.stringify(error,null,2))
        })
    }
    handleAllInRateChange(e){
        this.FOBAllIn = false;
        this.ExWorksIn = false;
        this.oceanfreightCheckbox = false
        this.allInRate = e.target.checked;
        this.updateRMSCheckBox();
    }
    handleFOBAllInChange(e){
        this.allInRate = false;
        this.ExWorksIn = false;
        this.oceanfreightCheckbox = false
        this.FOBAllIn = e.target.checked;
        this.updateRMSCheckBox();
    }
    handleoceanfreightCheckboxChange(e){
        this.oceanfreightCheckbox = e.target.checked;
        this.allInRate = false;
        this.ExWorksIn = false;
        this.FOBAllIn = false;
        console.log('this.oceanfreightCheckbox '+this.oceanfreightCheckbox)
        this.updateRMSCheckBox();
    }
    handleExWorksChange(e){
        this.FOBAllIn = false;
        this.allInRate = false;
        this.oceanfreightCheckbox = false
        this.ExWorksIn = e.target.checked;
        this.updateRMSCheckBox();
    }
    updateRMSCheckBox(){
        if(this.allInRate == true){
            this.FOBAllIn = false;
            this.ExWorksIn = false;
            this.oceanfreightCheckbox= false
            this.displayOriginCharge = false;
            this.displayShippingCharge = false;
            this.displayDestinCharge= true;
        }
        else if(this.FOBAllIn == true){
            this.allInRate = false;
            this.ExWorksIn = false;
            this.oceanfreightCheckbox= false
            this.displayShippingCharge = false;
            this.displayOriginCharge = false;
            this.displayDestinCharge= true;
        }
        else if(this.ExWorksIn == true){
            this.FOBAllIn = false;
            this.allInRate = false;
            this.oceanfreightCheckbox= false
            this.displayShippingCharge = false;
            this.displayOriginCharge = false;
            this.displayDestinCharge= true;
        }
        else if(this.oceanfreightCheckbox == true){
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
        console.log('rms  '+JSON.stringify(this.rmsDetail,null,2))
    }
    handleRemarksChange(e){
        this.remarks = e.target.value;
        this.rmsDetail.remarks = this.remarks
    }
    handleDestinCurrencyCodeSelection(e){
        this.destinCharges.currencyCode = e.target.value;
        this.curencyCodeOption.forEach(elem=>{
            if(elem.value == e.target.value){
                this.destinExchangeRate = elem.exchangeRate
                this.destinOffSet = elem.offSet
                this.destinCharges.offSet = elem.offSet;
            }
        })
        if(this.destinCharges.currencyCode == 'USD') {
            this.disableShippOffSet = true;
            this.destinCharges.offSet = 0;
        }
        else{
            this.disableShippOffSet = false;
        }
    }
    handleDestinOffSetChange(e){
        this.destinCharges.offSet = e.target.value;
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
   /* handleDestinDTHCChange(e){
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
       // Total = Total + (this.destinCharges.DTHC != null ? this.destinCharges.DTHC : 0)
        Total = Total + (this.destinCharges.doCharges != null ? this.destinCharges.doCharges : 0)
        Total = Total + (this.destinCharges.customClearance != null ? this.destinCharges.customClearance : 0)
        Total = Total + (this.destinCharges.bayanCharges != null ? this.destinCharges.bayanCharges : 0)
        this.destinCharges.total = parseInt( Total);

        console.log('this.destinCharges '+JSON.stringify(this.destinCharges,null,2))
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
    handleShippOffsetChange(e){
        this.shipp.offSet = e.target.value;
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
    handlecarriageCongestionSurchargChange(e){
        this.shipp.carriageCongestionSurcharg = parseInt(e.target.value);
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
    handlewarRiskSurchargeChange(e){
        this.shipp.warRiskSurcharge = parseInt(e.target.value);
        this.updateShippingTotal();
    }
    handleIncoTermSelection(e){
        this.rmsDetail.incoTermId = e.detail.Id;
        this.incoTermError = '';
    }
    handleIncoRemoved(e){
        this.rmsDetail.incoTermId = '';
    }
    handleCustomerSelection(e){
        this.rmsDetail.customerName = e.detail.Id;
    }
    handleCustomerRemoved(e){
        this.rmsDetail.customerName = '';
    }
}