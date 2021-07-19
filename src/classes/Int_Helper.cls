public with sharing class Int_Helper {

    public static String getToken() {
        List<Bexio__c> credentials = [SELECT Token__c FROM Bexio__c LIMIT 1];
        return credentials.size() > 0 ? credentials.get(0).Token__c : '';
    }

    public static String putInvoices(List<Invoice__c> putInvoices) {

        String result;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Invoice callout';
        log.Description__c = '';

        try {
            HttpResponse res = invoicePutCallout(putInvoices.get(0));
            System.debug(result);
            result = res.getBody();
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

    private static HttpResponse invoicePutCallout(Invoice__c invoice) {

        String credential = 'BexioStore';
        System.debug('invoicePutCallout');

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

    public static Integer getCountInvoicesRecon (String searchTime) {

        Integer countInvoices;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice callout';
        log.Description__c = '';

        try {

            HttpResponse res;

            res = invoiceCallout('Count', 0, 0, searchTime);

            if (res != null) {

                String result = res.getBody();

                List<Int_Invoice_Handler.Bexio_Billing> bexioBilling = (List<Int_Invoice_Handler.Bexio_Billing>) System.JSON.deserialize(result, List<Int_Invoice_Handler.Bexio_Billing>.class);
                countInvoices = bexioBilling.size();
                log.Description__c = 'Complete, All invoices = ' + countInvoices;
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            } else {
                log.Description__c = 'Complete, Result = Null (' + res.getBody() + ');';
            }

            insert log;
        } catch (Exception ex) {
            exceptionLog(log, ex);
        }

        return countInvoices;
    }


    public static List<Invoice__c> getInvoices(Integer nextCount, Integer limitObject, String searchTime) {

        List<Invoice__c> invoices = new List<Invoice__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice callout';
        log.Description__c = '';

        try {

            HttpResponse res;

            if (nextCount == 0 && limitObject == 0) {
                res = invoiceCallout('Objects', nextCount, limitObject, searchTime);
            } else {
                res = invoiceCallout('Count', nextCount, limitObject, searchTime);
            }

            if (res != null) {

                String result = res.getBody();
                invoices = Int_Invoice_Handler.parse(result);
                log.Description__c = 'Complete, All invoices = ' + invoices.size();
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            } else {
                log.Description__c = 'Complete, Result = Null (' + res.getBody() + ');';
            }

            insert log;
        } catch (Exception ex) {
            exceptionLog(log, ex);
        }

        return invoices;
    }

    public static List<Invoice_Product__c> getInvoiceProducts(String idInvoice) {

        List<Invoice_Product__c> invoiceProducts = new List<Invoice_Product__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice Product callout (Rec)';
        log.Description__c = '';

        try {
            HttpResponse res = invoiceProductCallout(idInvoice);
            String result = res.getBody();

            log.Description__c += 'Status ' + res.getStatus() + '\n';

            if (res.getStatus() != 'Not Found'){

                invoiceProducts = Int_Invoice_Items_Handler.parse(result);
                //invoiceProducts = Int_Invoice_Handler.parse(result);
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

    public static List<Invoice_Product__c> getInvoiceWithProduct(String idInvoice) {

        List<Invoice_Product__c> invoiceProducts = new List<Invoice_Product__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice Product callout';
        log.Description__c = '';

        try {
            HttpResponse res = invoiceProductCallout(idInvoice);
            String result = res.getBody();

            log.Description__c += 'Status ' + res.getStatus() + '\n';

            if (res.getStatus() != 'Not Found'){

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

    private static HttpResponse invoiceProductCallout(String idInvoice) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get count Invoice Product callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/' + idInvoice;

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

    private static HttpResponse invoiceCallout(String status, Integer nextCount, Integer limitObject, String searchTime) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = status == 'count' ? 'Bexio Get count Invoice callout (invoiceCallout)' : 'Bexio Get Invoice callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/search?order_by=updated_at_desc';

        if (status == 'Objects') {
            apiEndpoint += +'&limit=' + limitObject + (nextCount > 0 ? '&offset=' + nextCount : '');
        }

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setBody(putBody(searchTime));
        req.setMethod('POST');
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

    private static String putBody(String searchTime) {

        List<Map <String,String> > listReturn = new List<Map <String,String> >();
        Map <String,String> searchMap = new Map <String,String>();

        searchMap.put('criteria', '>=');
        searchMap.put('value', searchTime);
        searchMap.put('field', 'updated_at');

        listReturn.add(searchMap);

        System.debug(JSON.serialize(listReturn));

        return JSON.serialize(listReturn);
    }

    private static void exceptionLog(Bexio_Log__c log, Exception ex) {

        log.Status__c = 'Error';
        log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
        log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        insert log;
    }
}