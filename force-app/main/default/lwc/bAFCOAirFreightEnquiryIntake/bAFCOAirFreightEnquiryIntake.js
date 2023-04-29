import { LightningElement,api,track,wire } from 'lwc';
import ROUTE_OBJECT from '@salesforce/schema/Route__c';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CONTAINER_PNG from '@salesforce/resourceUrl/AddContainer';
import getAllRegularRoute from '@salesforce/apex/BAFCOLRoutingDetailsController.getAllRegularRoute';
import getRegularRouteData from '@salesforce/apex/BAFCOLRoutingDetailsController.getRegularRouteData';
import getDefualtValueForEnquiry from '@salesforce/apex/BAFCOLRoutingDetailsController.getDefualtValueForEnquiry';
export default class BAFCOAirFreightEnquiryIntake extends LightningElement {
    @api routeName;
    @api routingRegular;
    @api shipmentKind;
    @api serviceType;
    @api incoTerm;
    @api incoTermName;
    @api portLoading;
    @api portLoadingName;
    @api portDestination;
    @api portDestinationName;
    @api shippingLine;
    @api shippingLineName;
    @api placeOfPickup;
    @api placeOfDischarge;
    @api commodity;
    @api commodityName;
    @api cargoWeights;
    @api dangerousGoods;
    @api remarks;
    @api dgClass;
    @api leadIndex;
    @api containerRecord = [];
    @api showDGClassField;
    @api showPickupPlaceField;
    @api showDischargePlaceField;
    @api copyFromAbove;
    @api placeOfDischargeName = '';
    @api placeOfPickupName = '';
    @api shipmentKindClass='';
    @api serviceTypeClass='';
    @api incoTermClass='';
    @api portOfLoadingClass='';
    @api portOfDestinationClass='';
    @api commodityClass='';
    @api cargoweightClass='';
    @api pickupPlaceClass='';
    @api dischargePlaceClass='';
    @track regularRouteOption=[];
    @track kindOfShipmentOption =[];
    @track serviceTypeOption=[];
    @track dgClassOption=[];
    @api leadEnquiryList = [];
    @api disableAddRoute = false;
    AddContainerPNG = CONTAINER_PNG;
    @api accountId = '';
    @track isAccountObject = false;
    @track isLoading = false;
    @track disableIncoField =  false; 
    @track hidePOL = false;
    @track hidePOD = false;
    @api businessType= '';
    @track hideShippingLine = false;
    @track disableServiceType = false;
    @api isEdit;
    @api isAir;
    @track portObject = 'Port__c';
    @track loadigPortLabel = 'Port of Loading';
    @track destinationPortLabel = 'Port of Destination';
    @api cargoReadiness = '';
    @track isImport = false;
    @api minDate = '';
    @track shippLineObject = 'Shipping_Line__c';
    @track shippLinePlaceHolder = 'Search Shipping Line';
    @track shippLinePlaceLabel = 'Shipping Line';
    @track displayAddPackage = true;


    @track width;

    @wire(getPicklistValuesByRecordType, { objectApiName: ROUTE_OBJECT, recordTypeId: '012000000000000AAA' })
    routeObjectData({ data, error }) {
        if(data){
            this.kindOfShipmentOption = data.picklistFieldValues.Kind_Of_Shipment__c.values;
            this.serviceTypeOption = data.picklistFieldValues.Service_Type__c.values;
            this.dgClassOption = data.picklistFieldValues.DG_Class__c.values;
            this.updateEnquiryList();
        }
        else if(error){
            console.log(' Route Object data error', JSON.stringify(error, null, 2));
        }
    }

