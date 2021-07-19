@isTest
public class TestOppChangeRecordType {

    private static String oppRecordTypeSales = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
    private static String oppRecordTypeOngoingBusiness = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Ongoing business').getRecordTypeId();

    @testSetup static void setup() {

        Account acc = new Account();
        acc.Name = 'AccountUpselling';

        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'AccountTest';

        insert acc2;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.RecordTypeId = oppRecordTypeSales;
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();

        insert opp;

        Opportunity oppInCon = new Opportunity();
        oppInCon.Name = 'OppInContact';
        oppInCon.RecordTypeId = oppRecordTypeSales;
        oppInCon.StageName = 'In contact';
        oppInCon.AccountId = acc.Id;
        oppInCon.CloseDate = Date.today();

        insert oppInCon;

        Pricebook2 price = new Pricebook2();
        price.Name = 'Standard Scalable Price Book CHF';
        insert price;

    }

    @isTest static void createNewOppUpsellingTest() {

        Account acc = [SELECT Id FROM Account WHERE Name = :'AccountUpselling' LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp2';
        opp.RecordTypeId = oppRecordTypeSales;
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
        opp.RecordTypeId = oppRecordTypeSales;
        opp.StageName = 'In contact';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();

        Test.StartTest();
        insert opp;
        Test.StopTest();

        System.assertEquals('New Business - client referral', [SELECT Id, Source__c FROM Opportunity WHERE Name = :'OppTest' LIMIT 1].Source__c);
        System.assertEquals(5000, [SELECT Id, Amount FROM Opportunity WHERE Name = :'OppTest' LIMIT 1].Amount);
    }

    @isTest static void changeRecordTypeOppTest() {

        Opportunity oppTest = [SELECT Id, StageName FROM Opportunity WHERE Name = :'OppInContact' LIMIT 1];
        oppTest.StageName = 'Hand-shake agreement';

        Test.StartTest();
        update oppTest;
        Test.StopTest();

        System.assertEquals(oppRecordTypeOngoingBusiness, [SELECT Id, RecordTypeId FROM Opportunity WHERE Name = :'OppInContact' LIMIT 1].RecordTypeId);
    }

    @isTest static void controllerTest() {

        Account acc = [SELECT Id FROM Account WHERE Name = :'AccountTest' LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'OppControl';
        opp.RecordTypeId = oppRecordTypeSales;
        opp.StageName = 'In contact';
        opp.AccountId = acc.Id;

        List<String> multiPicklist = new List<String>();
        multiPicklist.add('Other');

        String IdOpp = OpportunityController.saveOpportunity(opp, '2020-04-01', multiPicklist, 'test@test.com');
        System.assertEquals(IdOpp, [SELECT Id FROM Opportunity WHERE Name = :'OppControl' LIMIT 1].Id);
    }
}