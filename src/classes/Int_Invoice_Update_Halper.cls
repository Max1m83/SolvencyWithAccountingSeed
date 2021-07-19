/**
 * Created by max1m on 23.03.21.
 */

public with sharing class Int_Invoice_Update_Halper implements Int_DeserializerInterface {

    static final Map<Integer, String> STATUS_MAP = new Map<Integer, String>{
            7 => 'Draft',
            8 => 'Overdue',
            9 => 'Paid'
    };

    public static List<SObject> parse(String json) {

        List<Invoice__c> invoices = updateInvoices((List<Bexio_Billing>) System.JSON.deserialize(json.replaceAll('title', 'titleBexio'), List<Bexio_Billing>.class));

        return invoices;
    }

    private static List<Invoice__c> updateInvoices(List<Bexio_Billing> bexioBilling) {

        List<Invoice__c> updateInvoices = new List<Invoice__c>();
        Set<String> invoicesId = new Set<String>();

        for (Bexio_Billing billing : bexioBilling) {
            invoicesId.add(billing.id);
        }

        List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Update_in_Bexio__c, Invoice__c FROM Invoice__c WHERE Bexio_Id__c IN :invoicesId];
        Map<String, SObject> invoicesMap = (Map<String, SObject>) Int_Utils.getSObjectMap(invoices, 'Bexio_Id__c');

        for (Bexio_Billing billing : bexioBilling) {

            if (invoicesMap.containsKey(billing.id)) {
                Invoice__c updateInvoice = (Invoice__c)invoicesMap.get(billing.id);
                updateInvoice.Update_in_Bexio__c = Date.valueOf(billing.updated_at);
                updateInvoice.Invoice__c = billing.document_nr;
                updateInvoice.getPositions__c = true;
                updateInvoice.Invoice_Status__c = STATUS_MAP.containsKey(billing.kb_item_status_id) ? STATUS_MAP.get(billing.kb_item_status_id) : 'Draft';

                updateInvoices.add(updateInvoice);

            } else {

            }
        }

        upsert updateInvoices;
        return updateInvoices;
    }

    public class Bexio_Billing {
        String id { get; set; }
        String document_nr { get; set; }
        Integer kb_item_status_id { get; set; }
        String updated_at { get; set; }
    }
}