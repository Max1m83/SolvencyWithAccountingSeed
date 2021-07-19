/**
 * Created by max1m on 13.05.21.
 */

public with sharing class Bexio_Invoice {

    @AuraEnabled
    public static Map<String, String> previewInvoiceBexio(String invoiceIds) {

        Map<String, String> returnMaps = new Map<String, String>();
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceIds];

        if (invoices.size() > 0) {
            returnMaps.put('Status', 'Success');

            if (String.isBlank(invoices.get(0).Bexio_Id__c)) {
                returnMaps.put('Status', 'Success');
                returnMaps.put('BexioId', createInvoiceOnBexioSide(invoiceIds).Bexio_Id__c);
            } else {
                returnMaps.put('Status', 'Success');
                returnMaps.put('BexioId', invoices.get(0).Bexio_Id__c);
            }

        } else {
            returnMaps.put('Status', 'Not Invoices');
        }

        return returnMaps;
    }

    private static Invoice__c createInvoiceOnBexioSide(String invoiceId) {

        Invoice__c invoice = new Invoice__c();

        List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Invoice__c, Opportunity__c, CurrencyIsoCode, PDF_Email_Status__c, Posting_Status__c FROM Invoice__c WHERE Id = :invoiceId];

        if (Test.isRunningTest() || (invoices.size() > 0 && String.isBlank(invoices.get(0).Bexio_Id__c))) {

            String result = Int_Helper_Reserved.putInvoices(invoices);
            Bexio_Billing invoiceBexio;

            if (result != null) {
                invoiceBexio = (Bexio_Billing) System.JSON.deserialize(result, Bexio_Billing.class);
            }

            if (invoiceBexio != null) {

                invoice = updateInvoices(invoiceBexio, invoiceId);
                updateInvoiceProduct(invoiceBexio, invoiceId);
            }
        }
        return invoice;
    }

    public static void updateInvoiceProduct(Bexio_Billing invoiceBexio, String invoiceId) {

        List<Invoice_Product__c> updateInvoiceProducts = new List<Invoice_Product__c>();
        Map<String, SObject> productMap = new Map<String, SObject>();

        List<Invoice_Product__c> products = [
                SELECT Id, Unit_Price__c, Total__c, Quantity__c,Bexio_Id__c, Product__r.Name, Position__c
                FROM Invoice_Product__c
                WHERE Invoice__c = :invoiceId
                ORDER BY Position__c ASC
        ];

        Integer positionInteger = 1;

        for (Invoice_Product__c prod : products) {
            productMap.put(String.valueOf(positionInteger), prod);
            positionInteger++;
        }

        for (Bexio_Billing_Position position : invoiceBexio.positions) {

            if (position.text != 'Discount' && String.isNotBlank(position.pos)) {
                Invoice_Product__c product = (Invoice_Product__c) productMap.get(position.pos);
                product.Position__c = Integer.valueOf(position.pos);
                product.Bexio_Id__c = position.id;

                updateInvoiceProducts.add(product);
            }
        }

        update updateInvoiceProducts;
    }

    private static Invoice__c updateInvoices(Bexio_Billing invoiceBexio, String invoiceId) {

        List<Invoice__c> invoices = [
                SELECT Invoice__c, Bexio_Id__c, PDF_Email_Status__c, Update_in_Bexio__c, RecordTypeId
                FROM Invoice__c
                WHERE Id = :invoiceId
        ];
        if (invoices.size() > 0) {
            Invoice__c invoiceSalesforce = invoices.get(0);
            invoiceSalesforce.Invoice__c = invoiceBexio.document_nr;
            invoiceSalesforce.Bexio_Id__c = invoiceBexio.id;
            invoiceSalesforce.Update_in_Bexio__c = datetime.now();
            invoiceSalesforce.PDF_Email_Status__c = invoiceSalesforce.PDF_Email_Status__c != null ? invoiceSalesforce.PDF_Email_Status__c : 'Unsent';
            invoiceSalesforce.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('After create').getRecordTypeId();
            //invoiceSalesforce.updateOnBexio__c = invoiceSalesforce.updateOnBexio__c ? false : true;
            update invoiceSalesforce;
            return invoiceSalesforce;
        } else {
            return null;
        }
    }

    public class Bexio_Billing {
        String id { get; set; }
        String document_nr { get; set; }
        List<Bexio_Billing_Position> positions { get; set; }
    }

    public class Bexio_Billing_Position {
        String id { get; set; }
        String text { get; set; }
        String pos { get; set; }
    }
}