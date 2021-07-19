/**
 * Created by max1m on 02.03.21.
 */
@isTest
private with sharing class StatusEmailControllerTest {

    @testSetup static void setup() {
        Email_log__c log1 = new Email_log__c();
        log1.Position__c = 'Position #1';
        log1.Email_Status__c = 'Success';
        log1.Status__c = 'Status #3';
        log1.Candidate__c = 'Candidate #3';
        log1.Sending_time__c = Datetime.now();
        insert log1;

        Email_log__c log2 = new Email_log__c();
        log2.Position__c = 'Position #1';
        log2.Email_Status__c = 'Success';
        log2.Status__c = 'Status #2';
        log2.Candidate__c = 'Candidate #2';
        log2.Sending_time__c = Datetime.now().addHours(-2);
        insert log2;
    }

    @isTest static void getEmailLogsTest() {

        Test.StartTest();
        Map<String, Object> resultMap = StatusEmailController.getEmailLogs();
        Test.StopTest();

        System.assertEquals('Success', resultMap.get('Status'));
    }
}