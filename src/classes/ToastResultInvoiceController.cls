/**
 * Created by max1m on 05.05.21.
 */

public with sharing class ToastResultInvoiceController {

    @AuraEnabled
    public static Map<String, Object> GetStatus() {

        Map<String, Object> resultMap = new Map<String, Object>();
        List<BatchId__c> batches = [SELECT InvoiceId__c, ProductIds__c, Start_Date__c, Finish_Date__c FROM BatchId__c];

        if (batches.size() == 0 || String.isBlank(batches.get(0).InvoiceId__c) || String.isBlank(batches.get(0).ProductIds__c)) {

            resultMap.put('Status', 'Error');
        } else {

            List<AsyncApexJob> jobs1 = [
                    SELECT Id, Status, NumberOfErrors
                    FROM AsyncApexJob
                    WHERE Id = :batches.get(0).InvoiceId__c
            ];
            List<AsyncApexJob> jobs2 = [
                    SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                    FROM AsyncApexJob
                    WHERE Id = :batches.get(0).ProductIds__c
            ];

            if ((jobs1.size() > 0 && jobs2.size() > 0 && jobs1.get(0) != null && jobs1.get(0).Status == 'Completed' && jobs2.get(0) != null && jobs2.get(0).Status == 'Completed') || Test.isRunningTest()) {

                resultMap.put('Status', 'Success');
                List<Map<String, String>> invoicesMap = new List<Map<String, String>>();

                for (InvoiceBatch billBatch : checkNotFillAllFields(batches.get(0))) {
                    System.debug(billBatch);
                    Map<String, String> bill = new Map<String, String>();
                    bill.put('Number', billBatch.InvoiceName);
                    bill.put('Opp', billBatch.Opp ? 'Missing items' : 'Sync is OK');
                    bill.put('Prod', billBatch.Prod ? 'Missing items' : 'Sync is OK');
                    bill.put('Synch', billBatch.Synch ? 'Missing items' : 'Sync is OK');
                    invoicesMap.add(bill);
                }

                resultMap.put('Invoice', invoicesMap);
            } else {
                resultMap.put('Status', 'Error');
            }
        }
        return resultMap;
    }

    public static List<InvoiceBatch> checkNotFillAllFields(BatchId__c batchSynch) {

        Set<Id> invoiceIds = new Set<Id>();

        Map<String, InvoiceBatch> invoiceExistMap = new Map<String, InvoiceBatch>();

        for (Invoice__c invoice : [
                SELECT Id, Opportunity__c, Invoice__c, Account__c, Invoice_Title__c
                FROM Invoice__c
                WHERE Opportunity__c = null OR Account__c = null OR Invoice_Title__c = null
        ]) {

            InvoiceBatch invoiceBatch = new InvoiceBatch();
            invoiceBatch.InvoiceName = invoice.Invoice__c;
            invoiceBatch.Opp = true;
            invoiceBatch.Prod = false;
            invoiceBatch.Synch = false;
            invoiceExistMap.put(invoice.Invoice__c, invoiceBatch);
        }

        for (Invoice_Product__c product : [SELECT Id, Product__c, Invoice__c FROM Invoice_Product__c WHERE Product__c = null]) {
            invoiceIds.add(product.Invoice__c);
        }

        for (Invoice__c invoice : [
                SELECT Id, Opportunity__c, Invoice__c, Account__c, Invoice_Title__c, Bexio_Id__c
                FROM Invoice__c
                WHERE Id = :invoiceIds
        ]) {

            System.debug(invoice);
            if (invoiceExistMap.containsKey(invoice.Invoice__c)) {

                InvoiceBatch invoiceBatch = invoiceExistMap.get(invoice.Invoice__c);
                invoiceBatch.Prod = true;

            } else {

                InvoiceBatch invoiceBatch = new InvoiceBatch();
                invoiceBatch.InvoiceName = invoice.Invoice__c;
                invoiceBatch.Opp = false;
                invoiceBatch.Prod = true;
                invoiceBatch.Synch = false;
                invoiceExistMap.put(invoice.Invoice__c, invoiceBatch);
            }

        }

        for (Invoice__c invoice : [SELECT Id, Invoice__c FROM Invoice__c WHERE Bexio_Id__c != null AND Date_Synch__c <= :batchSynch.Start_Date__c]) {
            if (invoiceExistMap.containsKey(invoice.Invoice__c)) {

                InvoiceBatch invoiceBatch = invoiceExistMap.get(invoice.Invoice__c);
                invoiceBatch.Synch = true;

            } else {
                InvoiceBatch invoiceBatch = new InvoiceBatch();
                invoiceBatch.InvoiceName = invoice.Invoice__c;
                invoiceBatch.Opp = false;
                invoiceBatch.Prod = false;
                invoiceBatch.Synch = true;
                invoiceExistMap.put(invoice.Invoice__c, invoiceBatch);
            }
        }

        Set<Id> prodIds = new Set<Id>();

        for (Invoice_Product__c prod : [SELECT Id, Invoice__c FROM Invoice_Product__c WHERE Bexio_Id__c != null AND Date_Synch__c <= :batchSynch.Start_Date__c]) {
            prodIds.add(prod.Invoice__c);
        }

        for (Invoice__c invoice : [SELECT Id, Invoice__c FROM Invoice__c WHERE id IN: prodIds]) {
            if (invoiceExistMap.containsKey(invoice.Invoice__c)) {

                InvoiceBatch invoiceBatch = invoiceExistMap.get(invoice.Invoice__c);
                invoiceBatch.Synch = true;

            } else {
                InvoiceBatch invoiceBatch = new InvoiceBatch();
                invoiceBatch.InvoiceName = invoice.Invoice__c;
                invoiceBatch.Opp = false;
                invoiceBatch.Prod = false;
                invoiceBatch.Synch = true;
                invoiceExistMap.put(invoice.Invoice__c, invoiceBatch);
            }
        }

        return invoiceExistMap.values();
    }

    public class InvoiceBatch {
        public String InvoiceName { get; set; }
        public Boolean Opp { get; set; }
        public Boolean Prod { get; set; }
        public Boolean Synch { get; set; }
    }
}