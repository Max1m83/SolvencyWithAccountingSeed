/**
 * Created by max1m on 24.06.21.
 */
@isTest
public with sharing class RecordTimeControllerTest {
    @isTest static void getDatePositive() {
        Map<String, Object> resultMap = RecordTimeController.getDate(Int_TestCreateObject.oppAccountCreate().get('Opportunity'));
        System.assertEquals('Success', resultMap.get('Status'));
    }

    @isTest static void savePositive() {
        String oppId = Int_TestCreateObject.oppAccountCreate().get('Opportunity');
        Map<String, Object> resultMap = RecordTimeController.getDate(Int_TestCreateObject.oppAccountCreate().get('Opportunity'));

        Map<String, String> newRecordTime = new Map<String, String>();
        newRecordTime.put('userId', String.valueOf(resultMap.get('UserId')));
        newRecordTime.put('Id',oppId);
        newRecordTime.put('Date_of_work__c', '2021-06-21');
        newRecordTime.put('Description__c', 'Description');
        newRecordTime.put('Number_of_hours__c', '1');
        newRecordTime.put('Billable__c', 'true');

        String result = RecordTimeController.saveDate(newRecordTime);

        System.assertEquals('Success', result);
    }
}