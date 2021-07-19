public with sharing class CloneInvoiceController {

    @AuraEnabled
    public static String cloneInvoice(String invoiceIds) {

        List<Invoice__c> invoices = [
                SELECT Account__c, Opportunity__c, Billing_City__c, Billing_Comment__c, Billing_Country__c, Billing_PostalCode__c, Billing_State__c, Bexio_Id__c,
                        Accounting_period_Invoice__c, PDF_Format_Invoice__c, PDF_Email_Status__c, Billing_Street__c, Date__c, DescriptionAnnex__c, Billing_Date__c,
                        Invoice__c, Invoice_Status__c, Invoice_Title__c, CurrencyIsoCode, (
                        SELECT Description__c, Invoice__c, Position__c, Product__c, Quantity__c, Product_Description__c, CurrencyIsoCode,
                                Unit_Price__c
                        FROM Invoice_Products__r
                ), (SELECT Id, Contact_group__c FROM Invoice_Contact_Groups_Billing__r)
                FROM Invoice__c
                WHERE Id = :invoiceIds
        ];

        if (invoices.size() > 0) {
            return cloneInvoice(invoices.get(0));
        } else {
            return 'Not Invoice';
        }
    }

    private static String cloneInvoice(Invoice__c invoice) {

        Invoice__c newInvoice = new Invoice__c();
        String periodId = findAccountingPeriod();

        if (periodId != null) {
            newInvoice.Account__c = invoice.Account__c;
            newInvoice.CurrencyIsoCode = invoice.CurrencyIsoCode;
            newInvoice.Opportunity__c = invoice.Opportunity__c;
            newInvoice.Billing_City__c = invoice.Billing_City__c;
            newInvoice.Billing_Comment__c = invoice.Billing_Comment__c;
            newInvoice.Billing_Country__c = invoice.Billing_Country__c;
            newInvoice.Billing_PostalCode__c = invoice.Billing_PostalCode__c;
            newInvoice.Accounting_period_Invoice__c = periodId;
            newInvoice.PDF_Format_Invoice__c = invoice.PDF_Format_Invoice__c;
            newInvoice.PDF_Email_Status__c = 'Unsent';
            newInvoice.Billing_Street__c = invoice.Billing_Street__c;
            newInvoice.Date__c = Date.today();
            newInvoice.DescriptionAnnex__c = invoice.DescriptionAnnex__c;
            newInvoice.Invoice__c = String.isNotBlank(invoice.Bexio_Id__c) ? 'Clone - ' + invoice.Invoice__c : 'Clone';
            newInvoice.Invoice_Status__c = 'Draft';
            newInvoice.Invoice_Title__c = invoice.Invoice_Title__c;
            insert newInvoice;

            cloneInvoiceProducts(invoice, newInvoice.Id);
            cloneContactGroups(invoice, newInvoice.Id);
            return newInvoice.Id;
        } else {
            return 'not Period';
        }
    }

    private static String findAccountingPeriod() {
        List<Accounting_Period__c> period = [
                SELECT Id, Start_Date__c, Name
                FROM Accounting_Period__c
                WHERE Start_Date__c <= :Date.today() AND End_Date__c >= :Date.today()
        ];
        if (period.size() > 0) {
            return period.get(0).Id;
        } else {
            return null;
        }
    }

    private static void cloneInvoiceProducts(Invoice__c invoice, Id invoiceId) {

        List<Invoice_Product__c> products = new List<Invoice_Product__c>();
        for (Invoice_Product__c existProduct : invoice.Invoice_Products__r) {

            Invoice_Product__c newProduct = new Invoice_Product__c();
            newProduct.Description__c = existProduct.Description__c;
            newProduct.CurrencyIsoCode = existProduct.CurrencyIsoCode;
            newProduct.Invoice__c = invoiceId;
            newProduct.Position__c = existProduct.Position__c;
            newProduct.Product__c = existProduct.Product__c;
            newProduct.Product_Description__c = existProduct.Product_Description__c;
            newProduct.Quantity__c = existProduct.Quantity__c ;
            newProduct.Unit_Price__c = existProduct.Unit_Price__c;

            products.add(newProduct);
        }

        insert products;
    }

    private static void cloneContactGroups(Invoice__c invoice, Id invoiceId) {

        List<Contacts_for_Billing__c> groups = new List<Contacts_for_Billing__c>();
        for (Contacts_for_Billing__c existGroups : invoice.Invoice_Contact_Groups_Billing__r) {

            Contacts_for_Billing__c invoiceGroup = new Contacts_for_Billing__c();
            invoiceGroup.Invoice__c = invoiceId;
            invoiceGroup.Contact_group__c = existGroups.Contact_group__c;

            groups.add(invoiceGroup);
        }

        insert groups;
    }
}