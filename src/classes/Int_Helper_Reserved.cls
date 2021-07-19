/**
 * Created by max1m on 06.04.21.
 */

public with sharing class Int_Helper_Reserved {

    public static String getToken() {
        List<Bexio__c> credentials = [SELECT Token__c FROM Bexio__c LIMIT 1];
        return credentials.size() > 0 ? credentials.get(0).Token__c : '';
    }

    public static String putAccount(Account acc) {

        String result;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Account callout';
        log.Description__c = '';

        try {
            HttpResponse res = accountBexioCallout(acc);
            result = res.getBody();
            log.Description__c = 'Complete, Invoice = ' + result;
            log.Status__c = 'Success';
            log.Description__c += 'Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return result;
    }

    private static HttpResponse accountBexioCallout(Account acc) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Account callout (accountBexioCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/contact';

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(Int_PUT_Account_Handler.putRequestAccount(acc));
        req.setMethod('POST');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);
        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            return res;
        } catch (Exception ex) {

            log.Status__c = 'Error';
            log.Description__c += 'Methods - invoicePutCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    public static String putInvoices(List<Invoice__c> putInvoices) {

        String result;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Invoice callout';
        log.Description__c = '';

        try {
            HttpResponse res = invoicePutCallout(putInvoices.get(0));
            result = res.getBody();
            System.debug(result);
//            updateInvoices = Int_Invoice_Handler.parse(result);
            //bexioInvoice = (Int_Invoice_Handler.Bexio_Billing) System.JSON.deserialize(result, Int_Invoice_Handler.Bexio_Billing.class);
            log.Description__c = 'Complete, Invoice = ' + result;
            log.Status__c = 'Success';
            log.Description__c += 'Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return result;
    }

    public static List<Object> getCountInvoices(String dateSearch, Integer nextCount, Integer limitObject, String status) {

        List<Object> invoices = new List<Object>();

        String result;
        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = status == 'Count' ? 'Bexio Count Invoice callout (update)' :
                'Bexio Invoice callout (update) - limit=' + limitObject + '; nextCount=' + nextCount;
        log.Description__c = '';

        try {
            HttpResponse res = invoiceCountCallout(dateSearch, nextCount, limitObject, status);

            result = res.getBody();

            log.Description__c += result + '\n';

            if (status == 'Count') {

                invoices = (List<Int_Invoice_Handler.Bexio_Billing>) System.JSON.deserialize(result, List<Int_Invoice_Handler.Bexio_Billing>.class);

            } else {
                invoices = Int_Invoice_Update_Halper.parse(result);
            }
            log.Description__c = 'Complete, Invoice = ' + invoices.size() + '\n';
            log.Status__c = 'Success';
            log.Description__c += '; Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;

        return invoices;
    }

    private static HttpResponse invoiceCountCallout(String dateSearch, Integer nextCount, Integer limitObject, String status) {

        String credential = 'BexioStore';
        String accessToken = getToken();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Post Invoice callout (invoiceCallout-count)';
        log.Description__c = '';

        String auth = 'Bearer ' + accessToken;
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/search?order_by=updated_at_desc';

        if (status == 'UpdateInvoice') {
            apiEndpoint += '&limit=' + limitObject + '&offset=' + nextCount;
        }

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(Int_PUT_Invoice_Handler.invoiceUpdateSearch(dateSearch));
        req.setMethod('POST');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            return res;
        } catch (Exception ex) {

            log.Status__c = 'Error';
            log.Description__c += 'Methods - invoicePutCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    private static HttpResponse invoicePutCallout(Invoice__c invoice) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Invoice callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice';

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(Int_PUT_Invoice_Handler.putRequestInvoice(invoice));
        req.setMethod('POST');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            return res;
        } catch (Exception ex) {

            log.Status__c = 'Error';
            log.Description__c += 'Methods - invoicePutCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }
}