import { LightningElement,track, wire,api } from 'lwc';
import submitRoutingList from '@salesforce/apex/BAFCOLRoutingDetailsController.submitRoutingList';
import getLeadDetails from '@salesforce/apex/BAFCOLeadDetailsController.getLeadDetails';
import { getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/Enquiry__c.Business_Type__c';
import { NavigationMixin } from 'lightning/navigation';
import ROUTE_OBJECT from '@salesforce/schema/Route__c';
import CONTAINER_PNG from '@salesforce/resourceUrl/AddContainer';
import getAllRegularRoute from '@salesforce/apex/BAFCOLRoutingDetailsController.getAllRegularRoute';
export default class BAFCOLeadEnquiryCreationComponent extends NavigationMixin(LightningElement) {
    @track leadEnquiryList = [];
    pickListvalues = [];    
    @track entryIntVar = 1;
    @track contractVar = 1;
    @track businessTypeSelected = '';
    @api quoteId;
    @track kindOfShipmentOption= [];
    @track serviceTypeOption = [];
    @track dgClassOption = [];

    @track quoteTypeErrorClass = '';
    @track quoteTypeErrorMsg = '';
    @track showPickupPlaceField = false;
    @track showDischargePlaceField = false;
    @track showDGClassField = false;
    AddContainerPNG = CONTAINER_PNG;
    @track regularRouteOption = [];
    @track dontShowAddNewRoute = false;
    @track closeDate = '';


    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : BUSINESS_TYPE_FIELD
    })wiredPickListValue({ data, error }){
            if(data){
                console.log(` Picklist values are `, data.values);
                this.pickListvalues = data.values;
                this.error = undefined;
            }
            if(error){
                console.log('Error while fetching Picklist values ' +JSON.stringify(error));
                this.error = error;
                this.pickListvalues = undefined;
            }
    }
    @wire(getPicklistValuesByRecordType, { objectApiName: ROUTE_OBJECT, recordTypeId: '012000000000000AAA' })
    routeObjectData({ data, error }) {
        if(data){
            this.kindOfShipmentOption = data.picklistFieldValues.Kind_Of_Shipment__c.values;
            this.serviceTypeOption = data.picklistFieldValues.Service_Type__c.values;
            this.dgClassOption = data.picklistFieldValues.DG_Class__c.values;
        }
        else if(error){
            console.log(' Route Object data error', JSON.stringify(error, null, 2));
        }
    }

    connectedCallback(){
        this.getAllRegularRoute();
        this.addRouteEnquiry();
        this.getDefaultBusinessType();
    }
    getAllRegularRoute(){
        getAllRegularRoute()
        .then(result=>{
            //console.log('getAllRegularRoute result: ',result)
            let templist = [];
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
    addRouteEnquiry(){
        let containerRecord = {
            'containerType':'',
            'containerTypeName':'',
            'quantity':0,
            'index' : this.entryIntVar +'.'+ this.contractVar
        }
        let contrTempList  = [];
        contrTempList.push(containerRecord);
        let leadEnqObj ={
            'routeName':'Route '+this.entryIntVar,
            'routingRegular':'',
            'shipmentKind':'',
            'serviceType':'',
            'incoTerm':'',
            'incoTermName':'',
            'portLoading':'',
            'portLoadingName':'',
            'portDestination':'',
            'portDestinationName':'',
            'shippingLine':'',
            'shippingLineName':'',
            'placeOfPickup':'',
            'placeOfDischarge':'',
            'commodity':'',
            'commodityName':'',
            'cargoWeights':0,
            'dangerousGoods':false,
            'remarks':'',
            'dgClass':'',
            'leadIndex':this.entryIntVar,
            'containerRecord': contrTempList,
            'showDGClassField':false,
            'showPickupPlaceField':false,
            'showDischargePlaceField':false,
            'incoTermField':this.entryIntVar+'incoTermField',
            'copyFromAbove':this.entryIntVar > 1 ? true : false,
            'placeOfPickupName':'',
            'placeOfDischargeName':'',
            'parentId':this.quoteId
        }
        this.entryIntVar++;
       if(this.leadEnquiryList.length <= 4 ){
            this.leadEnquiryList.push(leadEnqObj); 
        }
        else{
            this.dontShowAddNewRoute = true;
        }
        if(this.leadEnquiryList.length == 5){
            this.dontShowAddNewRoute = true;
        }
        console.log('Lead List '+JSON.stringify(this.leadEnquiryList,null,2));
    }       
    handleSubmit(){
        console.log('lead List' +JSON.stringify(this.leadEnquiryList,null,2))
        console.log('businessTypeSelected '+this.businessTypeSelected)
        let allValid = true;
        if(this.businessTypeSelected == '' || this.businessTypeSelected == undefined){
            this.quoteTypeErrorClass = 'slds-has-error';
            this.quoteTypeErrorMsg  = 'Complete this field.';
            allValid  = false;
        }
        if(this.closeDate == '' || this.closeDate == null){
            let closeDateField = this.template.querySelector("[data-field='closeDateField']");
            closeDateField.setCustomValidity("Complete this field");
            closeDateField.reportValidity();
            allValid  = false;
        }
        if(allValid){
            submitRoutingList({ 
                routingList : this.leadEnquiryList,
                businessType : this.businessTypeSelected,
                quoteId : this.quoteId,
                closeDate : this.closeDate
            })
            .then(result =>{
                console.log('routing submit  result : ', JSON.stringify(result,null,2));
                    this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Enquiry__c',
                        actionName: 'view'
                    }
                });
            }).catch(error=>{
                console.log('routing submit error lead: ', JSON.stringify(error));
            });
        }
    }    
    handleBusinessTypeChange(event){
        this.businessTypeSelected = event.target.value
        this.quoteTypeErrorClass ='';
        this.quoteTypeErrorMsg ='';
    }
    getDefaultBusinessType(){
        getLeadDetails({leadId : this.quoteId})
        .then(result =>{
            this.businessTypeSelected = result.businessType;
        }).catch(error=>{
            console.log('error lead: ', JSON.stringify(error));
        });
    }
    handleEnquiryListUpdate(event){
        let prdDto = JSON.parse(JSON.stringify(event.detail.dto));
        this.leadEnquiryList.forEach(elem => {
            if(elem.leadIndex == prdDto.leadIndex) {
                elem.shipmentKind = prdDto.shipmentKind;
                elem.serviceType = prdDto.serviceType;
                elem.incoTerm = prdDto.incoTerm;
                elem.routingRegular = prdDto.routingRegular;
                elem.portLoading = prdDto.portLoading;
                elem.portDestination = prdDto.portDestination;
                elem.shippingLine = prdDto.shippingLine;
                elem.showPickupPlaceField = prdDto.showPickupPlaceField;
                elem.showDischargePlaceField = prdDto.showDischargePlaceField;
                elem.placeOfPickup = prdDto.placeOfPickup;
                elem.placeOfDischarge = prdDto.placeOfDischarge;
                elem.commodity = prdDto.commodity;
                elem.cargoWeights = prdDto.cargoWeights;
                elem.remarks = prdDto.remarks;
                elem.dgClass = prdDto.dgClass;
                elem.dangerousGoods = prdDto.dangerousGoods;
                elem.showDGClassField = prdDto.showDGClassField;
                elem.incoTermName = prdDto.incoTermName;
                elem.portLoadingName = prdDto.portLoadingName;
                elem.portDestinationName = prdDto.portDestinationName;
                elem.shippingLineName = prdDto.shippingLineName;
                elem.commodityName = prdDto.commodityName;
                elem.placeOfPickupName = prdDto.placeOfPickupName;
                elem.placeOfDischargeName = prdDto.placeOfDischargeName;
                elem.containerRecords = prdDto.containerRecords;
            }
        })
        console.log('updated List '+ JSON.stringify(this.leadEnquiryList,null,2))
    }
    handleContainerTypeUpdate(e){
        let prdDto = JSON.parse(JSON.stringify(e.detail.dto));
        let index = prdDto.index;
        let splitIndex = index.split('.');
        let containerTypeID = prdDto.containerTypeID;
        let containerTypeName = prdDto.containerTypeName;
        let indexOfLeadEnquiry = this.leadEnquiryList.findIndex(x => x.leadIndex == splitIndex[0] );
        let childContainerIndex = this.leadEnquiryList[indexOfLeadEnquiry].containerRecord.findIndex(x => x.index == index );
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].containerType = containerTypeID;
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].containerTypeName = containerTypeName;
    }
    handleContainerQTYUpdate(e){
        let prdDto = JSON.parse(JSON.stringify(e.detail.dto));
        let index = prdDto.index;
        let splitIndex = index.split('.');
        let qty = prdDto.quantity;
        let indexOfLeadEnquiry = this.leadEnquiryList.findIndex(x => x.leadIndex == splitIndex[0] );
        let childContainerIndex = this.leadEnquiryList[indexOfLeadEnquiry].containerRecord.findIndex(x => x.index == index );
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].quantity = qty;
    } 
    handleContainerTypeRemove(e){
        let index = e.detail
        let tempLeadList = this.leadEnquiryList;
        let indexofBothList = index.split('.');
        let LeadIndex = indexofBothList[0] - 1;
        let indexOfRemoved = indexofBothList[1] - 1;
        let containerRecords = tempLeadList[LeadIndex].containerRecord;
        if(containerRecords.length != 1)
        containerRecords.splice( indexOfRemoved, 1 );
    }
    handleAddContainerType(e){
        let strIndex = e.detail
        let tempList = this.leadEnquiryList;   
        let lastcontainer = tempList[strIndex - 1].containerRecord.length;
        let indexOfPreviousRecord = tempList[strIndex - 1].containerRecord[lastcontainer - 1].index.split('.');
        let newContainerIndex = indexOfPreviousRecord[1];
        newContainerIndex++;
        let lastContainerRecord = tempList[strIndex - 1].containerRecord;
        let containerRecord = {
            'containerType':'',
            'quantity':0,
            'containerTypeName':'',
            'index' : strIndex +'.'+ newContainerIndex
        }
        lastContainerRecord.push(containerRecord);
        tempList[strIndex - 1].containerRecord = lastContainerRecord;
        this.leadEnquiryList = JSON.parse( JSON.stringify( tempList ) );
        console.log('****2 '+JSON.stringify(this.leadEnquiryList,null,2))
    }
    handleCopyContainerData(e){
        let copyData = e.detail.dto;
        console.log('copyData '+JSON.stringify(copyData,null,2))
    } 
    handleaddEmptycontainertype(e){
        let cData = e.detail;
        let cameIndex = cData.index
        let tempList1 = this.leadEnquiryList;
        let strIndex = this.leadEnquiryList.findIndex(x => x.leadIndex == cameIndex );
        tempList1[strIndex].containerRecord = [];
        this.leadEnquiryList = JSON.parse( JSON.stringify( tempList1 ) );
        for(let i = 0 ;i<cData.size; i++ ){  
            let tempList = this.leadEnquiryList;  
            let newContainerIndex= i+1 
            let lastContainerRecord = tempList[strIndex].containerRecord;
            let containerRecord = {
            'containerType':'',
            'quantity':0,
            'containerTypeName':'',
            'index' : cameIndex +'.'+ newContainerIndex
            }
            lastContainerRecord.push(containerRecord);
            tempList[strIndex].containerRecord = lastContainerRecord;
            this.leadEnquiryList = JSON.parse( JSON.stringify( tempList ) );
        }
        
    }
    handelCloseDate(e){
        this.closeDate =e.target.value
        let closeDateField = this.template.querySelector("[data-field='closeDateField']");
        if(this.closeDate == null){
            closeDateField.setCustomValidity("Complete this field");
        }
        else{
            closeDateField.setCustomValidity("");
        }        
        closeDateField.reportValidity();
    }
    handleRemoveRouteOption(e){
        let index = e.target.value;
        if(index != 1){
            let indexTobeRemoved = this.leadEnquiryList.findIndex(x => x.leadIndex == index );
            if(indexTobeRemoved != -1) {
                this.leadEnquiryList.splice( indexTobeRemoved, 1 );
            }
        }
        if(this.leadEnquiryList.length <= 5){
            this.dontShowAddNewRoute = false
        }
        else{
            this.dontShowAddNewRoute = true
        }
    }
}