@isTest
public with sharing class Int_inSettingsControllerTest {

    @isTest static void checkIsValidAccessTokenPositive() {

        String result;

        Int_TestCreateObject.createCredentials('TestToken');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('DEFAULT_BODY', 'Get', 'OK'));
        result = Int_inSettingsController.checkIsValidAccessToken('TestToken');
        Test.stopTest();

        System.assertEquals('Success', result);
        System.assertEquals(1, [SELECT Id FROM Bexio__c].size());
    }

    @isTest static void getSettingPositive() {

        Map<String, String> results = new Map<String, String>();

        Int_TestCreateObject.createCredentials('TestToken');
        Int_TestCreateObject.createBexioLog('Success');
        Int_TestCreateObject.createBatchIndex('Invoice',15);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('DEFAULT_BODY', 'Get', 'OK'));
        results = Int_inSettingsController.getSetting();
        Test.stopTest();

        System.assertEquals('success', results.get('Status'));
        System.assertEquals('Success', results.get('authorized'));
        System.assertEquals('TestToken', results.get('token'));
    }

    @isTest static void schedulerUpdatePositive() {

        String result;
        Int_TestCreateObject.createBatchIndex('Invoice',15);

        Test.startTest();
        result = Int_inSettingsController.schedulerUpdate('15');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest static void schedulerUpdateNegative() {

        String result;
        Int_TestCreateObject.createBatchIndex('Invoice', 15);

        Test.startTest();
        result = Int_inSettingsController.schedulerUpdate('not');
        Test.stopTest();

        System.assertEquals('', result);
    }

    @isTest static void syncNowPositive() {

        String result;
        Int_TestCreateObject.createBatchIndex('Invoice', 15);

        Test.startTest();
        result = Int_inSettingsController.syncNow();
        Test.stopTest();

        System.assertEquals('Success', result);
    }
}