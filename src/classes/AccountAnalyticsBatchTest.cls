/**
 * Created by max1m on 08.09.20.
 */
@isTest
public with sharing class AccountAnalyticsBatchTest {

    @testSetup static void setup() {

        List<Product2> insertProduct = new List<Product2>();
        List<PricebookEntry> insertPrice = new List<PricebookEntry>();
        List<Opportunity> insertOpport = new List<Opportunity>();
        List<Business__c> insertBusinesses = new List<Business__c>();

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

        Account acc1 = new Account (Name = 'TestParent1',
                CurrencyIsoCode = 'CHF',
                Account_Email__c = 'TestParent1@TestParent1.com');
        insert acc1;

        Account acc2 = new Account (Name = 'TestChild1.1',
                CurrencyIsoCode = 'CHF',
                ParentId = acc1.Id,
                Account_Email__c = 'TestChild11@TestChild11.com');
        insert acc2;

        Account acc3 = new Account (Name = 'TestChild1.1.1',
                CurrencyIsoCode = 'CHF',
                ParentId = acc2.Id,
                Account_Email__c = 'TestChild111@TestChild111.com');
        insert acc3;

        Account acc4 = new Account (Name = 'TestChild1.1.2',
                CurrencyIsoCode = 'CHF',
                ParentId = acc2.Id,
                Account_Email__c = 'TestChild112@TestChild112.com');
        insert acc4;

        Account acc5 = new Account (Name = 'TestChild2.1',
                CurrencyIsoCode = 'CHF',
                ParentId = acc1.Id,
                Account_Email__c = 'TestChild21@TestChild21.com');
        insert acc5;

        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Opp Test1';
        opp1.Amount = 250;
        opp1.CurrencyIsoCode = 'CHF';
        opp1.StageName = 'In contact';
        opp1.Pricebook2Id = pricebookId;
        opp1.AccountId = acc5.Id;
        opp1.Amounts_in_currency__c = 250;
        opp1.CloseDate = Date.today();

        insertOpport.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Test2';
        opp2.Amount = 300;
        opp2.Amounts_in_currency__c = 300;
        opp2.CurrencyIsoCode = 'CHF';
        opp2.StageName = 'In contact';
        opp2.Pricebook2Id = pricebookId;
        opp2.AccountId = acc5.Id;
        opp2.CloseDate = Date.today();

        insertOpport.add(opp2);

        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Opp Test3';
        opp3.Amount = 350;
        opp3.Amounts_in_currency__c = 350;
        opp3.StageName = 'In contact';
        opp3.CurrencyIsoCode = 'CHF';
        opp3.Pricebook2Id = pricebookId;
        opp3.AccountId = acc2.Id;
        opp3.CloseDate = Date.today();

        insertOpport.add(opp3);

        Opportunity opp4 = new Opportunity();
        opp4.Name = 'Opp Test4';
        opp4.Amount = 1250;
        opp4.Amounts_in_currency__c = 1250;
        opp4.CurrencyIsoCode = 'CHF';
        opp4.StageName = 'In contact';
        opp4.Pricebook2Id = pricebookId;
        opp4.AccountId = acc2.Id;
        opp4.CloseDate = Date.today();

        insertOpport.add(opp4);

        Opportunity opp5 = new Opportunity();
        opp5.Name = 'Opp Test5';
        opp5.Amount = 750;
        opp5.Amounts_in_currency__c = 750;
        opp5.CurrencyIsoCode = 'CHF';
        opp5.StageName = 'In contact';
        opp5.Pricebook2Id = pricebookId;
        opp5.AccountId = acc2.Id;
        opp5.CloseDate = Date.today();

        insertOpport.add(opp5);

        Opportunity opp6 = new Opportunity();
        opp6.Name = 'Opp Test6';
        opp6.Amount = 1750;
        opp6.Amounts_in_currency__c = 1750;
        opp6.CurrencyIsoCode = 'CHF';
        opp6.StageName = 'In contact';
        opp6.Pricebook2Id = pricebookId;
        opp6.AccountId = acc1.Id;
        opp6.CloseDate = Date.today();

        insertOpport.add(opp6);

        Opportunity opp7 = new Opportunity();
        opp7.Name = 'Opp Test7';
        opp7.Amount = 99;
        opp7.Amounts_in_currency__c = 99;
        opp7.CurrencyIsoCode = 'CHF';
        opp7.StageName = 'In contact';
        opp7.Pricebook2Id = pricebookId;
        opp7.AccountId = acc1.Id;
        opp7.CloseDate = Date.today();

        insertOpport.add(opp7);

        insert insertOpport;

        Business__c business1 = new Business__c();
        business1.Account__c = acc5.Id;
        business1.Opportunity__c = opp5.Id;
        insertBusinesses.add(business1);

        Business__c business2 = new Business__c();
        business2.Account__c = acc5.Id;
        business2.Opportunity__c = opp3.Id;
        insertBusinesses.add(business2);

        Business__c business3 = new Business__c();
        business3.Account__c = acc3.Id;
        business3.Opportunity__c = opp3.Id;
        insertBusinesses.add(business3);

        Business__c business4 = new Business__c();
        business4.Account__c = acc3.Id;
        business4.Opportunity__c = opp4.Id;
        insertBusinesses.add(business4);

        Business__c business5 = new Business__c();
        business5.Account__c = acc4.Id;
        business5.Opportunity__c = opp5.Id;
        insertBusinesses.add(business5);

        Business__c business6 = new Business__c();
        business6.Account__c = acc4.Id;
        business6.Opportunity__c = opp6.Id;
        insertBusinesses.add(business6);

        Business__c business7 = new Business__c();
        business7.Account__c = acc4.Id;
        business7.Opportunity__c = opp7.Id;
        insertBusinesses.add(business7);

        insert insertBusinesses;

        AcctSeed__Accounting_Period__c  period1 = new AcctSeed__Accounting_Period__c();

        period1.AcctSeed__Status__c = 'Closed';
        period1.Name = '2020-06';
        period1.AcctSeed__Start_Date__c = date.valueOf('2020-06-01');
        period1.AcctSeed__End_Date__c = date.valueOf('2020-06-30');

        insert period1;

        AcctSeed__Accounting_Period__c  period2 = new AcctSeed__Accounting_Period__c();

        period2.AcctSeed__Status__c = 'Closed';
        period2.Name = '2019-12';
        period2.AcctSeed__Start_Date__c = date.valueOf('2019-12-01');
        period2.AcctSeed__End_Date__c = date.valueOf('2019-12-31');

        insert period2;

        AcctSeed__Accounting_Period__c  period3 = new AcctSeed__Accounting_Period__c();

        period3.AcctSeed__Status__c = 'Closed';
        period3.Name = '2018-12';
        period3.AcctSeed__Start_Date__c = date.valueOf('2018-12-01');
        period3.AcctSeed__End_Date__c = date.valueOf('2018-12-31');

        insert period3;

        AcctSeed__Billing_Format__c format = new AcctSeed__Billing_Format__c();
        format.Name = 'Format';
        format.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        format.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductModernPDF';

        insert format;

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

        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.Name = 'Test Bank';
        glAccount.AcctSeed__Bank__c = true;
        glAccount.CurrencyIsoCode = 'CHF';
        glAccount.AcctSeed__Type__c = 'Balance Sheet';
        glAccount.AcctSeed__Sub_Type_1__c = 'Assets';
        glAccount.AcctSeed__Sub_Type_2__c = 'Cash';
        insert glAccount;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'Ledger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = format.Id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = format.Id;
        ledger.AcctSeed__Default_Billing_Format__c = format.Id;
        ledger.AcctSeed__Default_Bank_Account__c = glAccount.Id;

        insert ledger;

        AcctSeed__Billing__c invoice = new AcctSeed__Billing__c();

        invoice.AcctSeed__Ledger__c = ledger.Id;
        invoice.AcctSeed__Opportunity__c = opp1.Id;
        invoice.CurrencyIsoCode = opp1.CurrencyIsoCode;
        invoice.AcctSeed__Customer__c = opp1.AccountId;
        invoice.AcctSeed__Date__c = Date.today().addMonths(-4);
        invoice.AcctSeed__Accounting_Period__c = period1.Id;
        invoice.AcctSeed__Status__c = 'Approved';
        insert invoice;

        AcctSeed__Billing_Line__c billProduct1 = new AcctSeed__Billing_Line__c();
        billProduct1.AcctSeed__Product__c = prod1.Id;
        billProduct1.AcctSeed__Rate__c = 100;
        billProduct1.AcctSeed__Hours_Units__c = 2;
        billProduct1.TotalForPage__c = 200;
        billProduct1.AcctSeed__Billing__c = invoice.Id;
        billProduct1.AcctSeed__Revenue_GL_Account__c = glAccountWithoutBank.Id;

        insert billProduct1;

        AcctSeed__Billing_Line__c billProduct2 = new AcctSeed__Billing_Line__c();
        billProduct2.AcctSeed__Product__c = prod2.Id;
        billProduct2.AcctSeed__Rate__c = 500;
        billProduct2.AcctSeed__Hours_Units__c = 2;
        billProduct2.TotalForPage__c = 1000;
        billProduct2.AcctSeed__Billing__c = invoice.Id;
        billProduct2.AcctSeed__Revenue_GL_Account__c = glAccountWithoutBank.Id;

        insert billProduct2;
    }

    @isTest static void AccountAnalyticsBatchTestPositive() {

        Test.startTest();
        Id batchId = Database.executeBatch(new AccountAnalyticsBatch(6));
        Test.stopTest();

        System.assertEquals(1200, [
                SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c
                FROM Account
                WHERE Name = 'TestParent1'
        ].Invoice_Total__c);
        System.assertEquals(0, [
                SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c
                FROM Account
                WHERE Name = 'TestChild1.1'
        ].Invoice_Total__c);
        System.assertEquals(0, [
                SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c
                FROM Account
                WHERE Name = 'TestChild1.1.1'
        ].Invoice_Total__c);
        System.assertEquals(0, [
                SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c
                FROM Account
                WHERE Name = 'TestChild1.1.2'
        ].Invoice_Total__c);
        System.assertEquals(1200, [
                SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c
                FROM Account
                WHERE Name = 'TestChild2.1'
        ].Invoice_Total__c);
    }
}