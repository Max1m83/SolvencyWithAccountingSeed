/**
 * Created by max1m on 27.05.21.
 */

public with sharing class Recurring_Invoice_Batch implements Database.Batchable<Integer>, Database.Stateful, Schedulable {

    private List<Recurring_Invoice__c> invoices;
    private List<Accounting_Period__c> periods;
    private Integer chunkSize = 200;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        this.invoices = [
                SELECT Billing_City__c, Billing_Country__c, Billing_Postal_Code__c, Billing_State__c, Billing_Street__c, Discount__c, Name, With_Tax__c, Rounding_difference__c,
                        CurrencyIsoCode, Account__c, Date_create__c, DescriptionAnnex__c, Due_Date__c, Invoice_Frequency__c, Invoice_Title__c, isTax__c, Last_Invoice_Date__c,
                        Opportunity__c, (SELECT Id, Description__c, Position__c, Product__c, Quantity__c, Unit_Price__c, Discount__c FROM Recurring_Invoice_Lines__r ORDER BY Position__c ASC), (SELECT Id, Contact_group__c FROM Recurring_Billing_Contact_Groups__r)
                FROM Recurring_Invoice__c
                WHERE Next_Invoice_Date__c <= TODAY AND Status__c = 'Active'
        ];
        this.periods = [
                SELECT End_Date__c, Start_Date__c
                FROM Accounting_Period__c
                WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY
        ];
        if (this.periods.size() == 0) {
            Id periodId = Int_Invoice_Handler.createdAccountingPeriod(Date.today());
            this.periods = [
                    SELECT End_Date__c, Start_Date__c
                    FROM Accounting_Period__c
                    WHERE Id = :periodId
            ];
        }

        return Int_Utils.generateCountOfChuncks(this.invoices.size(), this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Recurring_Invoice__c> updateRecurring = new List<Recurring_Invoice__c>();
        List<Invoice_Product__c> insertProducts = new List<Invoice_Product__c>();
        List<Contacts_for_Billing__c> insertGroups = new List<Contacts_for_Billing__c>();
        Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>();

        Integer startInteger = (batchIndexes[0] - 1) * this.chunkSize + 1;
        Integer finishInteger = batchIndexes[0] * this.chunkSize > this.invoices.size() ? this.invoices.size() : batchIndexes[0] * this.chunkSize;

        for (Integer i = startInteger; i <= finishInteger; i++) {
            Recurring_Invoice__c rec = this.invoices.get(i - 1);
            rec.Last_Invoice_Date__c = Date.today();
            updateRecurring.add(rec);
        }

        invoiceMap.putAll(createInvoice(updateRecurring));

        upsert invoiceMap.values();
        insertProducts.addAll(createInvoiceProducts(updateRecurring, invoiceMap));

        upsert insertProducts;
        insertGroups.addAll(createEmailGroups(updateRecurring, invoiceMap));

        upsert insertGroups;
        createAttachments(invoiceMap);

        update updateRecurring;
    }

    public void finish(Database.BatchableContext BC) {

    }

    public void execute(SchedulableContext ctx) {
        System.scheduleBatch(new Recurring_Invoice_Batch(), 'Recurring Invoice Batch', 1, 1);
    }

    private Map<Id, Invoice__c> createInvoice(List<Recurring_Invoice__c > recurrings) {

        Map<Id, Invoice__c> returnMaps = new Map<Id, Invoice__c>();

        for (Recurring_Invoice__c recurringInvoice : recurrings) {

            Invoice__c invoice = new Invoice__c();
            if (this.periods.size() > 0) {
                invoice.Accounting_period_Invoice__c = periods.get(0).Id;
            }
            invoice.With_Tax__c = recurringInvoice.With_Tax__c;
            invoice.Rounding_difference__c = recurringInvoice.Rounding_difference__c;
            invoice.Account__c = recurringInvoice.Account__c;
            invoice.Billing_City__c = recurringInvoice.Billing_City__c;
            invoice.Billing_Country__c = recurringInvoice.Billing_Country__c;
            invoice.Billing_PostalCode__c = recurringInvoice.Billing_Postal_Code__c;
            invoice.Billing_State__c = recurringInvoice.Billing_State__c;
            invoice.Billing_Street__c = recurringInvoice.Billing_Street__c;
            invoice.CurrencyIsoCode = recurringInvoice.CurrencyIsoCode;
            invoice.Date__c = Date.today();
            invoice.DescriptionAnnex__c = recurringInvoice.DescriptionAnnex__c;
            invoice.Discount__c = recurringInvoice.Discount__c;
            invoice.Billing_Date__c = Date.today().addDays(30);
            invoice.Invoice_Status__c = 'Draft';
            invoice.Invoice_Title__c = recurringInvoice.Invoice_Title__c;
            invoice.Opportunity__c = recurringInvoice.Opportunity__c;
            invoice.Recurring_Invoice__c = recurringInvoice.Id;
            invoice.PDF_Email_Status__c = 'Unsent';
            invoice.Invoice__c = 'Recurring Invoice - ' + ' (' + recurringInvoice.Name + ')';
            invoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Draft Invoice').getRecordTypeId();
            returnMaps.put(recurringInvoice.Id, invoice);
        }


        return returnMaps;
    }

    private List<Invoice_Product__c> createInvoiceProducts(List<Recurring_Invoice__c > recurrings, Map<Id, Invoice__c> invoices) {

        List<Invoice_Product__c> insertProducts = new List<Invoice_Product__c>();

        for (Recurring_Invoice__c recurringInvoice : recurrings) {
            for (Recurring_Invoice_Line__c prod : recurringInvoice.Recurring_Invoice_Lines__r) {

                Invoice_Product__c productInvoice = new Invoice_Product__c();
                productInvoice.Invoice__c = invoices.get(recurringInvoice.Id).Id;
                productInvoice.CurrencyIsoCode = invoices.get(recurringInvoice.Id).CurrencyIsoCode;
                productInvoice.Description__c = prod.Description__c;
                productInvoice.Discount_Bexio__c = prod.Discount__c;
                productInvoice.Position__c = prod.Position__c;
                productInvoice.Product__c = prod.Product__c;
                productInvoice.Quantity__c = prod.Quantity__c;
                productInvoice.Unit_Price__c = prod.Unit_Price__c;
                insertProducts.add(productInvoice);
            }
        }

        return insertProducts;
    }

    private List<Contacts_for_Billing__c> createEmailGroups(List<Recurring_Invoice__c > recurrings, Map<Id, Invoice__c> invoices) {

        List<Contacts_for_Billing__c> insertGroups = new List<Contacts_for_Billing__c>();

        for (Recurring_Invoice__c recurringInvoice : recurrings) {
            for (Rec_Billing_Contact_Groups__c emailGroup : recurringInvoice.Recurring_Billing_Contact_Groups__r) {
                Contacts_for_Billing__c bills = new Contacts_for_Billing__c();
                bills.Contact_group__c = emailGroup.Contact_group__c;
                bills.Invoice__c = invoices.get(recurringInvoice.Id).Id;
                insertGroups.add(bills);
            }
        }

        return insertGroups;
    }

    private void createAttachments(Map<Id, Invoice__c> invoices) {

        List<Attachment> updateAttachments = new List<Attachment>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

        for (Attachment attachment : [SELECT Id, Name, Body, IsPrivate, ParentId FROM Attachment WHERE ParentId = :invoices.keySet()]) {
            Attachment attachNew = new Attachment();
            attachNew.Name = attachment.Name;
            attachNew.IsPrivate = attachment.IsPrivate;
            attachNew.ParentId = invoices.get(attachment.ParentId).Id;
            attachNew.Body = attachment.Body;
            updateAttachments.add(attachNew);
        }

        upsert updateAttachments;


        for (ContentDocumentLink CDLink : [
                SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title, ShareType
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :invoices.keySet()
        ]) {
            ContentDocumentLink newCdl = CDLink.clone();
            newCdl.LinkedEntityId = invoices.get(CDLink.LinkedEntityId).Id;
            newCdl.ShareType = 'V';
            cdlList.add(newCdl);
        }

        upsert cdlList;
    }
}