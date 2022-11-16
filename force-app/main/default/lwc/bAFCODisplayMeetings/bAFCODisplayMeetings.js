import { LightningElement,track,wire } from 'lwc';
import getMeetingsRecords from '@salesforce/apex/BAFCOMeetingController.getMeetingsRecords';
import { NavigationMixin } from 'lightning/navigation';
import Event_OBJECT from '@salesforce/schema/Event';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import submitMeetingsRecords from '@salesforce/apex/BAFCOMeetingController.submitMeetingsRecords';
import getIntakeMeetingObj from '@salesforce/apex/BAFCOMeetingController.getIntakeMeetingObj';
import updateEventObject from '@salesforce/apex/BAFCOMeetingController.updateEventObject';
export default class BAFCODisplayMeetings extends NavigationMixin(LightningElement) {
    showCreateMeeting = false;
    @track objectChoosed ='Lead';
    @track eventList = [];
    @track visitForOption = [];
    @track visitFor ='';
    @track startDate = '';
    @track startTime = '';
    isLoading = false; 
    @track objectName = 'Lead__c';
    @track placeholder ='Search Lead';
    @track whatId ='';
    @track whatIdName ='';
    @track todaysDate;
    @track whatIdErrorClass = '';
    @track whatIdErrorMsg ='';
    @track objecticon = 'standard:lead';
    @track objectApiName = 'Lead__c';
    @track filteredDate = ''; 
    @track hasEvent  = false;
    @track displayIntakeForm = false;
    @track eventId = '';
    @track displayInitial = true;
    get radioOptions() {
        return [
            { label: 'Lead', value: 'Lead' },
            { label: 'Account', value: 'Account' }
        ];
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: Event_OBJECT, recordTypeId: '012000000000000AAA' })
    routeObjectData({ data, error }) {
        if(data){
            let visitForOption = data.picklistFieldValues.Purpose_of_Visit__c.values;
            let tempList =[];
            visitForOption.forEach(elem=>{
                tempList.push({
                    label:elem.label,
                    value:elem.value
                })
            })
            this.visitForOption = tempList
        }
        else if(error){
            console.log(' Event  data error', JSON.stringify(error, null, 2));
        }
    }
    connectedCallback(){
        //this.handleGetCurrentLocationClick();
        document.title = 'Meeting';
        this.todaysDate = new Date().toISOString();  
        this.startDate = this.formatDate(this.todaysDate);
        this.startTime  = this.formatTime(this.todaysDate);
        this.filteredDate = this.formatDate(this.todaysDate);
        this.objectChoosed = 'Lead';
        this.placeholder ='Search Lead';
        this.objecticon = 'standard:lead';
        this.displayInitial = true;
        this.getMeetingsRecords();       
    }
    getMeetingsRecords(){
        this.isLoading = true;
        console.log('filetered date '+this.filteredDate)
        getMeetingsRecords({filteredDate : this.filteredDate})
        .then(result =>{
            console.log('getMeetingsRecords result ',JSON.stringify(result,null,2))
            this.eventList = result;
            if(this.eventList.length > 0 ) this.hasEvent = true;
            else this.hasEvent = false;
            this.showCreateMeeting = false;
            this.displayInitial = true;
            this.displayIntakeForm = false
            this.isLoading = false;
        })
        .catch(error=>{
            console.log('getMeetingsRecords error ',JSON.stringify(error))
            this.isLoading = false;
            this.hasEvent = false;
        })
    }
    handleCreateMeetingClicked(){
        this.showCreateMeeting = true;
        this.displayInitial = false;
    }
    handleCustomerChoosed(event){
        this.objectChoosed = event.target.value;
        if(this.objectChoosed == 'Lead') {
            this.objectApiName = 'Lead__c'
            this.placeholder ='Search Lead'
            this.objecticon = 'standard:lead';
        }
        else if(this.objectChoosed == 'Account'){
            this.objectApiName = 'Account'
            this.placeholder ='Search Account'
            this.objecticon = 'standard:account';
        }
    }
    handleEventCardClicked(e){
        this.eventId = e.target.dataset.evid;
        this.displayIntakeForm = true;  
        this.displayInitial = false;
        this.isLoading1 = true;
        this.getIntakeMeetingObj();
        this.handleGetCurrentLocationClick();    
    }
    handleRecordUpdated(e){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: e.detail,
                actionName: 'view'
            },
        }).then(url => { window.open(url,"_self") });
    }
    handlevisitForChange(e){
        this.visitFor =e.target.value
        let visitForField = this.template.querySelector("[data-field='visitFor']");
        visitForField.setCustomValidity(''); 
        visitForField.reportValidity();
    }
    handleCreateMeeting(){
        let allValid = true;
        if(this.whatId == ''){
            this.whatIdErrorClass= 'slds-has-error';
            this.whatIdErrorMsg = 'Complete this field.';
            allValid = false
        }
        if(this.startDate == null ){
            let startDateField = this.template.querySelector("[data-field='startDate']");
            startDateField.setCustomValidity('Complete this field.'); 
            startDateField.reportValidity();
            allValid = false;
        }
        if(this.startTime == null){
            let startTimeField = this.template.querySelector("[data-field='startTime']");
            startTimeField.setCustomValidity('Complete this field.'); 
            startTimeField.reportValidity();
            allValid = false;
        }
        if(this.visitFor == ''){
            let visitForField = this.template.querySelector("[data-field='visitFor']");
            visitForField.setCustomValidity('Complete this field.'); 
            visitForField.reportValidity();
            allValid = false;
        }
        if(allValid){
            submitMeetingsRecords({
                whatId : this.whatId,
                whatIdName: this.whatIdName,
                startDate : this.startDate,
                startTime : this.startTime,
                visitFor : this.visitFor,
            })
            .then(result=>{
                console.log('submitMeetingsRecords result ',JSON.stringify(result))
                this.getMeetingsRecords();
            })
            .catch(error=>{
                console.log('submitMeetingsRecords error ',JSON.stringify(error))
            })
    
        }
    }
    handleDateChange(e){
        this.startDate = e.target.value
        let startDateField = this.template.querySelector("[data-field='startDate']");
        startDateField.setCustomValidity(''); 
        startDateField.reportValidity();
    }
    handletimeChange(e){
        this.startTime = e.target.value
        let startTimeField = this.template.querySelector("[data-field='startTime']");
        startTimeField.setCustomValidity(''); 
        startTimeField.reportValidity();
    }
    formatDate(date) {
        let d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    }
    formatTime(date){
        let t = new Date(date),
            hour = '' +(t.getHours() + 1),
           // minute = '' +t.getMinutes() <= 9 ? '0'+ t.getMinutes() : t.getMinutes()
           //minute = '' +t.getMinutes() <= 9 ? '0'+ (Math.round(t.getMinutes()/15) * 15) % 60 : (Math.round(t.getMinutes()/15) * 15) % 60;
           //minute = ''+t.getMinutes() == 0 ? '00': t.getMinutes() > 0 && t.getMinutes() <= 9  ? '0'+ (Math.round(t.getMinutes()/15) * 15) % 60 : (Math.round(t.getMinutes()/15) * 15) % 60 == 0 ? '00' : (Math.round(t.getMinutes()/15) * 15) % 60;
           minute = ''+t.getMinutes() == 0 ? '00': (Math.round(t.getMinutes()/15) * 15) % 60 == 0 ? '00' : (Math.round(t.getMinutes()/15) * 15) % 60;
        return [hour, minute].join(':');
    }
    handleGetCurrentLocationClick(){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                 this.latitude = position.coords.latitude;
                this.longitude = position.coords.longitude;
            })
        }
    }
    handleWhatIdSelection(e){
        this.whatId = e.detail.Id
        this.whatIdName = e.detail.Name;
        this.whatIdErrorClass = '';
        this.whatIdErrorMsg = '';
    }
    handleWhatIdRemoved(e){
        this.whatId = '';
        this.whatIdName = '';
        this.whatIdErrorClass = 'slds-has-error';
        this.whatIdErrorMsg = 'Complete this field.';
    }
    handlefilteredDateChange(e){
        this.filteredDate = e.target.value
        this.getMeetingsRecords();
    }
    closeMeetingDisplay(){
        this.displayIntakeForm = false;
        this.displayInitial = true;
        this.eventId = '';
    }
    //////////

    @track startDate1 ='';
    @track startTime1 ='';
    @track endDate1='';
    @track endTime1 ='';
    @track meetinginute1 ='';
    @track isLoading1 = false;
    @track fetchedRecorrd1= false;
    @track lati1 ='';
    @track longi1 ='';
    @track whatName1 = '';
    @track filter1 =  null;
    @track enquiryId1 = '';

    getIntakeMeetingObj(){
        this.isLoading1 = true;
        getIntakeMeetingObj({eventId : this.eventId})
        .then(result=>{
            console.log('getIntakeMeetingObj result',result)
            if(result != null){
                this.fetchedRecorrd1 = true;
                this.whatName1 = result.whatName
                this.startDate1 = result.startDate
                this.startTime1 = this.formatTime1(result.startTime)
                this.endDate1 = result.endDate
                this.endTime1 = this.formatTime1(result.endTime)
                this.meetinginute1 = result.meetingMinute  
                if(result.objectName == 'Lead__c') this.filter1 = 'Lead__c = \''+result.whatId+'\'';
                else if(result.objectName == 'Account') this.filter1 = 'Account__c = \''+result.whatId+'\'';
                setTimeout(() => {
                    let childComp = this.template.querySelector('c-b-a-f-c-o-custom-look-up-component');
                console.log('ccccc '+JSON.stringify(childComp,null,2))
                let defaultObj = {Id:result.relatedEnquiryId,Name:result.relatedEnquiryName}
                if(childComp != null){
                    childComp.handleDefaultSelected(defaultObj);
                }
                }, 100);
                
            }
            this.isLoading1 = false;
        })
        .catch(error=>{
            console.log('getIntakeMeetingObj err',error)
            this.isLoading1 = false;
        })
    }
    formatTime1(date){
        let t = new Date(date),
            hour = '' +(t.getHours()),
            minute = ''+t.getMinutes() == 0 ? '00': (Math.round(t.getMinutes()/15) * 15) % 60 == 0 ? '00' : (Math.round(t.getMinutes()/15) * 15) % 60;
        return [hour, minute].join(':');
    }    
    SaveDataBox(){
        let allValid = true;
        if(this.startDate1 == null ){
            let startDateField = this.template.querySelector("[data-field='startDate1']");
            startDateField.setCustomValidity('Complete this field.'); 
            startDateField.reportValidity();
            allValid = false;
        }
        if(this.startTime1 == null){
            let startTimeField = this.template.querySelector("[data-field='startTime1']");
            startTimeField.setCustomValidity('Complete this field.'); 
            startTimeField.reportValidity();
            allValid = false;
        }
        if(this.endDate1 == null ){
            let endDateField = this.template.querySelector("[data-field='endDate1']");
            endDateField.setCustomValidity('Complete this field.'); 
            endDateField.reportValidity();
            allValid = false;
        }
        if(this.endTime1 == null){
            let endTimeField = this.template.querySelector("[data-field='endTime1']");
            endTimeField.setCustomValidity('Complete this field.'); 
            endTimeField.reportValidity();
            allValid = false;
        }
        if(this.meetinginute1 == '' || this.meetinginute1 == undefined || this.meetinginute1 == ''){
            let meetingMinuteField = this.template.querySelector("[data-field='meetingMinute1']");
            meetingMinuteField.setCustomValidity('Complete this field.'); 
            meetingMinuteField.reportValidity();
            allValid = false;
        }
        if(allValid){
            this.isLoading = true
            updateEventObject({
                recordId: this.eventId,
                enquiryId:this.enquiryId1,
                startDate:this.startDate1,
                startTime:this.startTime1,
                endDate:this.endDate1,
                endTime:this.endTime1,
                meetingMinute:this.meetinginute1,
                lati:this.lati1,
                longi:this.longi1
            })
            .then(result=>{
                console.log('result ',result)
                this.isLoading1 = false
                this.isLoading = false;
                this.displayInitial = true
                this.displayIntakeForm = false
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        actionName: 'view'
                    },
                }).then(url => { window.open(url,"_self") });
            })
            .catch(error=>{
                console.log('error ',error)
                this.isLoading1 = false
            })
        }
    }
    handleGetCurrentLocationClick(){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                 this.lati1 = position.coords.latitude;
                this.longi1 = position.coords.longitude;
            })
        }
    }
    handleEnquirySelection(e){
        this.enquiryId1 = e.detail.Id;
    }
    handleEnquiryRemoved(e){
        this.enquiryId1 = '';
    }
    handleStartDateChange(e){
        this.startDate1 = e.detail.value
        let startDateField = this.template.querySelector("[data-field='startDate1']");
        startDateField.setCustomValidity(''); 
        startDateField.reportValidity();
    }
    handleStarttimeChange(e){
        this.startTime1 = e.detail.value
        let Field = this.template.querySelector("[data-field='startTime1']");
        Field.setCustomValidity(''); 
        Field.reportValidity();
    }
    handleEndDateChange(e){
        this.endDate1 = e.detail.value
        let Field = this.template.querySelector("[data-field='endDate1']");
        Field.setCustomValidity(''); 
        Field.reportValidity();
    }
    handleEndtimeChange(e){
        this.endTime1 = e.detail.value
        let Field = this.template.querySelector("[data-field='endTime1']");
        Field.setCustomValidity(''); 
        Field.reportValidity();
    } 
    handleMeetingMinuteChange(e){
        this.meetinginute1 = e.detail.value
        let Field = this.template.querySelector("[data-field='meetingMinute1']");
        Field.setCustomValidity(''); 
        Field.reportValidity();
    }
}