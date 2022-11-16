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
        if(this.entryIntVar <= 6)
        this.leadEnquiryList.push(leadEnqObj); 
        if(this.entryIntVar == 6){
            this.dontShowAddNewRoute = true;
        }
        console.log('Lead List '+JSON.stringify(this.leadEnquiryList,null,2));
    }       
    handleSubmit(){
        console.log('lead List' +JSON.stringify(this.leadEnquiryList,null,2))
        console.log('businessTypeSelected '+this.businessTypeSelected)
        if(this.businessTypeSelected != ''){
            submitRoutingList({ 
                routingList : this.leadEnquiryList,
                businessType : this.businessTypeSelected,
                quoteId : this.quoteId
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
        else{
            this.quoteTypeErrorClass = 'slds-has-error';
            this.quoteTypeErrorMsg  = 'Complete this field.';
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
        this.leadEnquiryList[splitIndex[0] - 1].containerRecord[splitIndex[1] - 1].containerType = containerTypeID;
        this.leadEnquiryList[splitIndex[0] - 1].containerRecord[splitIndex[1] - 1].containerTypeName = containerTypeName;
    }
    handleContainerQTYUpdate(e){
        let prdDto = JSON.parse(JSON.stringify(e.detail.dto));
        let index = prdDto.index;
        let splitIndex = index.split('.');
        let qty = prdDto.quantity;
        this.leadEnquiryList[splitIndex[0] - 1].containerRecord[splitIndex[1] - 1].quantity = qty;
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
        let strIndex = cData.index
        let tempList1 = this.leadEnquiryList;
        tempList1[strIndex - 1].containerRecord = [];
        this.leadEnquiryList = JSON.parse( JSON.stringify( tempList1 ) );
        for(let i = 0 ;i<cData.size; i++ ){  
            let tempList = this.leadEnquiryList;  
            let newContainerIndex= i+1 
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
        }
    }
    handleResetFormClicked(e){
        let strIndex = e.detail;
        console.log('strIndex '+strIndex)
        console.log(JSON.stringify(this.leadEnquiryList[strIndex - 1 ],null,2));
        this.leadEnquiryList[strIndex - 1 ].routingRegular = '';
        this.leadEnquiryList[strIndex - 1 ].shipmentKind = '';
        this.leadEnquiryList[strIndex - 1 ].serviceType = '';
        this.leadEnquiryList[strIndex - 1 ].incoTerm = '';
        this.leadEnquiryList[strIndex - 1 ].incoTermName = '';
        this.leadEnquiryList[strIndex - 1 ].portLoading = '';
        this.leadEnquiryList[strIndex - 1 ].portLoadingName = '';
        this.leadEnquiryList[strIndex - 1 ].portDestination = '';
        this.leadEnquiryList[strIndex - 1 ].portDestinationName = '';
        this.leadEnquiryList[strIndex - 1 ].shippingLine = '';
        this.leadEnquiryList[strIndex - 1 ].shippingLineName = '';
        this.leadEnquiryList[strIndex - 1 ].placeOfPickup = '';
        this.leadEnquiryList[strIndex - 1 ].placeOfDischarge = '';
        this.leadEnquiryList[strIndex - 1 ].commodity = '';
        this.leadEnquiryList[strIndex - 1 ].commodityName = '';
        this.leadEnquiryList[strIndex - 1 ].cargoWeights=0
        this.leadEnquiryList[strIndex - 1 ].dangerousGoods=false
        this.leadEnquiryList[strIndex - 1 ].remarks = '';
        this.leadEnquiryList[strIndex - 1 ].dgClass = '';
        this.leadEnquiryList[strIndex - 1 ].showDGClassField = false
        this.leadEnquiryList[strIndex - 1 ].showPickupPlaceField = false
        this.leadEnquiryList[strIndex - 1 ].showDischargePlaceField = false
        this.leadEnquiryList[strIndex - 1 ].incoTermField = '';
        this.leadEnquiryList[strIndex - 1 ].copyFromAbove = false
        this.leadEnquiryList[strIndex - 1 ].placeOfPickupName = '';
        this.leadEnquiryList[strIndex - 1 ].placeOfDischargeName = '';
        this.template.querySelector('c-b-a-f-c-o-lead-enquiry-entry-intake').resetform(strIndex);
        console.log(JSON.stringify(this.leadEnquiryList[strIndex - 1 ],null,2));
    }
}