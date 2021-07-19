public with sharing class Int_TestCreateObject {

    public static void createCredentials(String token) {

        insert new Bexio__c(Token__c = token);
    }

    public static void createBexioLog(String status) {

        insert new Bexio_Log__c(Status__c = status);
    }

    public static void createBatchIndex(String nameObject, Integer minutes) {

        insert new BatchIndex__c(Object__c = nameObject, isActive__c = true, Chunk_Size__c = 200, Sync_Interval_Minutes__c = 5, Next_Batch_Date__c = Datetime.now().addMinutes(minutes));
        insert new BatchId__c (isWork__c = true);
    }

    public static String createRecurringInvoice(Date nextDate) {

        Map<String, String> accOpp = oppAccountCreate();
        Recurring_Invoice__c recurringBilling = new Recurring_Invoice__c();
        recurringBilling.Opportunity__c = accOpp.get('Opportunity');
        recurringBilling.Invoice_Frequency__c = 'Quarterly';
        recurringBilling.Name = 'Recurring Invoice #1';
        recurringBilling.Account__c = accOpp.get('Account');
        recurringBilling.Status__c = 'Active';
        recurringBilling.Rounding_difference__c = -0.01;
        recurringBilling.Next_Invoice_Date__c = nextDate;
        insert recurringBilling;

        Recurring_Invoice_Line__c billRecurringProduct = new Recurring_Invoice_Line__c();
        billRecurringProduct.Product__c = createProducts(1).get(0).Id;
        billRecurringProduct.Recurring_Invoice__c = recurringBilling.Id;
        billRecurringProduct.Quantity__c = 1;
        billRecurringProduct.Unit_Price__c = 22;
        billRecurringProduct.Description__c = 'Description';
        billRecurringProduct.Discount__c = 1.02;
        billRecurringProduct.Position__c = 1;
        insert billRecurringProduct;

        return recurringBilling.Id;
    }

    public static void createAccounts(List<String> bexioIds) {

        List<Account> insertAccounts = new List<Account>();
        Integer count = 1;

        for (String bexioId : bexioIds) {

            Account acc = new Account();
            acc.Name = 'TestAccount' + count;
            acc.Bexio_Id__c = bexioId;
            acc.isBexio__c = true;
            acc.Account_Email__c = 'test' + count + '@test.com';
            insertAccounts.add(acc);
            count++;
        }

        insert insertAccounts;
    }

    public static Map<String, String> oppAccountCreate() {

        Map<String, String> returnMap = new Map<String, String>();
        returnMap.put('Account', accountCreate());

        Opportunity oppInCon = new Opportunity();
        oppInCon.Name = 'OppInContact';
        oppInCon.StageName = 'In contact';
        oppInCon.AccountId = returnMap.get('Account');
        oppInCon.CloseDate = Date.today();

        Schema.DescribeFieldResult fieldResult = Opportunity.Email_Template_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        if (ple.size() > 0) {
            oppInCon.Email_Template_Name__c = ple.get(0).getLabel();
        }

        insert oppInCon;
        returnMap.put('Opportunity', oppInCon.Id);
        return returnMap;
    }

    public static String accountCreate() {

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Bexio_Id__c = '2';

        insert acc;

        return acc.Id;
    }

    public static String createContact() {

        Contact contact = new Contact();
        contact.Email = Integer.valueOf((Math.random() * 1000)) + 'test@test.com';
        contact.LastName = 'Contact';
        insert contact;
        return contact.Id;
    }

    public static String createContentVersion(String IdRec) {

        ContentVersion content = new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = IdRec;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id = :content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        return 'Success';
    }

    public static void contactBilling(String conId, String invoiceId, String status) {
        Contact_group__c group1 = new Contact_group__c();
        group1.Name = 'Group#1';
        insert group1;

        Contact_entity__c con1 = new Contact_entity__c();
        con1.Contact__c = conId;
        con1.Recipient__c = status;
        con1.Contact_group__c = group1.Id;
        insert con1;

        Contacts_for_Billing__c billCont = new Contacts_for_Billing__c();
        billCont.Invoice__c = invoiceId;
        billCont.Contact_group__c = group1.Id;
        insert billCont;

    }

    public static String createInvoices(String bexioIds, String OppIds, String AccountId) {

        Invoice__c invoice = new Invoice__c();
        invoice.Bexio_Id__c = bexioIds;
        invoice.getPositions__c = false;
        invoice.Accounting_period_Invoice__c = createAccountingPeriod();
        invoice.Posting_Status__c = 'Approved';
        invoice.Bexio_Name__c = 'Test Invoice';
        invoice.Account__c = AccountId;
        invoice.Opportunity__c = OppIds;
        invoice.Date__c = Date.today();
        invoice.Invoice__c = bexioIds;

        insert invoice;
        return invoice.Id;
    }

    public static String createAccountingPeriod() {
        Accounting_Period__c period = new Accounting_Period__c();
        period.Name = '2022-01';
        period.Status__c = 'Open';
        period.Start_Date__c = Date.today().toStartOfMonth();
        period.End_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);

        insert period;
        return period.Id;
    }

    public static String createInvoicesNotApproved(String bexioIds, String OppIds, String AccountId) {

        Invoice__c invoice = new Invoice__c();
        invoice.Bexio_Id__c = bexioIds;
        invoice.getPositions__c = false;
        invoice.Posting_Status__c = 'In Process';
        invoice.Bexio_Name__c = 'Test Invoice';
        invoice.Account__c = AccountId;
        invoice.Opportunity__c = OppIds;
        invoice.Date__c = Date.today();

        insert invoice;
        return invoice.Id;
    }

    public static void createInvoices(List<String> bexioIds) {

        List<Invoice__c> insertInvoices = new List<Invoice__c>();
        Integer count = 1;

        for (String bexioId : bexioIds) {

            Invoice__c invoice = new Invoice__c();
            invoice.Bexio_Id__c = bexioId;
            invoice.Posting_Status__c = 'Approved';
            invoice.Bexio_Name__c = 'Test Invoice' + count;
            invoice.getPositions__c = false;
            invoice.Invoice_Status__c = 'Paid';
            invoice.Date__c = Date.today();
            insertInvoices.add(invoice);
            count++;
        }

        insert insertInvoices;
    }

    public static List<Product2> createProducts(Integer countProducts) {

        List<Product2> returnProducts = new List<Product2>();

        for (Integer i = 1; i <= countProducts; i++) {
            Product2 prod1 = new Product2();
            prod1.Name = 'Product #' + i;
            prod1.Product_Type__c = 'Reporting';
            prod1.CurrencyIsoCode = 'CHF';
            returnProducts.add(prod1);
        }

        insert returnProducts;
        return returnProducts;
    }

    public static void createInvoicesProduct(String bexioIds, List<Product2> products) {

        List<Invoice__c> insertInvoices = [SELECT Id FROM Invoice__c WHERE Bexio_Id__c = :bexioIds];
        List<Invoice_Product__c> insertProd = new List<Invoice_Product__c>();

        if (insertInvoices.size() > 0) {
            for (Product2 product : products) {

                Invoice_Product__c prod = new Invoice_Product__c();
                prod.Product__c = product.Id;
                prod.Invoice__c = insertInvoices.get(0).Id;
                prod.Quantity__c = 1;
                prod.Unit_Price__c = 2;
                insertProd.add(prod);
            }

            insert insertProd;
        }
    }

    public static void createAttachment(String nameAttachment, String parentId) {

        Attachment att = new Attachment();
        att.Name = nameAttachment;
        att.IsPrivate = false;
        att.ParentId = parentId;
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        insert att;
    }

    public static String createBatchId(String InvoiceId, String ProductIds, Datetime startTime, Datetime finishTime) {

        BatchId__c batch = new BatchId__c(InvoiceId__c = InvoiceId,
                ProductIds__c = ProductIds,
                Start_Date__c = startTime,
                Finish_Date__c = finishTime);
        insert batch;

        return batch.Id;
    }

    public static void createInvoicesItemsWithoutProduct(String bexioIds, List<String> products) {

        List<Invoice__c> insertInvoices = [SELECT Id FROM Invoice__c WHERE Bexio_Id__c = :bexioIds];
        List<Invoice_Product__c> insertProd = new List<Invoice_Product__c>();

        if (insertInvoices.size() > 0) {
            Integer count = 1;
            for (String product : products) {

                Invoice_Product__c prod = new Invoice_Product__c();
                prod.Position__c = count;
                prod.Product_Description__c = product;
                prod.Invoice__c = insertInvoices.get(0).Id;
                prod.Quantity__c = 1;
                prod.Unit_Price__c = 2;
                count++;
                insertProd.add(prod);
            }

            insert insertProd;
        }
    }

    public static void createInvoicesWithoutDateSynch(String bexioIds, Datetime dateSynch) {

        Invoice__c invoice = new Invoice__c();
        invoice.Bexio_Id__c = bexioIds;
        invoice.getPositions__c = false;
        invoice.Posting_Status__c = 'In Process';
        invoice.Date_Synch__c = dateSynch;
        invoice.Bexio_Name__c = 'Test Invoice';
        invoice.Date__c = Date.today();

        insert invoice;
    }

    public static String createReminderEmail(String name, String AccountId, String status, String InvoiceId, String settingsReminderEmailId) {

        Reminder_email__c newReminder = new Reminder_email__c();
        newReminder.Account__c = AccountId;
        newReminder.CurrencyIsoCode = [SELECT CurrencyIsoCode FROM Invoice__c WHERE Id = :InvoiceId].CurrencyIsoCode;
        newReminder.Date_create__c = Datetime.now();
        newReminder.Invoice__c = InvoiceId;
        newReminder.isCancel__c = false;
        newReminder.Reminder_Stage__c = status;
        newReminder.Name = name;
        newReminder.Picture_Status__c = 'Overdue';
        newReminder.Settings_Reminder_email__c = settingsReminderEmailId;
        newReminder.Status__c = 'Unsent';

        insert newReminder;
        return newReminder.Id;
    }

    public static String createSettingsReminderEmail(Integer days1, Integer days2, Integer days3, String Stage1, String Stage2, String Stage3) {

        Settings_Reminder_email__c setting = new Settings_Reminder_email__c();
        setting.Name = 'Test Settings';
        setting.Days_to_stage_1__c = days1;
        setting.Days_to_stage_2__c = days2;
        setting.Days_to_stage_3__c = days3;
        setting.Stage_1__c = Stage1;
        setting.Stage_2__c = Stage2;
        setting.Stage_3__c = Stage3;

        insert setting;
        return setting.Id;
    }

    public static String createCandidate(String firstName, String LastName, String emails) {

        Candidate__c candidate = new Candidate__c(First_Name__c = firstName,
                                                    Last_Name__c = LastName,
                                                    Email__c = emails);
        insert candidate;
        return candidate.Id;
    }

    public static String createPosition(String namePosition, String positionId, String isActive) {
        Position__c pos = new Position__c(Name = namePosition, Position_ID__c = positionId, Active__c = isActive == 'true' ? true : false);
        insert pos;
        return pos.Id;
    }

    public static String createJobApplication(String IdCandidate, String IdPosition, String status) {

        Job_Application__c job = new Job_Application__c(Candidate__c = IdCandidate,
                Position__c = IdPosition,
                Picklist__c = status);
        insert job;
        return job.Id;
    }

    public static String createInvoiceDefault(String bexioIds, String OppIds, String AccountId, String postings, String bexioName, Date dateCreate) {

        Invoice__c invoice = new Invoice__c();
        invoice.Bexio_Id__c = bexioIds;
        invoice.getPositions__c = false;
        invoice.Accounting_period_Invoice__c = createAccountingPeriod();
        invoice.Posting_Status__c = postings;
        invoice.Bexio_Name__c = bexioName;
        invoice.Account__c = AccountId;
        invoice.Opportunity__c = OppIds;
        invoice.Date__c = dateCreate;
        invoice.Invoice__c = bexioIds;

        insert invoice;
        return invoice.Id;
    }
}