@IsTest
public with sharing class Int_InvoiceControllerTest {
    @TestSetup
    static void setupDataInvoice() {
//        Profile pf = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
//
//        User user = new User(
//                Alias = 'usralias',
//                Email = 'theuser@email.com',
//                EmailEncodingKey = 'UTF-8',
//                LastName = 'user_lastname',
//                LanguageLocaleKey = 'en_US',
//                LocaleSidKey = 'en_US',
//                ProfileId = pf.Id,
//                TimeZoneSidKey = 'America/Los_Angeles',
//                Username = Math.random() + 'test@testuser.com',
//                CompanyName = 'the company',
//                UserRoleId = '00E28000000zqCy'
//        );

//        EmailTemplate template = new EmailTemplate(DeveloperName = 'TestEmailTemplate', TemplateType = 'custom', FolderId = UserInfo.getUserId(),
//                Name = 'TestEmailVFTemplate',
//                IsActive = true);
//        System.runAs(acc){
//            insert template;
//        }

        Account acc = new Account();
        acc.Name = 'TestNameAccount';
        acc.Account_Email__c = 'test@gmail.com';
        acc.CurrencyIsoCode = 'CHF';
        insert acc;

//        EmailTemplate template = new EmailTemplate(DeveloperName = 'TestEmailTemplate', TemplateType = 'custom', FolderId = UserInfo.getUserId(),
//                Name = 'TestEmailVFTemplate',
//                IsActive = true);
//            insert template;

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
    }

    @isTest static void GetEmailTest() {
        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'TO');
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Int_TestCreateObject.createAttachment('1.pdf', invoiceId);

        Test.StartTest();
        Map<String, String> getMap = Int_SendEmailController.GetEmail(invoiceId);
        Test.StopTest();
        System.assertEquals(getMap.get('TO'), '');
    }

    @isTest static void cancelSendEmailTest() {

        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        Int_TestCreateObject.createAttachment('1.pdf', invoiceId);

        Test.StartTest();
        Map<String, String> returnString = Int_SendEmailController.cancelSendEmail(invoiceId);
        Test.StopTest();

        System.assertEquals(returnString.get('Status'), 'Success');
    }

    @isTest static void createPDFTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.StartTest();
        String returnString = Int_SendEmailController.createPDF(invoiceId);
        Test.StopTest();

        System.assertEquals(returnString, '2021-0215');
    }

    @isTest static void previewInvoiceBexioTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));

        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.StartTest();
        Map<String, String> returnString = Int_SendEmailController.previewInvoiceBexio(invoiceId);
        Test.StopTest();

        System.assertEquals(returnString.get('Status'), 'Success');
    }

    @isTest static void previewInvoiceBexioTestNegative() {

        Test.StartTest();
        Map<String, String> returnString = Int_SendEmailController.previewInvoiceBexio('a1w1j000000ZkNBAA0');
        Test.StopTest();

        System.assertEquals(returnString.get('Status'), 'Not Invoices');
    }

    @isTest static void GetEmailTestNegative() {

        Test.StartTest();
        Map<String, String> getMap = Int_SendEmailController.GetEmail('00N1j00000AVCew');
        Test.StopTest();

        System.assertEquals(getMap.get('Template'), 'Not');
    }

    @isTest static void SendEmailTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Int_TestCreateObject.createAttachment('1.pdf', invoiceId);

        Test.StartTest();
        String returnString = Int_SendEmailController.SendEmail(invoiceId, 'Body', 'Subject');
        Test.StopTest();

        System.assertEquals(invoiceId, returnString);
    }

    @isTest static void EmailsGroupTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');

        Test.StartTest();
        Map<String, List<String>> returnString = Int_SendEmailController.getEmailsGroup(invoiceId);
        Test.StopTest();

        System.assertEquals(1, returnString.size());
    }

    @isTest static void updateBillingTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.StartTest();
        String returnString = Int_SendEmailController.updateBilling(invoiceId, new List<String>{
                'Group#1'
        });
        Test.StopTest();

        System.assertEquals('Success', returnString);
    }

    @isTest static void updateBillingTestNegative() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoicesNotApproved('1', accOpp.get('Opportunity'), accOpp.get('Account'));
        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.StartTest();
        String returnString = Int_SendEmailController.updateBilling(invoiceId, new List<String>{
                'Group#1'
        });
        Test.StopTest();

        System.debug(returnString);

        //System.assertEquals('Success', returnString);
    }

    @IsTest
    static void testSchedulerInvoices() {
        String startDay = String.valueOf(Date.today());
        String endDay = String.valueOf(Date.today().addDays(1));
        List<EmailTemplate> emailTemplates = [SELECT Id, Name FROM EmailTemplate];

        List<Account> accounts = [SELECT Id, Name, Account_Email__c FROM Account];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];

        Id invoiceId = Int_TestCreateObject.createInvoices('1', opportunities.get(0).Id, accounts.get(0).Id);

        Test.startTest();
        String returnStringOne = Int_SendEmailController.schedulerInvoices('body', 'subject', 'TestNameInvoice', startDay, endDay, accounts.get(0).Account_Email__c, emailTemplates.get(0).Name, invoiceId, 'test@gmail.com', 'testCC@gmail.com');
        System.assertNotEquals(null, returnStringOne);
        Test.stopTest();
    }

    @IsTest
    static void testSchedulerInvoicesFullDate() {
        String startDayFull = String.valueOf(Date.today()) + 'T17:00:00.789Z';
        String endDayFull = String.valueOf(Date.today().addDays(1)) + 'T17:00:00.789Z';
        List<EmailTemplate> emailTemplates = [SELECT Id, Name FROM EmailTemplate];

        List<Account> accounts = [SELECT Id, Name, Account_Email__c FROM Account];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];

        Id invoiceId = Int_TestCreateObject.createInvoices('1', opportunities.get(0).Id, accounts.get(0).Id);

        Test.startTest();
        String returnStringTwo = Int_SendEmailController.schedulerInvoices('body', 'subject', 'TestNameInvoice', startDayFull, endDayFull, accounts.get(0).Account_Email__c, emailTemplates.get(0).Name, invoiceId, 'test@gmail.com', 'testCC@gmail.com');
        System.assertNotEquals(null, returnStringTwo);
        Test.stopTest();
    }

    @IsTest
    static void testCreateSendEmailInvoice() {
        List<EmailTemplate> emailTemplates = [SELECT Id, Name FROM EmailTemplate];
        List<Account> accounts = [SELECT Id, Name, Account_Email__c FROM Account];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];

        Id invoiceId = Int_TestCreateObject.createInvoices('1', opportunities.get(0).Id, accounts.get(0).Id);

        Test.startTest();
        String result = Int_SendEmailController.createSendEmailInvoice('body', 'subject', null, emailTemplates.get(0).Name, invoiceId, 'test@gmail.com', null);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }
}