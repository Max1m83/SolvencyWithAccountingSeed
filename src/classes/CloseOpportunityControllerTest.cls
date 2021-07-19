/**
 * Created by max1m on 25.01.21.
 */
@isTest
public with sharing class CloseOpportunityControllerTest {

    @testSetup static void setup() {
        Account acc1 = new Account();
        acc1.Name = 'Account1';
        acc1.BillingStreet = 'ul. street';
        acc1.BillingCity = 'TestCity';
        acc1.BillingState = 'State';
        acc1.BillingCountry = 'Country';
        insert acc1;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc1.Id;
        opp.CloseDate = Date.today();

        insert opp;
    }

    @isTest static void closedOpportunityTest() {

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp'];

        System.assertEquals('SUCCESS', CloseOpportunityController.closedOpportunity(opp.Id, 'Price too high'));
        //System.assertEquals(5, CloseOpportunityController.setLostReasonOpportunity().size());
    }
}