import { LightningElement,track, wire,api } from 'lwc';
import submitRoutingList from '@salesforce/apex/BAFCOLRoutingDetailsController.submitRoutingList';
import getLeadDetails from '@salesforce/apex/BAFCOLeadDetailsController.getLeadDetails';
import { getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import BUSINESS_TYPE_FIELD from '@salesforce/schema/Opportunity.Business_Type__c';
import { NavigationMixin } from 'lightning/navigation';
import ROUTE_OBJECT from '@salesforce/schema/Route__c';
import CONTAINER_PNG from '@salesforce/resourceUrl/AddContainer';
import getAllRegularRoute from '@salesforce/apex/BAFCOLRoutingDetailsController.getAllRegularRoute';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCommercialUserOnLoad from '@salesforce/apex/BAFCOLRoutingDetailsController.getCommercialUserOnLoad';
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
    @track ErrorList = [];
    @track commercialUserId = '';
    @track commercialUserName = '';
    @track isLoading = false;
    @track customerErrorClass = '';
    @track minDate = '';


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
        let todaysDate = new Date();
        this.minDate = this.formatDate(todaysDate);
        this.getCommercialUserOnLoad();
        this.getAllRegularRoute();
        this.addRouteEnquiry();
        this.getDefaultBusinessType();
    }
    getCommercialUserOnLoad(){
        getCommercialUserOnLoad({AccountId : this.quoteId})
        .then(result=>{
            console.log('getCommercialUserOnLoad result'+JSON.stringify(result,null,2));
            if(result != null){
                let commercialUserId = result[0].Commercial_User__c;
                let commercialUserName = result[0].Commercial_User__r.Name;
                let field = this.template.querySelector('c-b-a-f-c-o-custom-look-up-component');
                let Obj={Id:commercialUserId,Name:commercialUserName}
                field.handleDefaultSelected(Obj);
            }

        })
        .catch(error=>{
            console.log('getCommercialUserOnLoad error'+error);
        })
    }
    formatDate(date) {
        let d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + (d.getDate()),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
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
            'containerTypeErrorClass':'',
            'containerQuantityErrorClass':'',
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
            'parentId':this.quoteId,
            'shipmentKindClass':'',
            'serviceTypeClass':'',
            'incoTermClass':'',
            'portOfLoadingClass':'',
            'portOfDestinationClass':'',
            'commodityClass':'',
            'cargoweightClass':'',
            'dischargePlaceClass':'',
            'pickupPlaceClass':'',
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
        this.isLoading = true;
        let ChildList = this.template.querySelectorAll('c-b-a-f-c-o-lead-enquiry-entry-intake');
        if(ChildList.length > 0){
            ChildList.forEach(elem=>{
            elem.onSubmit();
            })
        }
        let allValid = true;
        let errorList = [];
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
        else if(this.closeDate < this.minDate){
            let closeDateField = this.template.querySelector("[data-field='closeDateField']");
            closeDateField.setCustomValidity("Date should be greater than today.");
            closeDateField.reportValidity();
            allValid  = false;
        }
        this.leadEnquiryList.forEach(elem=>{
            let tempErrorList = [];
            /*if(elem.shipmentKind == '') {
                tempErrorList.push('Please fill kind of shipment')
                elem.shipmentKindClass = 'slds-has-error';

            }*/
            if(elem.serviceType == '') {
                tempErrorList.push('Please fill Service Type')
                elem.serviceTypeClass = 'slds-has-error';
            }
            if(elem.incoTerm == '') {
                tempErrorList.push('Please fill Inco term')
                elem.incoTermClass = 'slds-has-error';
            }
            if(elem.portLoading == '') {
                tempErrorList.push('Please fill Port of Loading')
                elem.portOfLoadingClass = 'slds-has-error';
            }
            if(elem.portDestination == '') {
                tempErrorList.push('Please fill Port of Destination')
                elem.portOfDestinationClass = 'slds-has-error';
            }
            if(elem.commodity == '') {
                tempErrorList.push('Please fill commodity')
                elem.commodityClass = 'slds-has-error';
            }
            if(elem.serviceType == 'D2P' && elem.placeOfPickup == ''){
                tempErrorList.push('Please fill cargoWeights')
                elem.pickupPlaceClass = 'slds-has-error';
            }
            if(elem.serviceType == 'D2D' && elem.placeOfDischarge == ''){
                tempErrorList.push('Please fill cargoWeights')
                elem.dischargePlaceClass = 'slds-has-error';
            }
            elem.containerRecord.forEach(elem2=>{
                if(elem2.containerType == '' ){
                    elem2.containerTypeErrorClass = 'slds-has-error';
                    allValid = false
                }
                if(elem2.quantity <= 0){
                    elem2.containerQuantityErrorClass = 'slds-has-error';
                    allValid = false
                }
            })
            if(tempErrorList.length > 0){
               allValid  = false;
               errorList.push(elem.routeName);
            }
            if(this.commercialUserId == ''){
                allValid = false;
                this.customerErrorClass = 'slds-has-error'
            }
        })
        if(allValid){
            this.isLoading = true
            submitRoutingList({ 
                routingList : this.leadEnquiryList,
                businessType : this.businessTypeSelected,
                quoteId : this.quoteId,
                closeDate : this.closeDate,
                commercialUserId : this.commercialUserId
            })
            .then(result =>{
                this.isLoading = false
                console.log('routing submit  result : ', JSON.stringify(result,null,2));
                if(ChildList.length > 0){
                    ChildList.forEach(elem=>{
                    elem.submitdone();
                    })
                }
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
                this.isLoading = false
                if(ChildList.length > 0){
                    ChildList.forEach(elem=>{
                    elem.submitdone();
                    })
                }
            });
        }
        else{
            console.log('errorList '+JSON.stringify(errorList,null,2))
            
            if(ChildList.length > 0){
                ChildList.forEach(elem=>{
                elem.submitdone();
                })
            }
            setTimeout(() => {
                this.isLoading = false
            }, 100);
            setTimeout(() => {
                this.showErrorToast();
            }, 300);
           
        }
    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Missing Field',
            message: 'Complete the missing field.',
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    } 
    handleBusinessTypeChange(event){
        this.businessTypeSelected = event.target.value
        this.quoteTypeErrorClass ='';
        this.quoteTypeErrorMsg ='';
        let ChildList = this.template.querySelectorAll('c-b-a-f-c-o-lead-enquiry-entry-intake');
        if(ChildList.length > 0){
            ChildList.forEach(elem=>{
                if(this.businessTypeSelected == 'Import' )elem.removeDefaultOnImport();
                else if(this.businessTypeSelected == 'Export')elem.getDefualtValueForEnquiry();
            })
        }
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
                elem.shipmentKindClass = prdDto.shipmentKindClass
                elem.serviceTypeClass = prdDto.serviceTypeClass
                elem.incoTermClass = prdDto.incoTermClass
                elem.portOfLoadingClass = prdDto.portOfLoadingClass
                elem.portOfDestinationClass = prdDto.portOfDestinationClass
                elem.commodityClass = prdDto.commodityClass
                elem.cargoweightClass = prdDto.cargoweightClass
                elem.dischargePlaceClass = prdDto.dischargePlaceClass
                elem.pickupPlaceClass = prdDto.pickupPlaceClass
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
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].containerTypeErrorClass = '';
    }
    handleContainerQTYUpdate(e){
        let prdDto = JSON.parse(JSON.stringify(e.detail.dto));
        let index = prdDto.index;
        let splitIndex = index.split('.');
        let qty = prdDto.quantity;
        let indexOfLeadEnquiry = this.leadEnquiryList.findIndex(x => x.leadIndex == splitIndex[0] );
        let childContainerIndex = this.leadEnquiryList[indexOfLeadEnquiry].containerRecord.findIndex(x => x.index == index );
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].quantity = qty;
        this.leadEnquiryList[indexOfLeadEnquiry].containerRecord[childContainerIndex].containerQuantityErrorClass = '';
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
    handleCommercialUserSelection(e){
        this.commercialUserId = e.detail.Id;
        this.commercialUserName = e.detail.Name;
        this.customerErrorClass ='';
    }
    handleCommercialUserRemoved(e){
        this.commercialUserId = '';
        this.commercialUserName = '';
        this.customerErrorClass ='slds-has-error';
    }
}