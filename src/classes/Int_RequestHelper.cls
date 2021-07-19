public with sharing class Int_RequestHelper {

    public static String getToken() {
        List<Bexio__c> credentials = [SELECT Token__c FROM Bexio__c LIMIT 1];
        return credentials.size() > 0 ? credentials.get(0).Token__c : '';
     }

    // Production
//    final private static String ACCESS_TOKEN = 'eyJraWQiOiI2ZGM2YmJlOC1iMjZjLTExZTgtOGUwZC0wMjQyYWMxMTAwMDIiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJkbmllZGVybWF5ZXJAc29sdmVuY3lhbmFseXRpY3MuY29tIiwibG9' +
//            'naW5faWQiOiI0NmE1YjVhYi1jOTYwLTExZTktYjE2Mi1hNGJmMDExY2U4NzIiLCJjb21wYW55X2lkIjoib3phamx5M2JzY3hrIiwidXNlcl9pZCI6MTMxMTU5LCJhenAiOiJldmVybGFzdC10b2tlbi1vZmZpY2UtY2xp' +
//            'ZW50Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCBhbGwgdGVjaG5pY2FsIiwiaXNzIjoiaHR0cHM6XC9cL2lkcC5iZXhpby5jb20iLCJleHAiOjMxOTA4NzIyNzIsImlhdCI6MTYxNDA3MjI3MiwiY29tcGFue' +
//            'V91c2VyX2lkIjoxLCJqdGkiOiJiMGFmNDhmYi0wOTNlLTRkNGUtODdhZS1mMzUwMDI1Njg0YTQifQ.ZqE_grb0xBY04vv4DMjUaKoMrCh8jJHnWvA8SQGCSRrCJ-ngOrJRjMAJ9j7S0OZOR1OZ0Hd4xUk7xUL8ceI3M5Fx' +
//            'cAVtlEfQUoKWtNCYpnJSWTXb9FTp_PhZ83rLb-3k2if9GllTXqBfwQHEhi5IzDDh_YCnawu4_KaIj2TpcTSaGyeviLEi4khcqGjXNvSGVOvaBdErkIvFnhyg47t1X9ueY_P05N9grlPGponjI29f0oQg57VI1Mpqhe2XLa' +
//            'GqkmIPGzJAgxA1AZLgYq5W-uAp6fHKtmojIMamenF2E10fescoCukJhwxVthD7nMFI7mJwMSNdjDVSAB2O-gSQOjyBpcRerk4ns631N4F2h_krs-gcBoNyn1Indh-Ja-WxF0WqyjMHqXiz_JZUfg5wqi4hwuSwT4vvwbl1P2' +
//            'mB6RoqU-dLPOJfirSmSCdQZbKIl7rMtCb4LRbv0gV8Aggw7R34y5ehjFkFuL6VrRA2WENqP0pwfF9MJJdFInPjISFeLh3rVyP3uBaW2_XCULN2CH-6Hw5i_UqFIKnr13bTEfmwcUZ-mamk-A1tuqiOGiIuj8Ns-idizn97' +
//            'VXQM-U240J2OrzLSkgpkpTjy98ClAIb9-XqfIZPUORCXeFKWdMkIbNYnXm36EGMjjiyuUsXIdRVx3VkbG-_q8Jx90VLo9iw';
    //Test
//    final private static String ACCESS_TOKEN = 'eyJraWQiOiI2ZGM2YmJlOC1iMjZjLTExZTgtOGUwZC0wMjQyYWMxMTAwMDIiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJkbmllZGVybWF5ZXJAc29sdmVuY3lhbmFseXRpY3MuY29tIiwibG9n' +
//            'aW5faWQiOiI0NmE1YjVhYi1jOTYwLTExZTktYjE2Mi1hNGJmMDExY2U4NzIiLCJjb21wYW55X2lkIjoianQ2M2RvNGhpdmZ6IiwidXNlcl9pZCI6MTMxMTU5LCJhenAiOiJldmVybGFzdC10b2tlbi1vZmZpY2U' +
//            'tY2xpZW50Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCBhbGwgdGVjaG5pY2FsIiwiaXNzIjoiaHR0cHM6XC9cL2lkcC5iZXhpby5jb20iLCJleHAiOjMxOTA5MTgwNzMsImlhdCI6MTYxNDExODA3Myw' +
//            'iY29tcGFueV91c2VyX2lkIjoxLCJqdGkiOiJiZDZiMzVlYy04ZjA4LTQzZDItYjNkYi04NmM5OWI3YjEwZjMifQ.VAgQMF62166q_gx9skx3X-rR9CJeoZhZe4R-5eeyFyKyz-UgwUvLXcYzhk10Sz3nRukrTkfx' +
//            '1I-h4EExcWX8t_QEaGQj5rX4Mj_3o5VVrX2tYHyQRaqUScDPTHNRNizRyyjWz_GIKYf0WfiQ-QeA4Stpj4iLWugqDPYqBJN9-zxmMirVmwiTU7Lb8TmR_NOOtrbmUosTzO5hgtZjKiTyps_FWcY_GW3dmyWYxERd' +
//            'BgR1VXquG16US5jk2h_wWjtTnck6Tp9toVGJqBP1JA1Jpm0yzm6RPJz-bzM_leIzru5nGtVlqwd2ouHUlVjJ-novNB_JyyyFdFWLB1XoDWgHNOsh3wUVioQpE9qW8kixPvvXvR6Dop5bFD2UmDEaPFms6GkYFZ36' +
//            '8FvSpL57wuPwZbXfEBBT51CIAwEi5WrocrSV4q4lXcaGXgaS8JDG8HW2YMMqPhGw874ufAcfBr7fR1oZxBzDC2mylPm0tAdzrslzCPN5HZa-nDQFt5UL9QXEXRgghSTn6Fh4_kbAAmaDDQOlKshDSIrEp30J8qsh' +
//            'N6MOHDbchKQeqVrh5kd8ZfY6FDbQhqOTdYnFoRy_LYKP3fpYdN5heoWurbWgm7qOxDoRLZuPfIBnO1HuGZdE4TUDZ5PkuhSfV2C8g19VtKwnFDZApMHVgCE5Cbc-RkmmevQ';

    public static String putInvoices(List<Invoice__c> putInvoices) {

        String result;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Invoice callout';
        log.Description__c = '';

        try {
            HttpResponse res = invoicePutCallout(putInvoices.get(0));
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

            if (status == 'Count') {
                invoices = (List<Int_Invoice_Handler.Bexio_Billing>) System.JSON.deserialize(result, List<Int_Invoice_Handler.Bexio_Billing>.class);
            } else {
                invoices = Int_Invoice_Update_Halper.parse(result);
            }

            log.Description__c = 'Complete, Invoice = ' + invoices.size();
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

    public static String updateInvoices(Invoice__c invoiceUpdate) {

        String result;
        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Invoice callout (Update)';
        log.Description__c = '';

        try {
            HttpResponse res = invoicePutUpdateCallout(invoiceUpdate);
            if (res != null) {

                System.debug('Result');
                result = res.getBody();
                System.debug('Result---> ' + result);
                //updateInvoices = Int_Invoice_Handler.parse(result);
                //bexioInvoice = (Int_Invoice_Handler.Bexio_Billing) System.JSON.deserialize(result, Int_Invoice_Handler.Bexio_Billing.class);
                log.Description__c = 'Complete, Invoice = ' + result;
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            } else {
                log.Description__c = 'Complete, Result = Null (' + result + ');';
            }

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;

        return result;
    }
//
//    public static List<Payment__c> getPayments(String queryDay, Integer nextCount, Integer limitObject) {
//
//        List<Payment__c> payments = new List<Payment__c>();
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Bexio Get Payment callout';
//        log.Description__c = '';
//
//        try {
//            HttpResponse res = paymentCallout('Objects', queryDay, nextCount, limitObject);
//            String result = res.getBody();
//            payments = Int_Payment_Handler.parse(result);
//            log.Description__c = 'Complete, All payments = ' + payments.size();
//            log.Status__c = 'Success';
//            log.Description__c += 'Time ' + Date.today() + '\n';
//
//        } catch (Exception ex) {
//            log.Status__c = 'Error';
//            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
//            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
//        }
//
//        insert log;
//        return payments;
//    }
//
//    public static Integer getCountPayments(String queryDay) {
//
//        Integer count = 0;
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Bexio Get count Payment callout';
//        log.Description__c = '';
//
//        try {
//            HttpResponse res = paymentCallout('count', queryDay, 0, 0);
//            count = Integer.valueOf(res.getHeader('X-Total-Count'));
//            log.Description__c = 'Complete, count payments = ' + count;
//            log.Status__c = 'Success';
//            log.Description__c += 'Time ' + Date.today() + '\n';
//        } catch (Exception ex) {
//            log.Status__c = 'Error';
//            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
//            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
//        }
//
//        insert log;
//        return count;
//    }

//    public static List<Object> getCountPayments() {
//
//        List<Object> invoices = new List<Object>();
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Bexio Get Invoice callout';
//        log.Description__c = '';
//
//        try {
//            HttpResponse res = invoiceCallout('count',0,0);
//            String result = res.getBody();
//
//            invoices = (List<Int_Payment_Handler.BexioPayment>) System.JSON.deserialize(result, List<Int_Payment_Handler.BexioPayment>.class);
//
//            System.debug(invoices);
//            log.Description__c = 'Complete, All payments = ' + invoices.size();
//            log.Status__c = 'Success';
//            log.Description__c += 'Time ' + Date.today() + '\n';
//
//        } catch (Exception ex) {
//            log.Status__c = 'Error';
//            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
//            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
//        }
//
//        insert log;
//        return invoices;
//    }

    public static List<Invoice__c> getInvoices(Integer nextCount, Integer limitObject) {

        System.debug('++++++++');

        List<Invoice__c> invoices = new List<Invoice__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice callout';
        log.Description__c = '';

        try {

            HttpResponse res;

            if (nextCount == 0 && limitObject == 0) {
                res = invoiceCallout('Objects',nextCount,limitObject);
            } else {
                res = invoiceCallout('Count',nextCount,limitObject);
            }

            if (res.getStatus() == 'Success') {
                String result = res.getBody();
                invoices = Int_Invoice_Handler.parse(result);
                log.Description__c = 'Complete, All invoices = ' + invoices.size();
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';

            } else {
                log.Status__c = 'Error';
                log.Description__c += 'Status: ' + res.getStatus() + '\n';
            }


        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return invoices;
    }

    public static List<Account> getAccounts(Integer nextCount, Integer limitObject) {

        List<Account> accounts = new List<Account>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Account callout';
        log.Description__c = '';

        try {
            HttpResponse res = accountCallout('Objects',nextCount,limitObject);
            String result = res.getBody();

            accounts = Int_Account_Handler.parse(result);
            log.Description__c = 'Complete, All accounts = ' + accounts.size();
            log.Status__c = 'Success';
            log.Description__c += 'Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return accounts;
    }

    public static List<Invoice_Product__c> getInvoiceProducts(String idInvoice) {

        System.debug('+++++++++');

        List<Invoice_Product__c> invoiceProducts = new List<Invoice_Product__c>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Invoice Product callout';
        log.Description__c = '';

        try {
            HttpResponse res = invoiceProductCallout(idInvoice);
            String result = res.getBody();

            invoiceProducts = Int_Invoice_Items_Handler.parse(result);
            log.Description__c = 'Complete, All invoice Products = ' + invoiceProducts.size();
            log.Status__c = 'Success';
            log.Description__c += 'Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return invoiceProducts;
    }

    public static List<Object> getCountCountry() {

        List<Object> countries = new List<Object>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Country count callout';
        log.Description__c = '';

        try {
            HttpResponse res = countryCallout();
            String result = res.getBody();

            countries = Int_Country_Handler.parse(result);

            if (countries.size() > 200) {
                log.Description__c = 'Sent many countries and will fix the butch!, All accounts = ' + countries.size();
                log.Status__c = 'Error';
                log.Description__c += 'Time ' + Date.today() + '\n';
            } else {
                log.Description__c = 'Complete, All accounts = ' + countries.size();
                log.Status__c = 'Success';
                log.Description__c += 'Time ' + Date.today() + '\n';
            }

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return countries;
    }

    private static HttpResponse countryCallout() {

        String credential = 'BexioStore';
        String accessToken = getToken();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get count Country callout (countryCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + accessToken;
        String apiEndpoint = 'callout:' + credential + '/2.0/country';

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

            log.Status__c = 'Error';
            log.Description__c += 'Methods - accountCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    public static List<Object> getCountAccounts() {

        List<Object> accounts = new List<Object>();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get Account count callout';
        log.Description__c = '';

        try {
            HttpResponse res = accountCallout('count',0,0);
            System.debug(res);
            String result = res.getBody();

            accounts = (List<Int_Account_Handler.Bexio_Account>) System.JSON.deserialize(result, List<Int_Account_Handler.Bexio_Account>.class);

            log.Description__c = 'Complete, All accounts = ' + accounts.size();
            log.Status__c = 'Success';
            log.Description__c += 'Time ' + Date.today() + '\n';

        } catch (Exception ex) {
            log.Status__c = 'Error';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
        }

        insert log;
        return accounts;
    }

    private static HttpResponse invoiceProductCallout(String idInvoice) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Get count Invoice Product callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/'+idInvoice;

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

            log.Status__c = 'Error';
            log.Description__c += 'Methods - invoiceProductCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    private static HttpResponse invoiceCallout(String status, Integer nextCount, Integer limitObject) {

        System.debug('+++');

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = status == 'count' ? 'Bexio Get count Invoice callout (invoiceCallout)' : 'Bexio Get Invoice callout (invoiceCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice?order_by=updated_at_desc';

        if (status == 'Objects') {
            apiEndpoint += + '&limit=' + limitObject + (nextCount > 0 ? '&offset=' + nextCount : '');
        }

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

            log.Status__c = 'Error';
            log.Description__c += 'Methods - invoiceCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    private static HttpResponse paymentCallout(String status, String queryDay, Integer nextCount, Integer limitObject) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = status == 'count' ? 'Bexio Get count Payment callout(paymentCallout)' : 'Bexio Get Payment callout(paymentCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/3.0/banking/payments?&from' + queryDay;

        if (status == 'Objects') {
            apiEndpoint += + '&limit=' + limitObject + (nextCount > 0 ? '&offset=' + nextCount : '');
        }

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

            log.Status__c = 'Error';
            log.Description__c += 'Methods - paymentCallout' + '\n';
            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
            insert log;
            return null;
        }
    }

    private static HttpResponse accountCallout(String status, Integer nextCount, Integer limitObject) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = status == 'count' ? 'Bexio Get count Account callout (accountCallout)' : 'Bexio Get Account callout (accountCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();
        String apiEndpoint = 'callout:' + credential + '/2.0/contact?order_by=updated_at_desc';

        if (status == 'Objects') {
            apiEndpoint += + '&limit=' + limitObject + (nextCount > 0 ? '&offset=' + nextCount : '');
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
            System.debug('DDD');
            return res;
        } catch (Exception ex) {

            log.Status__c = 'Error';
            log.Description__c += 'Methods - accountCallout' + '\n';
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

    private static HttpResponse invoicePutUpdateCallout(Invoice__c invoice) {

        String credential = 'BexioStore';

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Put Update Invoice callout';
        log.Description__c = '';

        String auth = 'Bearer ' + getToken();

        if (String.isNotBlank(invoice.Bexio_Id__c)) {
            String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/' + invoice.Bexio_Id__c;
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', auth);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(Int_PUT_Update_Invoice_Handler.putRequestInvoice(invoice));
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
        } else {
            return null;
        }
    }


//    public static List<Payment__c> getPayments() {
//
//        List<Payment__c> payments = new List<Payment__c>();
//        String credential = 'BexioStore';
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Bexio Get Payment callout';
//        log.Description__c = '';
//
//        String auth = 'Bearer ' + ACCESS_TOKEN;
//        String apiEndpoint = 'callout:' + credential + '/3.0/banking/payments';
//
//        HttpRequest req = new HttpRequest();
//        req.setHeader('Authorization', auth);
//        req.setHeader('Accept', 'application/json');
//        req.setMethod('GET');
//        req.setEndpoint(apiEndpoint);
//        req.setTimeout(120000);
//
//        Http sendHttp = new Http();
//
//        try {
//            HttpResponse res = sendHttp.send(req);
//            String result = res.getBody();
//            payments = Int_Payment_Handler.parse(result);
//            log.Description__c = 'Complete, All payments = ' + payments.size();
//            log.Status__c = 'Success';
//            log.Description__c += 'Time ' + Date.today() + '\n';
//        } catch (Exception ex) {
//            log.Status__c = 'ERROR';
//            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
//            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
//        }
//
//        insert log;
//        return payments;
//    }
//
//    public static Integer getCountPayments(String queryDay) {
//
//        Integer count = 0;
//        String credential = 'BexioStore';
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Bexio Get count Payment callout';
//        log.Description__c = '';
//
//        String auth = 'Bearer ' + ACCESS_TOKEN;
//        String apiEndpoint = 'callout:' + credential + '/3.0/banking/payments?&from' + queryDay;
//
//        HttpRequest req = new HttpRequest();
//        req.setHeader('Authorization', auth);
//        req.setHeader('Accept', 'application/json');
//        req.setMethod('GET');
//        req.setEndpoint(apiEndpoint);
//        req.setTimeout(120000);
//
//        Http sendHttp = new Http();
//
//        try {
//            HttpResponse res = sendHttp.send(req);
//            count = Integer.valueOf(res.getHeader('X-Total-Count'));
//            log.Description__c = 'Complete, count payments = ' + count;
//            log.Status__c = 'Success';
//            log.Description__c += 'Time ' + Date.today() + '\n';
//        } catch (Exception ex) {
//            log.Status__c = 'ERROR';
//            log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
//            log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
//        }
//
//        insert log;
//        return count;
//    }


}