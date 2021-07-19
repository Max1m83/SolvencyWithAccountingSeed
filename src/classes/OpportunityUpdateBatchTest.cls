/**
 * Created by max1m on 10.08.20.
 */
@isTest
public with sharing class OpportunityUpdateBatchTest {

    @testSetup static void setup() {

        List<Account> insertAccount = new List<Account>();
        List<PricebookEntry> insertPrice = new List<PricebookEntry>();
        List<Product2> insertProduct = new List<Product2>();
        List<Opportunity> insertOpport = new List<Opportunity>();
        List<OpportunityLineItem> insertOpportLine = new List<OpportunityLineItem>();
        List<Invoice_Product__c> insertInvoiceProduct = new List<Invoice_Product__c>();

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

        Accounting_Period__c period = new Accounting_Period__c();
        period.Status__c = 'Closed';
        period.Name = '2020-02';
        period.Start_Date__c = date.valueOf('2020-02-01');
        period.End_Date__c = date.valueOf('2020-02-29');

        insert period;

        Accounting_Period__c period1 = new Accounting_Period__c();
        period1.Status__c = 'Closed';
        period1.Name = '2020-06';
        period1.Start_Date__c = date.valueOf('2020-06-01');
        period1.End_Date__c = date.valueOf('2020-06-30');

        insert period1;

        Accounting_Period__c period2 = new Accounting_Period__c();

        period2.Status__c = 'Open';
        period2.Name = '2021-03';
        period2.Start_Date__c = date.valueOf('2021-03-01');
        period2.End_Date__c = date.valueOf('2021-03-31');

        insert period2;

        Accounting_Period__c period3 = new Accounting_Period__c();

        period3.Status__c = 'Closed';
        period3.Name = '2018-12';
        period3.Start_Date__c = date.valueOf('2018-12-01');
        period3.End_Date__c = date.valueOf('2018-12-31');

        insert period3;

        Invoice__c invoice = new Invoice__c();

        invoice.Opportunity__c = opp1.Id;
        invoice.CurrencyIsoCode = opp1.CurrencyIsoCode;
        invoice.Account__c = opp1.AccountId;
        invoice.Date__c = Date.today().addMonths(-4).addDays(-1);
        invoice.Accounting_period_Invoice__c = period1.Id;
        insert invoice;

        Invoice__c invoice1 = new Invoice__c();

        invoice1.Opportunity__c = opp2.Id;
        invoice1.CurrencyIsoCode = opp2.CurrencyIsoCode;
        invoice1.Account__c = opp2.AccountId;
        invoice1.Date__c = Date.today();
        invoice1.Discount__c = 25;
        invoice1.Accounting_period_Invoice__c = period2.Id;
        insert invoice1;

        Invoice_Product__c billProduct1 = new Invoice_Product__c();
        billProduct1.Product__c = lineItems1.Product2Id;
        billProduct1.Unit_Price__c = lineItems1.UnitPrice;
        billProduct1.Quantity__c = 7;
        billProduct1.Invoice__c = invoice.Id;

        insertInvoiceProduct.add(billProduct1);

        Invoice_Product__c billProduct2 = new Invoice_Product__c();
        billProduct2.Product__c = lineItems2.Product2Id;
        billProduct2.Unit_Price__c = lineItems2.UnitPrice;
        billProduct2.Quantity__c = 5;
        billProduct2.Invoice__c = invoice.Id;

        insertInvoiceProduct.add(billProduct2);

        Invoice_Product__c billProduct3 = new Invoice_Product__c();
        billProduct3.Product__c = lineItems2.Product2Id;
        billProduct3.Unit_Price__c = 1000;
        billProduct3.Quantity__c = 5;
        billProduct3.Invoice__c = invoice1.Id;

        insertInvoiceProduct.add(billProduct3);
        insert insertInvoiceProduct;

    }

    @isTest static void OpportunityUpdateBatchTestPositive() {

        Test.startTest();
        Id batchId = Database.executeBatch(new OpportunityUpdateBatch());
        Test.stopTest();

        System.assertEquals(0, [
                SELECT Sum_amounts_quar__c
                FROM Opportunity
                WHERE Name = 'Opp Test2'
        ].Sum_amounts_quar__c);

        System.assertEquals(0, [
                SELECT Last12_months_invoiced__c
                FROM Opportunity
                WHERE Name = 'Opp Test1'
        ].Last12_months_invoiced__c);
    }
}