    connectedCallback(){
        if(this.businessType == 'Import') this.isImport = true;
        if(this.isAir == 'true'){
            this.portObject = 'Airport__c';
            this.loadigPortLabel = 'Airport of Loading';
            this.destinationPortLabel = 'Airport of Destination';
            this.shippLineObject = 'Airline__c';
            this.shippLinePlaceHolder = 'Search Airline Line';
            this.shippLinePlaceLabel = 'Airline';
           if(this.businessType == 'Import') this.displayAddPackage = false;
        }
        else{
            this.portObject = 'Port__c';
            this.loadigPortLabel = 'Port of Loading';
            this.destinationPortLabel = 'Port of Destination';
            this.shippLineObject = 'Shipping_Line__c';
            this.shippLinePlaceHolder = 'Search Shipping Line';
            this.shippLinePlaceLabel = 'Shipping Line';
            this.displayAddPackage = true;
        }
        if(this.accountId.startsWith('001')){
            this.isAccountObject = true;
            this.getAllRegularRoute();
        }
        if(this.isEdit == 'true'){
            this.routeDefaultValueAssignment();
        }
        else{
            this.getDefualtValueForEnquiry();
        }
    }
    routeDefaultValueAssignment(){
        console.log('hidePOL '+this.hidePOL,this.portLoading)
        setTimeout(() => {
            if(this.commodity != ''){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                let Obj={Id:this.commodity,Name:this.commodityName}
                if(field != null || field != undefined) field.handleDefaultSelected(Obj);
            }
            if(this.incoTerm!= undefined){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                let Obj={Id:this.incoTerm,Name:this.incoTermName}
                if(field != null || field != undefined) field.handleDefaultSelected(Obj);
            }
            //if(this.incoTermName == 'Local Operation') this.handleLocalInco();
            if(this.hidePOL == false && this.portLoading != ''){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
                let Obj={Id:this.portLoading,Name:this.portLoadingName,index:this.leadIndex}
                field.handleDefaultSelected(Obj);
            }
            if(this.hidePOD == false && this.portDestination != ''){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[2];
                let Obj={Id:this.portDestination,Name:this.portDestinationName,index:this.leadIndex}
                field.handleDefaultSelected(Obj);
            }
            if(this.hideShippingLine == false && this.shippingLine != ''){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[3];
                let Obj={Id:this.shippingLine,Name:this.shippingLineName,index:this.leadIndex}
                field.handleDefaultSelected(Obj);
            }
            if(this.serviceType != ''){
                if(this.serviceType == 'Ex-Works'){
                    this.showPickupPlaceField = true;
                    this.showDischargePlaceField = true;
                    let field2 = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                    field2.handleRemovePill();
                    this.incoTerm = '';
                    this.incoTermName = '';
                }
                else{
                    this.showPickupPlaceField = true;
                    this.showDischargePlaceField = true;                
                    if(this.serviceType == 'D2P' || this.serviceType ==  'D2D'){
                        this.showPickupPlaceField = true;
                    }
                    else{
                        this.showPickupPlaceField = false;
                    }
                    if(this.serviceType == 'P2D' || this.serviceType ==  'D2D'){
                        this.showDischargePlaceField = true;
                    }
                    else{
                        this.showDischargePlaceField = false;
                    }
                }
            }
        }, 100);
    }
    @api getDefualtValueForEnquiry(){
        this.isLoading = true 
        this.isImport = false;
        this.cargoReadiness = '';
        getDefualtValueForEnquiry()
        .then(result=>{
            console.log(' getDefualtValueForEnquiry result', JSON.stringify(result, null, 2));
            if(result != null){
                //this.displayIncoChanges();   
                setTimeout(() => {
                    this.serviceType = '';
                    if(result.commodityId != undefined){
                        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                        let Obj={Id:result.commodityId,Name:result.commodityName}
                        if(field != null || field != undefined) field.handleDefaultSelected(Obj);
                    }
                    if(result.incoTermId != undefined){
                        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                        let Obj={Id:result.incoTermId,Name:result.incoTermName}
                        if(field != null || field != undefined) field.handleDefaultSelected(Obj);
                    }
                    //if(this.incoTermName == 'Clearance and Delivery' || this.incoTermName == 'Local Operation') this.handleLocalInco();
                }, 200);
                this.disableAddRoute = false;
                this.disableIncoField = false;
                this.displayAddPackage = true;
            }
            this.updateEnquiryList();
            this.isLoading = false;
        })
        .catch(error=>{
            console.log(' getDefualtValueForEnquiry error', JSON.stringify(error, null, 2));
            this.isLoading = false;
        })
    }

