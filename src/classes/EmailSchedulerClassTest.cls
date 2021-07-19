/**
 * Created by max1m on 01.03.21.
 */
@isTest
private with sharing class EmailSchedulerClassTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static String NAME_JOB = 'Test Name';

    @testSetup static void setup() {

        Contact cont = new Contact();
        cont.LastName = 'TestName';
        cont.Email = 'test@contact.com';
        insert cont;

        Position__c position = new Position__c();
        position.Status__c = 'New Position';
        position.Position_ID__c = '1234567890';
        position.Sender_email__c = 'test@position.com';
        insert position;

        Candidate__c candidate = new Candidate__c();
        candidate.First_Name__c = 'F';
        candidate.Last_Name__c = 'Last';
        candidate.Email__c = 'test@test.com';
        insert candidate;

        Job_Application__c job = new Job_Application__c();
        job.Picklist__c = 'Test';
        job.Position__c = position.Id;
        job.Candidate__c = candidate.Id;
        insert job;
    }

    @isTest static void testScheduledJob() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        String jobName = 'Send email to Candidate Last F (' + jobs.get(0).Id + ')';

        Test.startTest();
        String result = System.schedule(jobName,
                CRON_EXP,
                new EmailScheduledClass(jobs.get(0).Id, 'Test', 'body', 'SubjectEmail', jobName, 'cctest@test.com'));
        Test.stopTest();

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :jobName
                LIMIT 1
        ];

        System.assertEquals(0, scheduleInProgress.size());
    }
}