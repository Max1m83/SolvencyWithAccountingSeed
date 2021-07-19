/**
 * Created by max1m on 29.07.20.
 */

@isTest
public with sharing class TestEgnyteController {


    @testSetup static void setup() {

        Account acc = new Account();
        acc.Name = 'AccountUpselling';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.UrlClientContracts__c = 'https://www.google.com/';
        insert opp;
    }

    @isTest static void controllerTest() {

        Opportunity oppTest = [SELECT Id, UrlClientContracts__c, UrlStandardContracts__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
        Map <String, String> getMap = EgnyteController.getURL(oppTest.Id);
        System.assertEquals('https://www.google.com/', getMap.get('Client'));
    }
}