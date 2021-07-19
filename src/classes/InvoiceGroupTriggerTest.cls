/**
 * Created by max1m on 22.12.20.
 */
@isTest
public with sharing class InvoiceGroupTriggerTest {

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
                UnitPrice = 500, IsActive = true);
        insertPrice.add(standardPrice2);

        insert insertPrice;

        Account acc1 = new Account (Name = 'TestAccount1',
                CurrencyIsoCode = 'CHF',
                Account_Email__c = 'acc1@acc1.com');
        insertAccount.add(acc1);

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

        AcctSeed__Billing__c invoice = new AcctSeed__Billing__c();

        invoice.AcctSeed__Ledger__c = ledger.Id;
        invoice.AcctSeed__Opportunity__c = opp1.Id;
        invoice.CurrencyIsoCode = opp1.CurrencyIsoCode;
        invoice.AcctSeed__Customer__c = opp1.AccountId;
        invoice.AcctSeed__Date__c = Date.today().addMonths(-4);
        invoice.AcctSeed__Accounting_Period__c = period.Id;
        invoice.AcctSeed__Billing_Format__c = format.Id;
        insert invoice;

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

        Contact contact = new Contact();
        contact.Email = 'test@test.com';
        contact.LastName = 'Contact';
        insert contact;

        Contact_group__c groups = new Contact_group__c();
        groups.Name = 'Group Test';
        insert groups;

        Contact_entity__c con = new Contact_entity__c();
        con.Contact__c = contact.Id;
        con.Contact_group__c = groups.Id;
        insert con;
    }

    @isTest static void contactBillingInsertDeleteTestPositive() {

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test1'];
        AcctSeed__Billing__c bill = [SELECT Id FROM AcctSeed__Billing__c WHERE AcctSeed__Opportunity__c = :opp.Id];
        Contact_group__c groups = [SELECT Id FROM Contact_group__c WHERE Name = 'Group Test'];

        Contacts_for_Billing__c billCont = new Contacts_for_Billing__c();
        billCont.Billing__c = bill.Id;
        billCont.Contact_group__c = groups.Id;
        insert billCont;

        System.assertEquals(billCont.Id, [SELECT Id, Invoice_Contact_Groups__c FROM Send_to_Contact__c WHERE Billing__c = :bill.Id LIMIT 1].Invoice_Contact_Groups__c);

        Test.StartTest();
        delete billCont;
        Test.StopTest();

        List<Send_to_Contact__c> sendCon = [SELECT Id, Invoice_Contact_Groups__c FROM Send_to_Contact__c WHERE Billing__c = :bill.Id];

        System.assertEquals(0, sendCon.size());
    }

}