    getAllRegularRoute(){
        getAllRegularRoute({AccountId : this.accountId})
        .then(result=>{
            let templist = [];
            templist.push({
                label:'-None-',
                value:''
            })
            result.forEach(elem=>{
                templist.push({
                    label:elem.Name,
                    value:elem.Id
                })
            })
            this.regularRouteOption = templist;
        })
        .catch(error=>{
            console.log('getAllRegularRoute error: ',error)
        })
    }
    handleRegularRouteChange(event){
        let index = event.target.dataset.recordId;
        let regularValue = event.target.value;
        this.routingRegular = regularValue;
        this.getRegularRouteData(index,regularValue);
        this.updateEnquiryList();
    }
    getRegularRouteData(index,rgID){
        getRegularRouteData({rgID:rgID})
        .then(result=>{
            console.log('rsult ',JSON.stringify(result,null,2))
           this.serviceType = result.Service_Type__c != undefined ? result.Service_Type__c : '';
            this.incoTerm = result.INCO_Term__c != undefined ? result.INCO_Term__c : '';
            this.portLoading = result.Port_of_Loading__c != undefined ? result.Port_of_Loading__c : '';
            this.portDestination = result.Port_of_Destination__c != undefined ? result.Port_of_Destination__c : '';
            this.shippingLine = result.Shipping_Line__c != undefined ? result.Shipping_Line__c : '';
            this.commodity = result.Commodity__c != undefined ? result.Commodity__c : '';
            this.dangerousGoods = result.Dangerous_Goods__c != undefined ? result.Dangerous_Goods__c : '';
            this.shipmentKind = 'FCL';
            this.placeOfPickup = result.Pickup_Place__c != undefined ? result.Pickup_Place__c : '';
            this.placeOfDischarge = result.Discharge_Place__c != undefined ? result.Discharge_Place__c : '';
            let incoTermfield = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
            let polfield = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
            let podfield = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[2];
            let shipfield = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[3];
            let commodityfield = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
            if(result.Dangerous_Goods__c == true){
                this.showDGClassField = true;
                this.dgClass = result.DG_Class__c != undefined ? result.DG_Class__c : '';
            }
            if(this.incoTerm != ''){
                let Obj={Id:result.INCO_Term__c,Name:result.INCO_Term__r.Name}
                if(incoTermfield != null) incoTermfield.handleDefaultSelected(Obj);
            }
            else{
                if(incoTermfield != null) incoTermfield.handleRemovePill();
            }
            if(result.Port_of_Loading__c != undefined){
                let Obj={Id:result.Port_of_Loading__c,Name:result.Port_of_Loading__r.Name,index:index}
                polfield.handleDefaultSelected(Obj);
            }
            else{
                polfield.handleRemovePill();
            }
            if(result.Port_of_Destination__c != undefined){                
                let Obj={Id:result.Port_of_Destination__c,Name:result.Port_of_Destination__r.Name,index:index}
                podfield.handleDefaultSelected(Obj);
            }
            else{
                podfield.handleRemovePill();
            }
            if(result.Shipping_Line__c != undefined){                
                let Obj={Id:result.Shipping_Line__c,Name:result.Shipping_Line__r.Name,index:index}
                shipfield.handleDefaultSelected(Obj);
            }
            else{
                shipfield.handleRemovePill();
            }
            if(result.Commodity__c != undefined){                
                let Obj={Id:result.Commodity__c,Name:result.Commodity__r.Name,index:index}
                commodityfield.handleDefaultSelected(Obj);
            }
            else{
                commodityfield.handleRemovePill();
            }
            if(this.serviceType  == 'D2P' || this.serviceType  == 'D2D'){
                this.showPickupPlaceField = true;    
            }
            if(this.serviceType  == 'P2D' || this.serviceType  == 'D2D'){
                this.showDischargePlaceField = true;
            }

            setTimeout(() => {
                this.shipmentKindClass = '';
                this.serviceTypeClass = '';
                this.incoTermClass = '';
                this.portOfLoadingClass = '';
                this.portOfDestinationClass = '';
                this.commodityClass = '';
                this.dischargePlaceClass = '';
                this.pickupPlaceClass = '';
                this.updateEnquiryList();
            }, 500);
        
        })
        .catch(error=>{
            console.log('error '+error)
        })
    }
    @api updateEnquiryList(){
        let leadEntryDto = {
             'shipmentKind':this.shipmentKind,
             'serviceType':this.serviceType,
             'incoTerm':this.incoTerm,
             'leadIndex':this.leadIndex,
             'routingRegular':this.routingRegular,
             'portLoading':this.portLoading,
             'portDestination':this.portDestination,
             'shippingLine':this.shippingLine,
             'showPickupPlaceField':this.showPickupPlaceField,
             'showDischargePlaceField':this.showDischargePlaceField,
             'placeOfPickup':this.placeOfPickup,
             'placeOfDischarge':this.placeOfDischarge,
             'commodity':this.commodity,
             'cargoWeights':this.cargoWeights,
             'remarks':this.remarks,
             'dgClass':this.dgClass,
             'dangerousGoods':this.dangerousGoods,
             'showDGClassField':this.showDGClassField,
             'incoTermName':this.incoTermName,
             'portLoadingName':this.portLoadingName,
             'portDestinationName':this.portDestinationName,
             'shippingLineName':this.shippingLineName,
             'commodityName':this.commodityName,
             'placeOfPickupName':this.placeOfPickupName,
             'placeOfDischargeName':this.placeOfDischargeName,
             'containerRecord':this.containerRecord,
             'shipmentKindClass':this.shipmentKindClass,
             'serviceTypeClass':this.serviceTypeClass,
             'incoTermClass':this.incoTermClass,
             'portOfLoadingClass':this.portOfLoadingClass,
             'portOfDestinationClass':this.portOfDestinationClass,
             'commodityClass':this.commodityClass,
             'cargoweightClass':this.cargoweightClass,
             'dischargePlaceClass':this.dischargePlaceClass,
             'pickupPlaceClass':this.pickupPlaceClass,
             'disableAddRoute':this.disableAddRoute,
             'cargoReadiness':this.cargoReadiness,
         }
         let updateleadEntryDto = JSON.parse(JSON.stringify(leadEntryDto));
         this.dispatchEvent(new CustomEvent('update', { detail: { dto: updateleadEntryDto } }));
     }
     handleIncoTermSelection(e){
        let incoTermID = e.detail.Id;
        this.incoTerm = incoTermID;
        this.incoTermName = e.detail.Name        
        this.incoTermClass ='';
        this.updateEnquiryList();
    }
    handleIncoTermRemoved(e){
        this.incoTerm = '';
        this.incoTermName = '';
        this.updateEnquiryList();
    }
    handleServiceType(e){
        let serviceType = e.target.value;
        this.serviceType = serviceType;
        if(serviceType == 'D2P' || serviceType ==  'D2D'){
            this.showPickupPlaceField = true;
        }
        else{
            this.showPickupPlaceField = false;
        }
        if(serviceType == 'P2D' || serviceType ==  'D2D'){
            this.showDischargePlaceField = true;
        }
        else{
           this.showDischargePlaceField = false;
        }
        this.placeOfPickup = '';
        this.placeOfDischarge = '';
        this.serviceTypeClass ='';
        this.updateEnquiryList();
    }
    handleLoadingPortSelectedSelection(e){
        let portLoading = e.detail.Id;
        this.portLoading = portLoading;
        this.portLoadingName = e.detail.Name
        this.portOfLoadingClass ='';
        this.updateEnquiryList();
    }
    handleLoadingPortRemoved(e){
        this.portLoading = '';
        this.portLoadingName = '';
        this.updateEnquiryList();
    }
    handleDestinationPortSelectedSelection(e){
        let portDestination = e.detail.Id;
        this.portDestination = portDestination;
        this.portDestinationName = e.detail.Name
        this.portOfDestinationClass ='';
        this.updateEnquiryList();
    }
    handleDestinationPortRemoved(e){
        this.portDestination = '';
        this.portDestinationName = '';
        this.updateEnquiryList();
    }
    handleShippingLineSelection(e){
        let shippingLine = e.detail.Id;
        this.shippingLine = shippingLine;
        this.shippingLineName = e.detail.Name
        this.updateEnquiryList();
    }
    handleShippingLineRemoved(e){
        this.shippingLine = '';
        this.shippingLineName ='';
        this.updateEnquiryList();
    }
    handleCommoditySelection(e){
        let commodity = e.detail.Id;
        this.commodity = commodity;
        this.commodityName = e.detail.Name
        this.commodityClass ='';
        this.updateEnquiryList();
    }
    handleCommodityRemoved(e){
        this.commodity = '';
        this.commodityName = '';
        this.updateEnquiryList();
    }
    handleDischargePlaceInputchange(e){
        this.placeOfDischarge = e.target.value
        this.dischargePlaceClass ='';
        this.updateEnquiryList();
    }
    handlePickupPlaceInputchange(e){
        this.placeOfPickup = e.target.value;
        this.pickupPlaceClass = '';
        this.updateEnquiryList();
    }
    handleDangeorusGood(e){
        let value = e.target.checked;
        this.dangerousGoods = value;
        if(value){
            this.showDGClassField = true;
        }
        else{
            this.showDGClassField = false;
        }
        this.dgClass = '';
    }
    handleDGClass(e){
        let dgClass = e.target.value;
        this.dgClass = dgClass;
        this.updateEnquiryList();
    }

