public class BAFCOMeetingController {
    @AuraEnabled
    public static List<EventList> getMeetingsRecords(String filteredDate){
        Id currentUserId = UserInfo.getUserId();
        Date filterDateTime = Date.valueOf(filteredDate);
        List<EventList> eventList = new List<EventList>();
        for(Event ev : [Select id, What.Name,StartDateTime, Purpose_of_Visit__c,Minutes_of_Meeting__c from Event where Start_Date__c =: filterDateTime AND createdbyId =:currentUserId  order by StartDateTime ]){
            EventList evobj = new EventList();
            evobj.recordId = ev.id;
            evobj.accountName =  ev.WhatId != null ? ev.What.Name : '-';
            evobj.startDate = ev.StartDateTime != null ? String.valueOf(date.valueof(ev.StartDateTime)) : '-';
            evobj.startTime = ev.StartDateTime != null ? String.valueOf(ev.StartDateTime.format('h:mm a'))  : '-';
            evObj.visitfor = ev.Purpose_of_Visit__c != null ? ev.Purpose_of_Visit__c : '-';
            evObj.meetingMinute = ev.Minutes_of_Meeting__c != null ? ev.Minutes_of_Meeting__c : '-';
            eventList.add(evobj);                
        }
        return eventList;
    }
    @AuraEnabled
    public static string submitMeetingsRecords(
    	String whatId,
        String whatIdName,
        String startDate,
        String startTime,
        String visitFor 
    ){
        List<String> dateList = startDate.split('-');
        List<String> timeList = startTime.split(':');
        Date myDate = Date.newInstance(integer.valueOf(dateList[0]), integer.valueOf(dateList[1]), integer.valueOf(dateList[2]));
		Time myTime = Time.newInstance(integer.valueOf(timeList[0]), integer.valueOf(timeList[1]),0,0);
        Datetime startDate3 = Datetime.newInstanceGmt(myDate,myTime);
        String startDate2 = startDate3.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + '+00:00';	        
        Event ev =new Event();
        ev.WhatId = whatId;
        ev.StartDateTime = DateTime.valueOf(startDate2.replace('T', ' '));
        ev.Purpose_of_Visit__c = visitFor;
        ev.Subject = visitFor;
        ev.DurationInMinutes = 60;
        ev.Start_Date__c = Date.valueOf(startDate);
        //ev.Checkin_Location__Latitude__s = lat != '' ? Decimal.valueOf(lat) : null;
        //ev.Checkin_Location__Longitude__s = longi !='' ?  Decimal.valueOf(longi) : null;
        insert ev;
        return ev.id;
    }
    @AuraEnabled
    public static EventRecord getIntakeMeetingObj(String eventId){
        EventRecord dto = new EventRecord();
        String objectName = '';
        Event ev = [Select Related_Enquiry__r.Name,id,whatId,what.Name,Start_Date__c,StartDateTime,End_Date__c,EndDateTime,Minutes_of_Meeting__c from event where id =: eventId];       	
        if(ev.WhatId != null){
            dto.objectName = getObjectNameFromId(ev.WhatId);
            dto.whatName = ev.what.Name;
            dto.whatId = ev.WhatId;
        }
        dto.recordId = ev.Id;
        dto.startDate = String.valueOf(ev.Start_Date__c);
        dto.startTime = string.valueOf(ev.StartDateTime);
        dto.endDate = String.valueOf(ev.EndDateTime);
        dto.endTime = String.valueOf(ev.EndDateTime);
        dto.meetingMinute = ev.Minutes_of_Meeting__c;
        dto.relatedEnquiryId = ev.Related_Enquiry__c;
        dto.relatedEnquiryName = ev.Related_Enquiry__r.Name;
        return dto;
    }
    public static String getObjectNameFromId(String recordId){
        String objectAPIName = '';
        String keyPrefix = recordId.substring(0,3);
        for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix == keyPrefix){
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }
        
        return objectAPIName;
    }
    @AuraEnabled
    public static string updateEventObject(
        string recordId,
        String enquiryId,
        String startDate,
        String startTime,
        String endDate,
        String endTime,
        String meetingMinute,
        String lati,
        String longi
    ){
        system.debug('enquiryId : '+enquiryId);
        List<String> dateList = startDate.split('-');
        List<String> timeList = startTime.split(':');
        Date myDate = Date.newInstance(integer.valueOf(dateList[0]), integer.valueOf(dateList[1]), integer.valueOf(dateList[2]));
		Time myTime = Time.newInstance(integer.valueOf(timeList[0]), integer.valueOf(timeList[1]),0,0);
        Datetime startDate3 = Datetime.newInstanceGmt(myDate,myTime);
        String startDate2 = startDate3.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + '+00:00';	   
        
        
        
        List<String> dateList2 = endDate.split('-');
        List<String> timeList2 = endTime.split(':');
        String endDateDay = '';
        if(dateList2[2].contains(' ')){
            List<String> temp = dateList2[2].split(' ');
            endDateDay = temp[0];
        }
        else{
            endDateDay = dateList2[2];
        }
        Date myDate2 = Date.newInstance(integer.valueOf(dateList2[0]), integer.valueOf(dateList2[1]), integer.valueOf(endDateDay));
		Time myTime2 = Time.newInstance(integer.valueOf(timeList2[0]), integer.valueOf(timeList2[1]),0,0);
        Datetime endDate4 = Datetime.newInstanceGmt(myDate2,myTime2);
        String endDate2 = endDate4.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss') + '+00:00';	
        
        Event ev =new Event();
        ev.Id = recordId;
        ev.Related_Enquiry__c = enquiryId != '' ? enquiryId : null;
        ev.StartDateTime = DateTime.valueOf(startDate2.replace('T', ' '));
        ev.EndDateTime = DateTime.valueOf(endDate2.replace('T', ' '));
        ev.Start_Date__c = Date.valueOf(startDate);
        ev.Checkin_Location__Latitude__s = lati != '' ? Decimal.valueOf(lati) : null;
        ev.Checkin_Location__Longitude__s = longi !='' ?  Decimal.valueOf(longi) : null;
        ev.Minutes_of_Meeting__c = meetingMinute;
        update ev;
        return ev.id;
    }
    public class EventList{
        @AuraEnabled 
        public string recordId{get;set;}
        @AuraEnabled 
        public string accountName{get;set;}
        @AuraEnabled 
        public String startDate{get;set;}
        @AuraEnabled 
        public String startTime{get;set;}
        @AuraEnabled 
        public String visitFor{get;set;}
        @AuraEnabled 
        public String meetingMinute{get;set;}
    }
    public class EventRecord{
        @AuraEnabled 
        public string recordId{get;set;}
        @AuraEnabled 
        public string whatName{get;set;}
        @AuraEnabled 
        public string whatId{get;set;}
        @AuraEnabled 
        public String startDate{get;set;}
        @AuraEnabled 
        public String startTime{get;set;}
        @AuraEnabled 
        public String endDate{get;set;}
        @AuraEnabled 
        public String endTime{get;set;}
        @AuraEnabled 
        public String meetingMinute{get;set;}
        @AuraEnabled 
        public String objectName{get;set;}
        @AuraEnabled 
        public String relatedEnquiryId{get;set;}
        @AuraEnabled 
        public String relatedEnquiryName{get;set;}
    }
}