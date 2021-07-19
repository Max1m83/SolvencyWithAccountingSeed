/**
 * Created by max1m on 17.05.21.
 */

public with sharing class Int_InvoicePaymentHandler implements Int_DeserializerInterface {

    public static List<SObject> parse(String json) {

        Invoice__c invoicePayment = createPayments((List<BexioPayment>) System.JSON.deserialize(json.replaceAll('date', 'paymentDate'), List<BexioPayment>.class));

        update invoicePayment;

        return new List<Invoice__c>{invoicePayment};
    }

    private static Invoice__c createPayments(List<BexioPayment> bexioPayments) {

        Invoice__c invoice = new Invoice__c();

        if (bexioPayments.size() > 0) {

            List<Invoice__c> invoiceExist = [SELECT Invoice__c, Payment_Date__c FROM Invoice__c WHERE Bexio_Id__c = :bexioPayments.get(0).kb_invoice_id AND Bexio_Id__c != NULL];

            if (invoiceExist.size() > 0) {
                invoice = invoiceExist.get(0);

                Date payDate;
                if (String.isNotBlank(bexioPayments.get(0).paymentDate)) {
                    payDate = Date.valueOf(bexioPayments.get(0).paymentDate);
                }

                for (BexioPayment bexioObject : bexioPayments) {
                    if (String.isNotBlank(bexioPayments.get(0).paymentDate)) {
                        payDate = Date.valueOf(bexioPayments.get(0).paymentDate) > payDate ? Date.valueOf(bexioPayments.get(0).paymentDate) : payDate;
                    }
                }
                invoice.Payment_Date__c = payDate;
            }
        }

        return invoice;
    }

    public class BexioPayment {
        String paymentDate { get; set; }
        String value { get; set; }
        String kb_invoice_id { get; set; }
    }
}