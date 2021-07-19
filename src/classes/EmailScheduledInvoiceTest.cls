@IsTest
private class EmailScheduledInvoiceTest {
    @TestSetup static void setupData() {
        Account acc = new Account();
        acc.Name = 'TestNameAccount';
        acc.Account_Email__c = 'test@gmail.com';
        acc.CurrencyIsoCode = 'CHF';
        insert acc;

        Pricebook2 pricebook2 = new Pricebook2();
        pricebook2.Name = 'TestPricebook2';
        pricebook2.Currency__c = 'CHF';
        insert pricebook2;

        Opportunity opp = new Opportunity();
        opp.Pricebook2Id = pricebook2.Id;
        opp.Name = 'TestNameOpportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Won';
        opp.Activity_Status__c = 'Active';
        opp.CloseDate = Date.today();
        opp.CurrencyIsoCode = '';
        opp.Invoice_approval_required__c = true;
        insert opp;

        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = acc.Id;
        invoice.Date__c = Date.today();
        invoice.Opportunity__c = opp.Id;
        insert invoice;
    }

    @IsTest
    static void testScheduledInvoice() {
        String CRON_EXP = '0 0 0 15 3 ? 2023';
        List<Account> accounts = [SELECT Id, Name, Account_Email__c FROM Account];
        List<Invoice__c> invoices = [SELECT Id FROM Invoice__c];
        String jobName = 'Send an email for the ' + accounts.get(0).Name + 'account';

        Test.startTest();
        String result = System.schedule(jobName,
                CRON_EXP,
                new EmailScheduledInvoice('body', 'subject', jobName, accounts.get(0).Account_Email__c, 'Email with Invoice EN', invoices.get(0).Id, 'testEmailsCC@gmail.com',  'testEmailsTO@gmail.com'));
        Test.stopTest();

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :jobName
                LIMIT 1
        ];

        System.assertEquals(0, scheduleInProgress.size());
    }
}