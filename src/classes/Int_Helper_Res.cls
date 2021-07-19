/**
 * Created by max1m on 10.05.21.
 */

public with sharing class Int_Helper_Res {

    public static List<Invoice__c> getPayments(String idInvoice) {

        List<Invoice__c> invoiceUpdate = new List<Invoice__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Payments';
        log.Description__c = '';

        try {
            HttpResponse res = invoiceProductCallout(idInvoice,'Payment');
            String result = res.getBody();

            log.Description__c += 'Status ' + res.getStatus() + '\n';

            if (res.getStatus() != 'Not Found') {


                invoiceUpdate = Int_InvoicePaymentHandler.parse(result);

                log.Description__c = 'Payment for ' + (invoiceUpdate.size() > 0 ? invoiceUpdate.get(0).Invoice__c : 'Not Invoice');
                log.Status__c = 'Success';
                log.Description__c += '; Time ' + Date.today() + '\n';

            } else {
                log.Description__c = 'Complete, Not Found Bexio Id = ' + idInvoice;
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            }

            insert log;

        } catch (Exception ex) {
            exceptionLog(log, ex);
        }

        return invoiceUpdate;
    }

    public static List<String> getCountInvoices(String dateSearch) {

        List<String> invoices = new List<String>();

        String result;
        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Count Invoice callout (update)';
        log.Description__c = '';

        System.debug('FFFFF');

        try {
            System.debug('Before sss');
            HttpResponse res = invoiceCountCallout(dateSearch);
            System.debug('sss');

            result = res.getBody();

            log.Description__c += result + '\n';
            System.debug('getCountInvoices');
            System.debug(dateSearch);
            System.debug(result);

            for (Bexio_Billing bill : (List<Bexio_Billing>) System.JSON.deserialize(result, List<Bexio_Billing>.class)) {
                invoices.add(bill.id);
                System.debug(bill);
                System.debug(bill.id);
            }

            System.debug(invoices);

            log.Description__c = 'Complete, Invoice = ' + invoices.size() + '\n';
            log.Status__c = 'Success';
            log.Description__c += '; Time ' + Date.today() + '\n';
            insert log;

        } catch (Exception ex) {
            System.debug('Exception');
            exceptionLog(log, ex);
            System.debug(ex);
        }

        return invoices;
    }

    public static List<Invoice_Product__c> getInvoiceProduct(String idInvoice) {

        List<Invoice_Product__c> invoiceProducts = new List<Invoice_Product__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice Product callout (95)';
        log.Description__c = '';

        try {
            HttpResponse res = invoiceProductCallout(idInvoice,'Invoice');
            String result = res.getBody();

            log.Description__c += 'Status ' + res.getStatus() + '\n';

            if (res.getStatus() != 'Not Found') {

                log.Description__c += result + '\n';

                invoiceProducts = Int_Invoice_Amount_Handler.parse(result);
                log.Description__c = 'Complete, All invoice Products = ' + invoiceProducts.size();
                log.Status__c = 'Success';
                log.Description__c += '; Time ' + Date.today() + '\n';

            } else {
                log.Description__c = 'Complete, Not Found Bexio Id = ' + idInvoice;
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            }

            insert log;

        } catch (Exception ex) {
            exceptionLog(log, ex);
        }

        return invoiceProducts;
    }

    private static HttpResponse invoiceProductCallout(String idInvoice, String status) {

        String credential = 'BexioStore';

        System.debug('invoiceProductCallout');

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get count Invoice Product callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + Int_Helper_Reserved.getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/' + idInvoice;

        System.debug(apiEndpoint);

        if (status == 'Payment') {
            apiEndpoint += '/payment';
        }

        System.debug(apiEndpoint);

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setMethod('GET');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            return res;
        } catch (Exception ex) {

            exceptionLog(log, ex);
            return null;
        }
    }

    private static HttpResponse invoiceCountCallout(String dateSearch) {

        String credential = 'BexioStore';
        String accessToken = Int_Helper_Reserved.getToken();

        System.debug(dateSearch);

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Post Invoice callout (invoiceCallout-count)';
        log.Description__c = '';

        String auth = 'Bearer ' + accessToken;
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/search?order_by=updated_at_desc';

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(Int_PUT_Invoice_Handler.invoiceUpdateSearch(dateSearch));
        req.setMethod('POST');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        System.debug('FF@@@@@@F');
        System.debug(req);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            return res;
        } catch (Exception ex) {

            System.debug(ex);

            exceptionLog(log, ex);
            return null;
        }
    }

    private static void exceptionLog(Bexio_Log__c log, Exception ex) {

        log.Status__c = 'Error';
        log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
        log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        insert log;
    }

    public class Bexio_Billing {
        public String id { get; set; }
    }
}