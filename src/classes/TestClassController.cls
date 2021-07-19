@isTest
public class TestClassController {

    @testSetup static void setup() {

        Account acc = new Account();
        acc.Name = 'AccountUpselling';

        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'AccountTest';
        acc2.Account_Email__c = 'Account@company.com';

        insert acc2;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Hand-shake agreement';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();

        insert opp;

        Opportunity oppInCon = new Opportunity();
        oppInCon.Name = 'OppInContact';
        oppInCon.StageName = 'In contact';
        oppInCon.AccountId = acc.Id;
        oppInCon.CloseDate = Date.today();

        insert oppInCon;

        Contact con = new Contact();
        con.LastName = 'Last';
        con.Email = 'Account@company.com';
        con.AccountId = acc2.Id;
        insert con;

        Pricebook2 price = new Pricebook2();
        price.Name = 'Standard Price Book CHF';
        price.Currency__c = 'USD';
        insert price;
    }

    @isTest static void controllerTest() {

        System.assertEquals([SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book CHF' LIMIT 1].Id,
                OpportunityController.getAccount('Account@company.com').get('Price')[0]);
        System.assertEquals([SELECT Id, Name FROM Account WHERE Account_Email__c = 'Account@company.com' LIMIT 1].Id,
                OpportunityController.getAccount('Account@company.com').get('Account')[0]);

        Account acc = [SELECT Id FROM Account WHERE Name = :'AccountTest' LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'OppControl';
        opp.StageName = 'In contact';
        opp.AccountId = acc.Id;
        opp.Pricebook2Id = [SELECT Id, Currency__c FROM Pricebook2 WHERE Name = 'Standard Price Book CHF' LIMIT 1].Id;

        List<String> multiPicklist = new List<String>();
        multiPicklist.add('Other');

        String IdOpp = OpportunityController.saveOpportunity(opp, '2020-04-01', multiPicklist, 'Account@company.com');
        System.assertEquals(IdOpp, [SELECT Id FROM Opportunity WHERE Name = :'OppControl' LIMIT 1].Id);
    }
}