    handleRemarkChange(e){
        let remarks = e.target.value;
        this.remarks = remarks;
        this.updateEnquiryList();
    }
    @api removeDefaultOnImport(){
        this.isLoading = true;      
        this.isImport = true;
        this.displayAddPackage =false;  
        let index = this.leadIndex+'.'+'1';
        let obj={
            "length": null,
            "width": null,
            "height": null,
            "CBM": null,
            "Weight": null,
            "index": index,
            "id": "",
            "lengthErrorClass": "",
            "widthErrorClass": "",
            "heightErrorClass": "",
            "CBMErrorClass": "",
            "WeightErrorClass": "",
            "unitsErrorClass": "",
            "stackable": false,
            "palletized": false,
            "units": "",
            "cargoDetails": "",
            "cargoDetailsError": ""
          }
          this.containerRecord = [];
          this.containerRecord.push(obj)
        setTimeout(() => {
            if(this.incoTermName != 'Clearance and Delivery' && this.incoTermName != 'Local Operation'){   
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                field.handleRemovePill();
                let field2 = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                field2.handleRemovePill();
            }
        }, 200); 
        this.shipmentKind = '';
        this.updateEnquiryList();
        this.isLoading = false;
    }
    handleCopyFromAbove(e){
        let index = e.target.dataset.recordId;
        if(this.businessType == 'Import') this.isImport = true;
        else this.isImport = false;
        this.leadEnquiryList.forEach(elem => {
            if(elem.leadIndex == 1) {
                this.shipmentKind = elem.shipmentKind;
                this.serviceType = elem.serviceType;
                this.incoTerm = elem.incoTerm;
                this.routingRegular = elem.routingRegular;
                this.portLoading = elem.portLoading;
                this.portDestination = elem.portDestination;
                this.shippingLine = elem.shippingLine;
                this.showPickupPlaceField = elem.showPickupPlaceField;
                this.showDischargePlaceField = elem.showDischargePlaceField;
                this.placeOfPickup = elem.placeOfPickup;
                this.placeOfDischarge = elem.placeOfDischarge;
                this.commodity = elem.commodity;
                this.cargoWeights = elem.cargoWeights;
                this.remarks = elem.remarks;
                this.dgClass = elem.dgClass;
                this.dangerousGoods = elem.dangerousGoods;
                this.showDGClassField = elem.showDGClassField;
                this.incoTermName = elem.incoTermName;
                this.portLoadingName = elem.portLoadingName;
                this.portDestinationName = elem.portDestinationName;
                this.shippingLineName = elem.shippingLineName;
                this.commodityName = elem.commodityName;
                this.placeOfPickupName = elem.placeOfPickupName;
                this.placeOfDischargeName = elem.placeOfDischargeName;
                this.cargoReadiness = elem.cargoReadiness;
            }
        })

        if(this.incoTerm != ''){
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
            let Obj={Id:this.incoTerm,Name:this.incoTermName}
            if(field != null) field.handleDefaultSelected(Obj);
        }
        if(this.portLoading != ''){
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
            let Obj={Id:this.portLoading,Name:this.portLoadingName}
            field.handleDefaultSelected(Obj);
        }
        if(this.portDestination != ''){
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[2];
            let Obj={Id:this.portDestination,Name:this.portDestinationName}
            field.handleDefaultSelected(Obj);
        }
        if(this.shippingLine != ''){
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[3];
            let Obj={Id:this.shippingLine,Name:this.shippingLineName}
            field.handleDefaultSelected(Obj);
        }
        if(this.commodity != ''){
            let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
            let Obj={Id:this.commodity,Name:this.commodityName}
            field.handleDefaultSelected(Obj);
        }
        if(this.serviceType  == 'D2P' || this.serviceType  == 'D2D'){
            this.showPickupPlaceField = true;
        }
        if(this.serviceType  == 'P2D' || this.serviceType  == 'D2D'){
            this.showDischargePlaceField = true;
        }
        let containerData = this.leadEnquiryList[0].containerRecord;
       let copyCObj={
        'index':index,
        'size': containerData.length
       }
       this.dispatchEvent(new CustomEvent('addemptycontainertype', { detail:  copyCObj}));
       for(let i=0 ;i<containerData.length;i++){
        setTimeout(() => {
            this.handleCopyData(containerData[i],index);
        }, 500);
       }
        setTimeout(() => {
            this.shipmentKindClass = '';
            this.serviceTypeClass = '';
            this.incoTermClass = '';
            this.portOfLoadingClass = '';
            this.portOfDestinationClass = '';
            this.commodityClass = '';
            this.dischargePlaceClass = '';
            this.pickupPlaceClass = '';
            this.updateEnquiryList();
        }, 2000);
    }
    handleCopyData(containerRecord,i){
        console.log('# containerRecord' +JSON.stringify(containerRecord,null,2))
        let initalIndex = containerRecord.index;
        let spitInitalIndex = initalIndex.split('.');
        let cameIndex = i;
        let finalIndex = cameIndex+'.'+spitInitalIndex[1]        
        let obj={
                'index':finalIndex,
                'length':containerRecord.length,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('lengthupdate', { detail: { dto: containerDto } }));
        let obj2={
            'index':finalIndex,
            'width':containerRecord.width,
        }
        let containerDto2 = JSON.parse(JSON.stringify(obj2));
        this.dispatchEvent(new CustomEvent('widthupdate', { detail: { dto: containerDto2 } })); 
        let obj3={
            'index':finalIndex,
            'height':containerRecord.height,
        }
        let containerDto3 = JSON.parse(JSON.stringify(obj3));
        this.dispatchEvent(new CustomEvent('heightupdate', { detail: { dto: containerDto3 } })); 
        let obj4={
            'index':finalIndex,
            'cbm':containerRecord.CBM,
        }
        let containerDto4 = JSON.parse(JSON.stringify(obj4));
        this.dispatchEvent(new CustomEvent('cbmupdate', { detail: { dto: containerDto4 } })); 
        let obj5={
            'index':finalIndex,
            'weight':containerRecord.Weight,
        }
        let containerDto5 = JSON.parse(JSON.stringify(obj5));
        this.dispatchEvent(new CustomEvent('weightupdate', { detail: { dto: containerDto5 } })); 
        let obj6={
            'index':finalIndex,
            'stackable':containerRecord.stackable,
        }
        let containerDto6 = JSON.parse(JSON.stringify(obj6));
        this.dispatchEvent(new CustomEvent('stackableupdate', { detail: { dto: containerDto6 } })); 
        let obj7={
            'index':finalIndex,
            'palletized':containerRecord.palletized,
        }
        let containerDto7 = JSON.parse(JSON.stringify(obj7));
        this.dispatchEvent(new CustomEvent('palletizedupdate', { detail: { dto: containerDto7 } }));
        let obj8={
            'index':finalIndex,
            'units':containerRecord.units,
        }
        let containerDto8 = JSON.parse(JSON.stringify(obj8));
        this.dispatchEvent(new CustomEvent('unitsupdate', { detail: { dto: containerDto8 } })); 
        let obj9={
            'index':finalIndex,
            'cargoDetails':containerRecord.cargoDetails,
        }
        let containerDto9 = JSON.parse(JSON.stringify(obj9));
        this.dispatchEvent(new CustomEvent('cargodetailsupdate', { detail: { dto: containerDto9 } })); 
    }
    handlelengthChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'length':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('lengthupdate', { detail: { dto: containerDto } }));      
    }
    handleWidthChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'width':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('widthupdate', { detail: { dto: containerDto } })); 
    }
    handleHeightChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'height':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('heightupdate', { detail: { dto: containerDto } })); 
    }
    handleCBMChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'cbm':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('cbmupdate', { detail: { dto: containerDto } })); 
    }
    handleWeightChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'weight':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('weightupdate', { detail: { dto: containerDto } })); 
    }
    handleStackableChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.checked;
        let obj={
            'index':index,
            'stackable':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('stackableupdate', { detail: { dto: containerDto } })); 
    }
    handlePalletizedChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.checked;
        let obj={
            'index':index,
            'palletized':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('palletizedupdate', { detail: { dto: containerDto } })); 
    }
    handleUnitsChange(e){
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'units':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('unitsupdate', { detail: { dto: containerDto } })); 
    }
    handleCargoDetailsChange(e){
        console.log('ccme '+JSON.stringify(e.target.dataset.recordId,null,2))
        console.log('ccme '+JSON.stringify(e.target.value,null,2))
        let index = e.target.dataset.recordId;
        let value = e.target.value;
        let obj={
            'index':index,
            'cargoDetails':value,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        console.log('ccme '+JSON.stringify(containerDto,null,2))
        this.dispatchEvent(new CustomEvent('cargodetailsupdate', { detail: { dto: containerDto } }));
        console.log('ccme deployed'+JSON.stringify(obj,null,2))
    }
    handleAddContainer(e){
        let strIndex = e.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('addcontainertype', { detail:  strIndex}));
    }
    handleRemoveContainer(e){
        let strIndex = e.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('removecontainertype', { detail:  strIndex}));
    }
    handelCargoReadinessDate(e){
        this.cargoReadiness = e.target.value;
        this.updateEnquiryList();
    }
}