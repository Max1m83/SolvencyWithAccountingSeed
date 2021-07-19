@isTest
public class TestForTriggerSourceOpp {

    @testSetup static void setup() {

        Account acc = new Account();
        acc.Name = 'AccountUpselling';

        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'AccountTest';

        insert acc2;

        Pricebook2 price = new Pricebook2();
        price.Name = 'Standard Scalable Price Book CHF';
        price.Currency__c = 'CHF';
        insert price;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc.Id;
        opp.Pricebook2Id = price.Id;
        opp.CloseDate = Date.today();

        insert opp;

        Opportunity oppInCon = new Opportunity();
        oppInCon.Name = 'OppInContact';
        opp.Operations_Mode__c = 'Sales';
        oppInCon.StageName = 'In contact';
        oppInCon.AccountId = acc.Id;
        oppInCon.Pricebook2Id = price.Id;
        oppInCon.CloseDate = Date.today();

        insert oppInCon;

        Opportunity oppInCon2 = new Opportunity();
        oppInCon2.Name = 'OppInCon';
        opp.Operations_Mode__c = 'Sales';
        oppInCon2.StageName = 'In contact';
        oppInCon2.AccountId = acc.Id;
        oppInCon2.Pricebook2Id = price.Id;
        oppInCon2.CloseDate = Date.today();

        insert oppInCon2;

        Opportunity oppInCon3 = new Opportunity();
        oppInCon3.Name = 'Closed Opportunity';
        oppInCon3.StageName = 'Closed';
        oppInCon3.AccountId = acc.Id;
        oppInCon3.Pricebook2Id = price.Id;
        oppInCon3.CloseDate = Date.today();
        oppInCon3.RecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Lost Opportunity').getRecordTypeId();

        insert oppInCon3;

    }

    @isTest static void createNewOppUpsellingTest() {

        Account acc = [SELECT Id FROM Account WHERE Name = :'AccountUpselling' LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp2';
        opp.Operations_Mode__c = 'Onboarding';
        opp.StageName = 'In contact';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();

        Test.StartTest();
        insert opp;
        Test.StopTest();

        System.assertEquals('Upselling', [SELECT Id, Source__c FROM Opportunity WHERE Name = :'Test Opp2' LIMIT 1].Source__c);
        System.assertEquals(5000, [SELECT Id, Amount FROM Opportunity WHERE Name = :'Test Opp2' LIMIT 1].Amount);
    }

    @isTest static void createNewOppBusTest() {

        Account acc = [SELECT Id FROM Account WHERE Name = :'AccountTest' LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.Name = 'OppTest';
        opp.StageName = 'In contact';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();

        Test.StartTest();
        insert opp;
        Test.StopTest();

        System.assertEquals('New Business - client referral', [SELECT Id, Source__c FROM Opportunity WHERE Name = :'OppTest' LIMIT 1].Source__c);
        System.assertEquals(5000, [SELECT Id, Amount FROM Opportunity WHERE Name = :'OppTest' LIMIT 1].Amount);
    }

    @isTest static void updateOpp() {

        List<Opportunity> updateOpp = new List<Opportunity>();

        Opportunity opp = [SELECT Id, Amount, Amount__c, StageName, Operations_Mode__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];

        System.assertNotEquals(12345.33, opp.Amount);
        opp.Amount__c = 12345.33;
        opp.StageName = 'In contact';
        opp.Operations_Mode__c = 'Sales';
        updateOpp.add(opp);

        Opportunity opp2 = [SELECT Id, Amount, Amount__c, StageName FROM Opportunity WHERE Name = 'OppInContact' LIMIT 1];
        opp2.StageName = 'Hand-shake agreement';
        opp.Operations_Mode__c = 'Onboarding';
        updateOpp.add(opp2);

        Opportunity opp3 = [SELECT Id, Amount, Amount__c, StageName FROM Opportunity WHERE Name = 'OppInCon' LIMIT 1];
        opp3.StageName = 'Negotiation';
        opp.Operations_Mode__c = 'BAU';
        updateOpp.add(opp3);

        Test.StartTest();
        update updateOpp;
        Test.StopTest();

        System.assertEquals(12345.33, [SELECT Id, Amount FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1].Amount);
    }

    @isTest static void changeRecordTypeOpp() {

        Opportunity opp = [SELECT Id, RecordTypeId, StageName FROM Opportunity WHERE Name = 'Closed Opportunity' LIMIT 1];
        System.assertEquals(opp.RecordTypeId, Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Lost Opportunity').getRecordTypeId());
        opp.StageName = 'Negotiation';

        Test.StartTest();
        update opp;
        Test.StopTest();

        System.assertEquals([SELECT Id, RecordTypeId, StageName FROM Opportunity WHERE Name = 'Closed Opportunity' LIMIT 1].RecordTypeId, Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId());
    }
}