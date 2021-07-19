/**
 * Created by max1m on 26.02.21.
 */
@isTest
public with sharing class JobAppSendEmailControllerTest {

    @testSetup static void setup() {

        Contact cont = new Contact();
        cont.LastName = 'TestName';
        cont.FirstName = 'First';
        cont.Email = 'test@contact.com';
        insert cont;

        Position__c position = new Position__c();
        position.Status__c = 'New Position';
        position.Position_ID__c = '1234567890';
        position.Sender_email__c = 'test@position.com';
        position.Contact_for_notification__c = cont.Id;
        position.Stage_of_Job_Application__c = 'New;Contact verified;Phone interview';
        position.Rejected_Contact_verified__c = 'Test (Rejected)';
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
        job.Stage_Progress__c = 'Approved';
        insert job;
    }

    @isTest static void GetEmailTestTest() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Test','Phone interview', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(9, returnMap.size());
    }

    @isTest static void GetEmailTestNew() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'New';
            update job;
        }

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('New','Phone interview', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestContactVerified() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Contact verified';
            update job;
        }

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Contact verified','Phone interview', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestPhoneInterview() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Phone interview';
            update job;
        }

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Phone interview','Contact verified', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestFinalInterview() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Final interview';
            update job;
        }

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Final interview','Contact verified', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestHired() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Hired';
            update job;
        }

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Hired','Contact verified', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestRejectedContactVerified() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Rejected','Contact verified', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.debug(returnMap);
        System.debug(returnMap.size());
        System.assertEquals(8, returnMap.size());
    }

    @isTest static void GetEmailTestRejectedPhoneInterview() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Rejected','Phone interview', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(9, returnMap.size());
    }

    @isTest static void GetEmailTestRejectedTest() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Rejected','Test', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(9, returnMap.size());
    }

    @isTest static void GetEmailTestRejectedHired() {

        List<Job_Application__c> jobs = [SELECT Id FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        Map<String,String> returnMap = JobAppSendEmailController.GetEmail('Rejected','Hired', String.valueOf(jobs.get(0).Id));
        Test.StopTest();
        System.assertEquals(9, returnMap.size());
    }

    @isTest static void SendEmailTest() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Test', 'Body', 'Subject','test@cctest.com');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestNew() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'New';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'New', 'Body', 'Subject', '');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestContactVerified() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Contact verified';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Contact verified', 'Body', 'Subject', '');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestPhoneInterview() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Phone interview';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Phone interview', 'Body', 'Subject', '');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestFinalInterview() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Final interview';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Final interview', 'Body', 'Subject', '');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestHired() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Hired';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Hired', 'Body', 'Subject', '');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailTestRejected() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Rejected';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail(String.valueOf(jobs.get(0).Id), 'Rejected', 'Body', 'Subject','');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void schedulerTest() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c FROM Job_Application__c WHERE Picklist__c = 'Test'];

        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Rejected';
            update job;
        }

        Test.StartTest();
        String result = JobAppSendEmailController.scheduler(String.valueOf(jobs.get(0).Id), 'Rejected', 'Body', 'Subject', 'TEstName', '2021-03-12T17:00:00.789Z', '2021-03-12T18:00:00.789Z','');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void updateCandidate() {
        List<Candidate__c> candidates = [SELECT Contact__c, Last_Name__c FROM Candidate__c WHERE Email__c = 'test@test.com'];
        System.assertEquals(1,  candidates.size());
        candidates.get(0).Email__c = 'update@update.com';
        update candidates;
        List<Candidate__c> newCandidates = [SELECT Contact__c, Last_Name__c FROM Candidate__c WHERE Id =:candidates.get(0).Id];
        System.assertEquals('update@update.com', [SELECT Email FROM Contact WHERE Id =:newCandidates.get(0).Contact__c].Email);
    }

    @isTest static void SendEmailNegative() {

        Test.StartTest();
        String result = JobAppSendEmailController.SendEmail('asdfgrewqd', 'Hired', 'Body', 'Subject','');
        Test.StopTest();
        System.assertEquals('Success', result);
    }

    @isTest static void SendEmailNotificationSend() {

        List<Job_Application__c> jobs = [SELECT Id, Picklist__c  FROM Job_Application__c WHERE Picklist__c = 'Test'];
        if (jobs.size() > 0) {
            Job_Application__c job = jobs.get(0);
            job.Picklist__c = 'Rejected';
            update job;
        }
        Test.StartTest();
        update jobs;
        Test.StopTest();

    }
}