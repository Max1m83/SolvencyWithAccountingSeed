/**
 * Created by max1m on 20.05.21.
 */
@isTest
public with sharing class Int_Account_PUT_QueueableTest {

    @isTest static void accountPUTQueueablePositive() {

        Int_TestCreateObject.createCredentials('Token');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('create Account', 'POST', 'success'));

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Company_name__c = 'Company';
        acc.isBexio__c = true;
        acc.BillingStreet = '520 BillingStreet';
        acc.BillingPostalCode = '8001';
        acc.BillingCity = 'Brest';
        acc.Account_Email__c = 'test@test.com';
        acc.Phone = '+375297253679';

        Test.startTest();
        insert acc;
        Test.stopTest();

        System.assertEquals('8', [SELECT Bexio_Id__c, Company_name__c, BillingStreet, BillingPostalCode, BillingCity, Account_Email__c, Phone FROM Account].get(0).Bexio_Id__c);
    }
}