/**
 * Created by max1m on 14.10.20.
 */
@isTest
public with sharing class testTriggerBilling {
    @testSetup static void setup() {

        List<Account> insertAccount = new List<Account>();
        List<PricebookEntry> insertPrice = new List<PricebookEntry>();
        List<Product2> insertProduct = new List<Product2>();
        List<Opportunity> insertOpport = new List<Opportunity>();
        List<OpportunityLineItem> insertOpportLine = new List<OpportunityLineItem>();
        List<AcctSeed__Billing_Line__c> insertInvoiceProduct = new List<AcctSeed__Billing_Line__c>();

        Product2 prod1 = new Product2();
        prod1.Name = 'Product1';
        prod1.Product_Type__c = 'Reporting';
        prod1.CurrencyIsoCode = 'CHF';
        insertProduct.add(prod1);

        Product2 prod2 = new Product2();
        prod2.Name = 'Product2';
        prod2.Product_Type__c = 'Reporting';
        prod2.CurrencyIsoCode = 'CHF';
        insertProduct.add(prod2);

        Product2 prod3 = new Product2();
        prod3.Name = 'Product3';
        prod3.Product_Type__c = 'Reporting';
        prod3.CurrencyIsoCode = 'CHF';
        insertProduct.add(prod3);

        insert insertProduct;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice1 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod1.Id,
                UnitPrice = 1000, IsActive = true);
        insertPrice.add(standardPrice1);

        PricebookEntry standardPrice2 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                UnitPrice = 1500, IsActive = true);
        insertPrice.add(standardPrice2);

        PricebookEntry standardPrice3 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod3.Id,
                UnitPrice = 2500, IsActive = true);
        insertPrice.add(standardPrice3);

        insert insertPrice;

        Account acc1 = new Account (Name = 'TestAccount1',
                CurrencyIsoCode = 'CHF',
                Account_Email__c = 'acc1@acc1.com');
        insertAccount.add(acc1);

        Account acc2 = new Account (Name = 'TestAccount2',
                CurrencyIsoCode = 'CHF',
                Account_Email__c = 'acc2@acc2.com');
        insertAccount.add(acc2);

        Account acc3 = new Account (Name = 'TestAccount3',
                CurrencyIsoCode = 'CHF',
                Account_Email__c = 'acc3@acc3.com');
        insertAccount.add(acc3);

        insert insertAccount;

        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Opp Test1';
        opp1.Amount = 250;
        opp1.CurrencyIsoCode = 'CHF';
        opp1.StageName = 'In contact';
        opp1.Pricebook2Id = pricebookId;
        opp1.AccountId = acc1.Id;
        opp1.CloseDate = Date.today();

        insertOpport.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Test2';
        opp2.Amount = 300;
        opp2.CurrencyIsoCode = 'CHF';
        opp2.StageName = 'In contact';
        opp2.Pricebook2Id = pricebookId;
        opp2.AccountId = acc2.Id;
        opp2.CloseDate = Date.today();

        insertOpport.add(opp2);

        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Opp Test3';
        opp3.Amount = 350;
        opp3.StageName = 'In contact';
        opp3.CurrencyIsoCode = 'CHF';
        opp3.Pricebook2Id = pricebookId;
        opp3.AccountId = acc3.Id;
        opp3.CloseDate = Date.today();

        insertOpport.add(opp3);

        insert insertOpport;

        OpportunityLineItem lineItems1 = new OpportunityLineItem();
        lineItems1.Product2Id = prod1.Id;
        lineItems1.UnitPrice = 450;
        lineItems1.Quantity = 2;
        lineItems1.OpportunityId = opp1.Id;
        insertOpportLine.add(lineItems1);

        OpportunityLineItem lineItems2 = new OpportunityLineItem();
        lineItems2.Product2Id = prod2.Id;
        lineItems2.UnitPrice = 50;
        lineItems2.Quantity = 2;
        lineItems2.OpportunityId = opp1.Id;
        insertOpportLine.add(lineItems2);

        OpportunityLineItem lineItems3 = new OpportunityLineItem();
        lineItems3.Product2Id = prod3.Id;
        lineItems3.UnitPrice = 33;
        lineItems3.Quantity = 1;
        lineItems3.OpportunityId = opp2.Id;
        insertOpportLine.add(lineItems3);

        insert insertOpportLine;

        AcctSeed__Billing_Format__c format = new AcctSeed__Billing_Format__c();
        format.Name = 'Format';
        format.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        format.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductModernPDF';

        insert format;

        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.Name = 'Test Bank';
        glAccount.AcctSeed__Bank__c = true;
        glAccount.CurrencyIsoCode = 'CHF';
        glAccount.AcctSeed__Type__c = 'Balance Sheet';
        glAccount.AcctSeed__Sub_Type_1__c = 'Assets';
        glAccount.AcctSeed__Sub_Type_2__c = 'Cash';
        insert glAccount;

        AcctSeed__GL_Account__c glAccountWithoutBank = new AcctSeed__GL_Account__c();
        glAccountWithoutBank.Name = 'Test';
        glAccountWithoutBank.AcctSeed__Bank__c = false;
        glAccountWithoutBank.CurrencyIsoCode = 'CHF';
        glAccountWithoutBank.AcctSeed__Type__c = 'Balance Sheet';
        glAccountWithoutBank.AcctSeed__Sub_Type_1__c = 'Assets';
        glAccountWithoutBank.AcctSeed__Sub_Type_2__c = 'Cash';
        insert glAccountWithoutBank;

        AcctSeed__GL_Account__c glAccountWithoutBank1 = new AcctSeed__GL_Account__c();
        glAccountWithoutBank1.Name = 'Test1';
        glAccountWithoutBank1.AcctSeed__Bank__c = false;
        glAccountWithoutBank1.CurrencyIsoCode = 'CHF';
        glAccountWithoutBank1.AcctSeed__Type__c = 'Balance Sheet';
        glAccountWithoutBank1.AcctSeed__Sub_Type_1__c = 'Assets';
        glAccountWithoutBank1.AcctSeed__Sub_Type_2__c = 'Cash';
        insert glAccountWithoutBank1;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'Ledger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = format.Id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = format.Id;
        ledger.AcctSeed__Default_Billing_Format__c = format.Id;
        ledger.AcctSeed__Default_Bank_Account__c = glAccount.Id;

        insert ledger;

        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();

        period.AcctSeed__Status__c = 'Closed';
        period.Name = '2020-02';
        period.AcctSeed__Start_Date__c = date.valueOf('2020-02-01');
        period.AcctSeed__End_Date__c = date.valueOf('2020-02-29');

        insert period;

        AcctSeed__Accounting_Period__c period1 = new AcctSeed__Accounting_Period__c();

        period1.AcctSeed__Status__c = 'Closed';
        period1.Name = '2020-06';
        period1.AcctSeed__Start_Date__c = date.valueOf('2020-06-01');
        period1.AcctSeed__End_Date__c = date.valueOf('2020-06-30');

        insert period1;

        AcctSeed__Accounting_Period__c period2 = new AcctSeed__Accounting_Period__c();

        period2.AcctSeed__Status__c = 'Closed';
        period2.Name = '2019-12';
        period2.AcctSeed__Start_Date__c = date.valueOf('2019-12-01');
        period2.AcctSeed__End_Date__c = date.valueOf('2019-12-31');

        insert period2;

        AcctSeed__Accounting_Period__c period3 = new AcctSeed__Accounting_Period__c();

        period3.AcctSeed__Status__c = 'Closed';
        period3.Name = '2018-12';
        period3.AcctSeed__Start_Date__c = date.valueOf('2018-12-01');
        period3.AcctSeed__End_Date__c = date.valueOf('2018-12-31');

        insert period3;

        AcctSeed__Billing__c invoice = new AcctSeed__Billing__c();

        invoice.AcctSeed__Ledger__c = ledger.Id;
        invoice.AcctSeed__Opportunity__c = opp1.Id;
        invoice.CurrencyIsoCode = opp1.CurrencyIsoCode;
        invoice.AcctSeed__Customer__c = opp1.AccountId;
        invoice.AcctSeed__Date__c = Date.today().addMonths(-4);
        invoice.AcctSeed__Accounting_Period__c = period1.Id;
        invoice.AcctSeed__Billing_Format__c = format.Id;
        insert invoice;

        AcctSeed__Billing__c invoice1 = new AcctSeed__Billing__c();

        invoice1.AcctSeed__Ledger__c = ledger.Id;
        invoice1.AcctSeed__Opportunity__c = opp2.Id;
        invoice1.CurrencyIsoCode = opp2.CurrencyIsoCode;
        invoice1.AcctSeed__Customer__c = opp2.AccountId;
        invoice1.AcctSeed__Date__c = Date.today();
        invoice1.AcctSeed__Billing_Street__c = 'test\r\nTest';
        invoice1.AcctSeed__Accounting_Period__c = period1.Id;
        invoice1.AcctSeed__Billing_Format__c = format.Id;
        insert invoice1;

        AcctSeed__Billing_Line__c billProduct1 = new AcctSeed__Billing_Line__c();
        billProduct1.AcctSeed__Product__c = lineItems1.Product2Id;
        billProduct1.AcctSeed__Rate__c = lineItems1.UnitPrice;
        billProduct1.AcctSeed__Hours_Units__c = lineItems1.Quantity;
        billProduct1.TotalForPage__c = lineItems1.Quantity * lineItems1.UnitPrice;
        billProduct1.AcctSeed__Billing__c = invoice.Id;
        billProduct1.AcctSeed__Revenue_GL_Account__c = glAccountWithoutBank.Id;

        insertInvoiceProduct.add(billProduct1);

        AcctSeed__Billing_Line__c billProduct2 = new AcctSeed__Billing_Line__c();
        billProduct2.AcctSeed__Product__c = lineItems2.Product2Id;
        billProduct2.AcctSeed__Rate__c = lineItems2.UnitPrice;
        billProduct2.AcctSeed__Hours_Units__c = lineItems2.Quantity;
        billProduct2.TotalForPage__c = lineItems2.Quantity * lineItems2.UnitPrice;
        billProduct2.AcctSeed__Billing__c = invoice.Id;
        billProduct2.AcctSeed__Revenue_GL_Account__c = glAccountWithoutBank.Id;

        insertInvoiceProduct.add(billProduct2);

        insert insertInvoiceProduct;

    }

    @isTest static void billingInsertTestPositive() {

        AcctSeed__Ledger__c ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        Opportunity opp1 = [SELECT Id, CurrencyIsoCode, AccountId FROM Opportunity WHERE Name = 'Opp Test1'];
        AcctSeed__Accounting_Period__c period1 = [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE Name = '2020-06'];
        AcctSeed__Billing_Format__c format = [SELECT Id FROM AcctSeed__Billing_Format__c WHERE Name = 'Format'];

        AcctSeed__Billing__c invoice = new AcctSeed__Billing__c();

        invoice.AcctSeed__Ledger__c = ledger.Id;
        invoice.AcctSeed__Opportunity__c = opp1.Id;
        invoice.CurrencyIsoCode = opp1.CurrencyIsoCode;
        invoice.AcctSeed__Customer__c = opp1.AccountId;
        invoice.AcctSeed__Date__c = Date.today().addMonths(-4);
        invoice.AcctSeed__Accounting_Period__c = period1.Id;
        invoice.AcctSeed__Billing_Format__c = format.Id;

        Test.startTest();
        insert invoice;
        Test.stopTest();

        System.debug([SELECT Id, Amount, Amounts_in_currency__c, Expected_Amount_local__c, ExpectedRevenue, Amount__c FROM Opportunity WHERE Name = 'Opp Test1']);

        System.assertEquals(1000, [SELECT Id, Amounts_in_currency__c FROM Opportunity WHERE Name = 'Opp Test1'].Amounts_in_currency__c);
    }

    @isTest static void billingUpdateTestPositive() {

        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test1'];
        AcctSeed__Billing__c invoice = [SELECT Id, AcctSeed__Date__c FROM AcctSeed__Billing__c WHERE AcctSeed__Opportunity__c = :opp1.Id];
        invoice.AcctSeed__Date__c = Date.today();
        invoice.billing_number__c = '2';

        Test.startTest();
        Update invoice;
        Test.stopTest();

        System.assertEquals(1000, [SELECT Id, Amounts_in_currency__c FROM Opportunity WHERE Name = 'Opp Test1'].Amounts_in_currency__c);
    }

    @isTest static void BillingProductExtensionTest() {

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test2'];
        AcctSeed__Billing__c invoice = [
                SELECT Id
                FROM AcctSeed__Billing__c
                WHERE AcctSeed__Opportunity__c = :opp.Id
        ];

        ApexPages.StandardController stdController = new ApexPages.StandardController(invoice);
        BillingProductExtension billProd = new BillingProductExtension(stdController);

        System.assertEquals('test<br/>Test', billProd.streetValue);
    }
}