import { LightningElement,api,track,wire } from 'lwc';
import ROUTE_OBJECT from '@salesforce/schema/Route__c';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getAllRegularRoute from '@salesforce/apex/BAFCOLRoutingDetailsController.getAllRegularRoute';
import getRegularRouteData from '@salesforce/apex/BAFCOLRoutingDetailsController.getRegularRouteData';
import getDefualtValueForEnquiry from '@salesforce/apex/BAFCOLRoutingDetailsController.getDefualtValueForEnquiry';
import CONTAINER_PNG from '@salesforce/resourceUrl/AddContainer';
export default class BAFCOLeadEnquiryEntryIntake extends LightningElement {
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
    @api containerRecord;
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
    AddContainerPNG = CONTAINER_PNG;
    @api accountId = '';
    @track isAccountObject = false;
    @track isLoading = false;

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
        if(this.accountId.startsWith('001')){
            this.isAccountObject = true;
            this.getAllRegularRoute();
        }
        this.getDefualtValueForEnquiry();
    }
    @api getDefualtValueForEnquiry(){
        this.isLoading = true
        getDefualtValueForEnquiry()
        .then(result=>{
            console.log(' getDefualtValueForEnquiry result', JSON.stringify(result, null, 2));
            if(result != null){
                if(result.commodityId != undefined){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                    let Obj={Id:result.commodityId,Name:result.commodityName}
                    field.handleDefaultSelected(Obj);
                }
                if(result.incoTermId != undefined){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                    let Obj={Id:result.incoTermId,Name:result.incoTermName}
                    field.handleDefaultSelected(Obj);
                }
            }
            this.shipmentKind = 'FCL';
            this.updateEnquiryList();
            this.isLoading = false;
        })
        .catch(error=>{
            console.log(' getDefualtValueForEnquiry error', JSON.stringify(error, null, 2));
            this.isLoading = false;
        })
    }
    handleResetRoute(e){
        let index = e.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('resetform', { detail:  index}));
    }
    handleCopyFromAbove(e){
        let index = e.target.dataset.recordId;
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
            /*setTimeout(() => {
                if(this.placeOfPickup != ''){
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[5];
                    let Obj={Id:this.placeOfPickup,Name:this.placeOfPickupName}
                    if(field != null) field.handleDefaultSelected(Obj);
                }
            }, 100);*/
        }
        if(this.serviceType  == 'P2D' || this.serviceType  == 'D2D'){
            this.showDischargePlaceField = true;
            /*setTimeout(() => {
                if(this.placeOfDischarge != ''){                    
                    let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[5];
                    let Obj={Id:this.placeOfDischarge,Name:this.placeOfDischargeName}
                    if(field != null) field.handleDefaultSelected(Obj);
                }
            }, 100);*/
        }
       let containerData = this.leadEnquiryList[0].containerRecord;
       let copyCObj={
        'index':index,
        'size': containerData.length
       }
       this.dispatchEvent(new CustomEvent('addemptycontainertype', { detail:  copyCObj}));
       for(let i=0 ;i<containerData.length;i++){  
            setTimeout(() => {
                let qtyCompt = this.template.querySelectorAll('c-bafco-lead-enquiry-entry-qty')[i];
                qtyCompt.handleCopyData(containerData[i],index);
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
    handleshipmentKindChange(e){
        let shipmentKind = e.target.value;
        this.shipmentKind = shipmentKind;
        this.shipmentKindClass ='';
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
        this.updateEnquiryList();
    }
    handlePickupPlaceInputchange(e){
        this.placeOfPickup = e.target.value;
        this.updateEnquiryList();
    }
   /* handlePickupPlaceSelection(e){
        let placeOfPickup = e.detail.Id;
        this.placeOfPickup = placeOfPickup;
        this.placeOfPickupName = e.detail.Name
        this.pickupPlaceClass ='';
        this.updateEnquiryList();
    }
    handlePickupRemoved(e){
        this.placeOfPickup = '';
        this.placeOfPickupName = '';
        this.updateEnquiryList();
    }
    handleDischargeSelection(e){
        let placeOfDischarge = e.detail.Id;
        this.placeOfDischarge = placeOfDischarge;
        this.placeOfDischargeName = e.detail.Name
        this.dischargePlaceClass ='';
        this.updateEnquiryList();
    }
    
    handleDischargeRemoved(e){
        this.placeOfDischarge = '';
        this.placeOfDischargeName ='';
        this.updateEnquiryList();
    }*/
    handleCargoChange(e){
        let cargoWeights = e.target.value;
        this.cargoWeights = cargoWeights;
        this.cargoweightClass ='';
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
            if(result.Dangerous_Goods__c == true){
                this.showDGClassField = true;
                this.dgClass = result.DG_Class__c != undefined ? result.DG_Class__c : '';
            }
            if(this.incoTerm != ''){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
                let Obj={Id:result.INCO_Term__c,Name:result.INCO_Term__r.Name}
                if(field != null) field.handleDefaultSelected(Obj);
            }
            if(result.Port_of_Loading__c != undefined){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[1];
                let Obj={Id:result.Port_of_Loading__c,Name:result.Port_of_Loading__r.Name,index:index}
                field.handleDefaultSelected(Obj);
            }
            if(result.Port_of_Destination__c != undefined){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[2];
                let Obj={Id:result.Port_of_Destination__c,Name:result.Port_of_Destination__r.Name,index:index}
                field.handleDefaultSelected(Obj);
            }
            if(result.Shipping_Line__c != undefined){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[3];
                let Obj={Id:result.Shipping_Line__c,Name:result.Shipping_Line__r.Name,index:index}
                field.handleDefaultSelected(Obj);
            }
            if(result.Commodity__c != undefined){
                let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
                let Obj={Id:result.Commodity__c,Name:result.Commodity__r.Name,index:index}
                field.handleDefaultSelected(Obj);
            }
            if(this.serviceType  == 'D2P' || this.serviceType  == 'D2D'){
                this.showPickupPlaceField = true;
                setTimeout(() => {
                    if(result.Place_of_Pickup__c != undefined){
                        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[5];
                        let Obj={Id:result.Place_of_Pickup__c,Name:result.Place_of_Pickup__r.Name,index:index}
                        if(field != null) field.handleDefaultSelected(Obj);
                    }
                }, 100);
            }
            if(this.serviceType  == 'P2D' || this.serviceType  == 'D2D'){
                this.showDischargePlaceField = true;
                setTimeout(() => {
                    if(result.Place_of_Discharge__c != undefined){                    
                        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[5];
                        let Obj={Id:result.Place_of_Discharge__c,Name:result.Place_of_Discharge__r.Name,index:index}
                        if(field != null) field.handleDefaultSelected(Obj);
                    }
                }, 100);
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
            'containerRecords':this.containerRecords,
            'shipmentKindClass':this.shipmentKindClass,
            'serviceTypeClass':this.serviceTypeClass,
            'incoTermClass':this.incoTermClass,
            'portOfLoadingClass':this.portOfLoadingClass,
            'portOfDestinationClass':this.portOfDestinationClass,
            'commodityClass':this.commodityClass,
            'cargoweightClass':this.cargoweightClass,
            'dischargePlaceClass':this.dischargePlaceClass,
            'pickupPlaceClass':this.pickupPlaceClass
        }
        let updateleadEntryDto = JSON.parse(JSON.stringify(leadEntryDto));
        this.dispatchEvent(new CustomEvent('update', { detail: { dto: updateleadEntryDto } }));
    }
    handleContainerTypeSelection(event){
        let dto = event.detail.dto;
        let index = dto.index;
        let containerTypeID = dto.containerTypeID;
        let containerTypeName = dto.containerTypeName;
        let obj={
            'index':index,
            'containerTypeID':containerTypeID,
            'containerTypeName':containerTypeName
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containertypeupdate', { detail: { dto: containerDto } }));
    }
    handleContainerTypeRemoved(event){
        let dto = event.detail.dto;
        let index = dto.index;
        let obj={
            'index':index,
            'containerTypeID':'',
            'containerTypeName':'',
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containertypeupdate', { detail: { dto: containerDto } }));
    }
    handleQuantityChange(event){
        let dto = event.detail.dto;
        let index = dto.index;
        let quantityValue = dto.quantity;
        let obj={
            'index':index,
            'quantity':quantityValue,
        }
        let containerDto = JSON.parse(JSON.stringify(obj));
        this.dispatchEvent(new CustomEvent('containerqtyupdate', { detail: { dto: containerDto } }));
    }
    handleRemoveContainer(e){
        let strIndex = e.detail
        this.dispatchEvent(new CustomEvent('removecontainertype', { detail:  strIndex}));
    }
    handleAddContainer(e){
        let strIndex = e.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('addcontainertype', { detail:  strIndex}));
    }
    @api removeDefaultOnImport(){
        let field = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[4];
        field.handleRemovePill();
        let field2 = this.template.querySelectorAll('c-b-a-f-c-o-custom-look-up-component')[0];
        field2.handleRemovePill();
        this.shipmentKind = '';
        this.updateEnquiryList();
    }
    @api onSubmit(){
        this.isLoading = true;
    }

    @api submitdone(){
        this.isLoading = false;
    }
}