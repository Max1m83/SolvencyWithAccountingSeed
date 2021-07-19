/**
 * Created by max1m on 28.06.21.
 */
@isTest
public with sharing class ReminderBatchTest {

    @isTest static void getEmailTest() {

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Reminder Email Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        Date dateCreate = Date.today().addDays(-50);
        String invoiceId = Int_TestCreateObject.createInvoiceDefault('1', oppAcc.get('Opportunity'), oppAcc.get('Account'), 'Approved', 'Test Invoice', dateCreate);
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 10, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        List<Reminder_email__c> reminderEmails = [SELECT Last_change_date_of_stage__c, Count_days__c, Picture_Status__c FROM Reminder_email__c WHERE Id = :remainderId];

        reminderEmails.get(0).Last_change_date_of_stage__c = Date.today().addDays(-11);
        reminderEmails.get(0).Picture_Status__c = 'Sent (Stage 2)';

        Test.StartTest();
        update reminderEmails;
        Id batchId = Database.executeBatch(new ReminderBatch());
        Test.StopTest();


        System.assertEquals(11, [SELECT Count_days__c FROM Reminder_email__c WHERE Id = :remainderId].Count_days__c);
        System.assertEquals('Stage 3', [SELECT Picture_Status__c FROM Reminder_email__c WHERE Id = :remainderId].Picture_Status__c);
        System.assertEquals(20, [SELECT Overdue_days__c FROM Reminder_email__c WHERE Id = :remainderId].Overdue_days__c);
    }
}