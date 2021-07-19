/**
 * Created by max1m on 24.06.21.
 */
@isTest
public with sharing class ApprovalRejectCandidateControllerTest {

    @isTest static void approvalProcessPositiveTest() {
        String IdCandidate = Int_TestCreateObject.createCandidate('First', 'Last', 'testCandidate@test.com');
        String IdJobApp = Int_TestCreateObject.createJobApplication(IdCandidate,null,'New');

        System.assertEquals('Pending', [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: IdJobApp].Stage_Progress__c);
        Test.startTest();
        String result = ApprovalRejectCandidateController.approve(IdJobApp);
        Test.stopTest();
        System.assertEquals('Success', result);
        System.assertEquals('Approved', [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: IdJobApp].Stage_Progress__c);
    }

    @isTest static void approvalProcessNegativeTest() {

        Test.startTest();
        String result = ApprovalRejectCandidateController.approve('');
        Test.stopTest();
        System.assertEquals('Error', result);
    }

    @isTest static void rejectProcessPositiveTest() {
        String IdCandidate = Int_TestCreateObject.createCandidate('First', 'Last', 'testCandidate@test.com');
        String IdJobApp = Int_TestCreateObject.createJobApplication(IdCandidate,null,'New');
        System.assertEquals('Pending', [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: IdJobApp].Stage_Progress__c);
        Test.startTest();
        String result = ApprovalRejectCandidateController.rejected(IdJobApp);
        Test.stopTest();
        System.assertEquals('Success', result);
        System.assertEquals('Rejected', [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: IdJobApp].Stage_Progress__c);
    }

    @isTest static void rejectProcessNegativeTest() {

        Test.startTest();
        String result = ApprovalRejectCandidateController.rejected('');
        Test.stopTest();
        System.assertEquals('Error', result);
    }

    @isTest static void sendMessageApprovalTest() {

        Int_TestCreateObject.createInvoices(new List<String>{'1'});
        List<Invoice__c> invoices = [SELECT Posting_Status__c FROM Invoice__c WHERE Bexio_Id__c = '1'];
        System.assertEquals(1, invoices.size());

        Test.startTest();
        invoices.get(0).Posting_Status__c = 'Rejected';
        update invoices;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        system.assertEquals(1, invocations, 'An email should be sent');
    }

    @isTest static void sendMessageRejectTest() {

        Int_TestCreateObject.createInvoices(new List<String>{'1'});
        List<Invoice__c> invoices = [SELECT Posting_Status__c FROM Invoice__c WHERE Bexio_Id__c = '1'];
        System.assertEquals(1, invoices.size());
        invoices.get(0).Posting_Status__c = 'Rejected';
        update invoices;

        Test.startTest();
        invoices.get(0).Posting_Status__c = 'Approved';
        update invoices;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        system.assertEquals(1, invocations, 'An email should be sent');
    }

}