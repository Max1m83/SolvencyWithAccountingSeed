/**
 * Created by max1m on 15.03.21.
 */

public with sharing class Int_Invoice_PUT_Queueable implements Queueable, Database.AllowsCallouts {

    private List<Invoice__c> invoices;
    final private String CRUD;
    final private String BODY;
    final private String SUBJECT;
    final private String INVOICE_ID;

    public Int_Invoice_PUT_Queueable(String invoiceIds, String crud, String body, String subject) {

//        this.invoices = [SELECT Id, Invoice__c, Opportunity__c, CurrencyIsoCode, PDF_Email_Status__c, Posting_Status__c FROM Invoice__c WHERE Id = :invoiceIds];
        this.INVOICE_ID = invoiceIds;
        this.CRUD = crud;
        this.BODY = body;
        this.SUBJECT = subject;
    }

    public void execute(QueueableContext context) {

        this.invoices = [SELECT Id, Invoice__c, Opportunity__c, CurrencyIsoCode, PDF_Email_Status__c, Posting_Status__c FROM Invoice__c WHERE Id = :INVOICE_ID];

        if (this.invoices.size() > 0 && this.CRUD == 'Insert') {

            String result = Int_RequestHelper.putInvoices(this.invoices);
            Bexio_Billing invoiceBexio = (Bexio_Billing) System.JSON.deserialize(result, Bexio_Billing.class);

            if (invoiceBexio != null) {

                String numberInvoice = updateInvoices(invoiceBexio);
                updateInvoiceProduct(invoiceBexio);
                //Int_SendEmailController.SendEmailToCustomers(invoices.get(0).Id, this.BODY, this.SUBJECT, numberInvoice);
            }
        }
        if (this.invoices.size() > 0 && this.CRUD == 'Update') {

            String result = Int_RequestHelper.updateInvoices(invoices.get(0));
            if (this.invoices.size() > 1) {
                this.invoices.remove(0);
                createdQueueable(this.invoices, 'Update');
            }
        }
    }

    private void createdQueueable(List<Invoice__c> invoices, String crud) {

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Creating Queueable';
        log.Description__c = 'Step next' + '\n';
        log.Description__c = crud == 'Insert' ? 'Insert operation' + '\n' : 'Update operation' + '\n';

        Int_Invoice_PUT_Queueable toCreateInvoice = new Int_Invoice_PUT_Queueable(invoices.get(0).Id, crud, '', '');
        ID jobID = System.enqueueJob(toCreateInvoice);
        log.Description__c += jobID;
        insert log;
    }

    private void updateInvoiceProduct(Bexio_Billing invoiceBexio) {

        List<Invoice_Product__c> updateInvoiceProducts = new List<Invoice_Product__c>();
        Map<String, SObject> productMap = new Map<String, SObject>();

        List<Invoice_Product__c> products = [
                SELECT Id, Unit_Price__c, Total__c, Quantity__c,Bexio_Id__c, Product__r.Name, Position__c
                FROM Invoice_Product__c
                WHERE Invoice__c = :this.invoices.get(0).Id
                ORDER BY Position__c ASC
        ];

        for (Invoice_Product__c prod : products) {
            productMap.put(String.valueOf(prod.Position__c), prod);
        }

        for (Bexio_Billing_Position position : invoiceBexio.positions) {

            Invoice_Product__c product = (Invoice_Product__c) productMap.get(position.pos);
            product.Bexio_Id__c = position.id;

            updateInvoiceProducts.add(product);
        }

        update updateInvoiceProducts;
    }

    private String updateInvoices(Bexio_Billing invoiceBexio) {

        List<Invoice__c> invoices = [
                SELECT Invoice__c, Bexio_Id__c, PDF_Email_Status__c, Update_in_Bexio__c, Rounding_difference__c
                FROM Invoice__c
                WHERE Id = :this.invoices.get(0).Id
        ];
        if (invoices.size() > 0) {
            Invoice__c invoiceSalesforce = invoices.get(0);
            invoiceSalesforce.Invoice__c = invoiceBexio.document_nr;
            invoiceSalesforce.Bexio_Id__c = invoiceBexio.id;
            invoiceSalesforce.Update_in_Bexio__c = datetime.now();
            invoiceSalesforce.PDF_Email_Status__c = invoiceSalesforce.PDF_Email_Status__c != null ? invoiceSalesforce.PDF_Email_Status__c : 'Unsent';
            invoiceSalesforce.Rounding_difference__c = invoiceBexio.total_rounding_difference;
            //invoiceSalesforce.updateOnBexio__c = invoiceSalesforce.updateOnBexio__c ? false : true;
            update invoiceSalesforce;
            return invoiceSalesforce.Invoice__c;
        } else {
            return null;
        }
    }

    public class Bexio_Billing {
        String id { get; set; }
        String document_nr { get; set; }
        Decimal total_rounding_difference { get; set; }
        List<Bexio_Billing_Position> positions { get; set; }
    }

    public class Bexio_Billing_Position {
        String id { get; set; }
        String text { get; set; }
        String pos { get; set; }
    }
}