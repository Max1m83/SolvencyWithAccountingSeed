@isTest
public with sharing class TestInvoiceController {

    @testSetup static void setup() {

        Account acc1 = new Account();
        acc1.Name = 'Account1';
        acc1.BillingStreet = 'ul. street';
        acc1.BillingCity = 'TestCity';
        acc1.BillingState = 'State';
        acc1.BillingCountry = 'Country';
        insert acc1;

        Account acc2 = new Account();
        acc2.Name = 'AccountTest';
        acc2.Account_Email__c = 'Account@company.com';

        insert acc2;

        Ongoing_Business__c buss = new Ongoing_Business__c();
        buss.Name = 'Business Type1';
        insert buss;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc1.Id;
        opp.CloseDate = Date.today();
        opp.Ongoing_Business__c = buss.Id;

        insert opp;

        Opportunity oppInCon = new Opportunity();
        oppInCon.Name = 'OppInContact';
        oppInCon.StageName = 'In contact';
        oppInCon.AccountId = acc1.Id;
        oppInCon.CloseDate = Date.today();

        insert oppInCon;

        Business__c business1 = new Business__c();
        business1.Account__c = acc1.Id;
        business1.Opportunity__c = opp.Id;

        insert business1;

        Business__c business2 = new Business__c();
        business2.Account__c = acc2.Id;
        business2.Opportunity__c = opp.Id;

        insert business2;

        Pricebook2 price = new Pricebook2();
        price.Name = 'Standard Price Book CHF';
        price.Currency__c = 'USD';
        insert price;
    }

    @isTest static void getInvoiceOngoingTest() {

        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp'];

        Test.StartTest();
        Opportunity opportunityGet = InvoiceController.getInvoiceOngoing(opportunity.Id);
        Test.StopTest();

        System.assertEquals([SELECT Id FROM Ongoing_Business__c WHERE Name = 'Business Type1' LIMIT 1].Id,
                opportunityGet.Ongoing_Business__c);
    }

    @isTest static void getInvoiceTest() {

        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp'];

        Test.StartTest();
        Map<String, List<String>> resultMap = InvoiceController.getInvoice(opportunity.Id);
        Test.StopTest();

        System.assertEquals(opportunity.Id, resultMap.get('Opportunity').get(0));
    }

    @isTest static void SaveBillingTest() {

        Opportunity opportunity = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opp'];
        List<String> emailsGroup = new List<String>();
        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('Opportunity', opportunity.Id);
        resultMap.put('Account', 'Account1');

        Test.StartTest();
        String billId = InvoiceController.SaveBilling(resultMap, emailsGroup, new List<String>());
        Test.StopTest();
        System.assertEquals('Test', billId);
    }
}