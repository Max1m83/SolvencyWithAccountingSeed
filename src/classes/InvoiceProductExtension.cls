public with sharing class InvoiceProductExtension {

    private final Id billId;

    public String streetValue { get; set; }
    public List<Invoice_Product__c> billLines { get; set; }


    public InvoiceProductExtension(ApexPages.StandardController stdController) {

        billId = stdController.getId();

        List<Invoice__c> invoices = [
                SELECT Id,Billing_Street__c, Invoice__c,
                (SELECT Id, Description__c, Unit_Price__c, Quantity__c, Sub_Total__c, Product__r.Name FROM Invoice_Products__r)
                FROM Invoice__c
                WHERE Id = :billId
                LIMIT 1
        ];

        System.debug(invoices);

        if (invoices.size() > 0) {

            if (invoices.get(0).Billing_Street__c != null) {
                this.streetValue = invoices.get(0).Billing_Street__c.replaceAll('\\r\\n', '<br/>');
            }

            if (invoices.get(0).Invoice_Products__r.size() > 0) {
                this.billLines = invoices.get(0).Invoice_Products__r;
            } else {
                this.billLines = new List<Invoice_Product__c>();
            }
        }


//
//        List<Invoice__c> updateInvoices = new List<Invoice__c>();
//        List<Solvency_PDF_Format__c> formats = [SELECT Id FROM Solvency_PDF_Format__c];
//        for (Invoice__c invoice : [SELECT Id, Bexio_Id__c, PDF_Format_Invoice__c, Invoice_Status__c, PDF_Email_Status__c FROM Invoice__c]) {
//
//            invoice.PDF_Email_Status__c = 'Sent';
//
//            if (formats.size() > 0) {
//
//                invoice.PDF_Format_Invoice__c =formats.get(0).Id;
//            }
//
//            if (invoice.Bexio_Id__c == '796') {
//                invoice.Invoice_Status__c = 'Draft';
//                invoice.PDF_Email_Status__c = 'Unsent';
//            } else if (invoice.Bexio_Id__c == '790' || invoice.Bexio_Id__c == '789' || invoice.Bexio_Id__c == '788'
//                    || invoice.Bexio_Id__c == '787' || invoice.Bexio_Id__c == '786' || invoice.Bexio_Id__c == '785'
//                    || invoice.Bexio_Id__c == '784' || invoice.Bexio_Id__c == '795' || invoice.Bexio_Id__c == '793'
//                    || invoice.Bexio_Id__c == '791' || invoice.Bexio_Id__c == '781' || invoice.Bexio_Id__c == '779'
//                    || invoice.Bexio_Id__c == '783' || invoice.Bexio_Id__c == '768' || invoice.Bexio_Id__c == '767'
//                    || invoice.Bexio_Id__c == '765' || invoice.Bexio_Id__c == '760' || invoice.Bexio_Id__c == '756'
//                    || invoice.Bexio_Id__c == '736' || invoice.Bexio_Id__c == '734' || invoice.Bexio_Id__c == '716'
//                    || invoice.Bexio_Id__c == '714' || invoice.Bexio_Id__c == '707' || invoice.Bexio_Id__c == '702'
//                    || invoice.Bexio_Id__c == '701' || invoice.Bexio_Id__c == '700' || invoice.Bexio_Id__c == '699'
//                    || invoice.Bexio_Id__c == '698' || invoice.Bexio_Id__c == '697' || invoice.Bexio_Id__c == '696'
//                    || invoice.Bexio_Id__c == '694' || invoice.Bexio_Id__c == '693' || invoice.Bexio_Id__c == '674'
//                    || invoice.Bexio_Id__c == '29') {
//
//                invoice.Invoice_Status__c = 'Overdue';
//
//            } else {
//                invoice.Invoice_Status__c = 'Paid';
//            }
//
//            updateInvoices.add(invoice);
//        }
//
//        update updateInvoices;
    }
}