/**
 * Created by max1m on 14.06.21.
 */

public with sharing class RecordTimeController {

    @AuraEnabled
    public static Map<String, Object> getDate(String oppId) {
        return getDefaultDate (oppId);
    }

    @AuraEnabled
    public static String saveDate(Map<String, String> opportunity) {
        return createRecordTime(opportunity);
    }

    private static Map<String, Object> getDefaultDate(String oppId) {

        Map<String, Object> defaultMap = new Map<String, Object>();
        List<Opportunity> opps = [SELECT OwnerId, Name FROM Opportunity WHERE Id = :oppId];

        if (opps.size() > 0) {
            defaultMap.put('Status', 'Success');
            defaultMap.put('UserId', UserInfo.getUserId());
            defaultMap.put('Opportunity', String.isNotBlank(opps.get(0).Name) ? opps.get(0).Name : 'Without Name');
            defaultMap.put('IdOpp', opps.get(0).Id);
        } else {
            defaultMap.put('Status', 'Error');
        }
        return defaultMap;
    }

    private static String createRecordTime(Map<String, String> opportunity) {

        List<Opportunity> opps = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :opportunity.get('Id')
        ];

        if (opps.size() > 0) {
            Opportunity updateOpp = opps.get(0);
            Record_Time__c times = new Record_Time__c();
            times.Person__c = String.isNotBlank(opportunity.get('userId')) ? opportunity.get('userId') : UserInfo.getUserId();
            times.Date_of_work__c = String.isNotBlank(opportunity.get('Date_of_work__c')) ? Date.valueOf(opportunity.get('Date_of_work__c')) : null;
            times.Number_of_hours__c = String.isNotBlank(opportunity.get('Number_of_hours__c')) ? Decimal.valueOf(opportunity.get('Number_of_hours__c')) : 0;
            times.Description__c = String.isNotBlank(opportunity.get('Description__c')) ? opportunity.get('Description__c') : '';
            times.Billable__c = String.isNotBlank(opportunity.get('Billable__c')) ? (opportunity.get('Billable__c') == 'true' ? true : false) : false;
            times.Kind_of_work__c = opportunity.get('Kind_of_work__c');
            times.Opportunity__c = updateOpp.Id;

            insert times;
            return 'Success';
        } else {
            return 'Error';
        }
    }
}