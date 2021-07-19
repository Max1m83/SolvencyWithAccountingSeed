/**
 * Created by max1m on 15.04.21.
 */

public with sharing class PDFClass {

    @AuraEnabled
    public static Map<String, String> previewInvoice(String invoiceId) {

        System.debug('invoiceId-->' + invoiceId);

        Map<String, String> returnMaps = new Map<String, String>();
        List<Attachment> deleteAttachments = new List<Attachment>();

        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoiceId];
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceId];

        System.debug(invoices);

        Attachment invoicePDF = new Attachment();

        if (invoices.size() > 0) {

            returnMaps.put('Status', 'SUCCESS');
            returnMaps.put('urlInvoice', '');

            Invoice__c invoice = invoices.get(0);

            for (Attachment att : attachmentList) {
                if (att.Name == invoice.Invoice__c + '.pdf') {
                    deleteAttachments.add(att);

                }
            }

            invoicePDF = createPDFCallout(invoice.Bexio_Id__c, attachmentList, invoices);
            System.debug(invoicePDF);
            updateInvoice(invoice.Bexio_Id__c);
            returnMaps.put('urlInvoice','/servlet/servlet.FileDownload?file=' + invoicePDF.Id + '&operationContext=S1');

            if (deleteAttachments.size() > 0) {
                delete deleteAttachments;
            }

        } else {
            returnMaps.put('Status', 'ERROR');
            returnMaps.put('Description', 'there isn`t invoice');
        }

        return returnMaps;
    }

    @Future (callout=true)
    public static void updateInvoice(String bexoiId) {
        List<Invoice_Product__c> products = Int_Helper_Res.getInvoiceProduct(bexoiId);
    }

    public static Attachment createPDFCallout(String invoiceId, List<Attachment> attachmentList, List<Invoice__c> invoices) {

        System.debug('createPDFCallout');

        String result;
        Attachment invoicePDF = new Attachment();
        Boolean isPDF = true;

        Bexio_Log__c log = new Bexio_Log__c();

        if (invoices.size() > 0) {

            Invoice__c invoice = invoices.get(0);

            for (Attachment att : attachmentList) {
                if (att.Name == invoice.Invoice__c + '.pdf') {
                    //isPDF = false;
                }
            }

            if (isPDF) {

                log.Type__c = 'Bexio PDF #' + invoiceId;
                log.Description__c = '';

                try {
                    HttpResponse res = invoicePDFCallout(invoiceId);
                    result = res.getBody();
                    invoicePDF = createPDF((Bexio_PDF) System.JSON.deserialize(result, Bexio_PDF.class), invoices.get(0));
                    log.Description__c = 'Complete';
                    log.Status__c = 'Success';
                    log.Description__c += 'Time ' + Date.today() + '\n';

                } catch (Exception ex) {
                    log.Status__c = 'Error';
                    log.Description__c += 'Exception: ' + ex.getMessage() + '\n';
                    log.Description__c += 'Line Number: ' + ex.getLineNumber() + '\n';
                }
            } else {

                log.Description__c += 'There is exist Invoice PDF';
                insert log;
            }

        } else {
            log.Description__c += 'There is not Invoice';
            insert log;
        }
        return invoicePDF;
    }

    public static Attachment createPDF(Bexio_PDF pdfObject, Invoice__c invoice) {

        ContentVersion cv = createContentVersion(pdfObject.content, invoice);

        Attachment attach = new Attachment();
        String nameInvoice = invoice.Invoice__c + '.pdf';
        attach.Name = nameInvoice;
        attach.IsPrivate = false;
        attach.ParentId = invoice.Id;
        attach.Body = cv.VersionData;
        insert attach;

        System.debug(attach);

        return attach;
    }

    private static ContentVersion createContentVersion(String base64, Invoice__c invoice) {

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = 'invoice #' + invoice.Invoice__c;
        cv.PathOnClient = 'invoice #' + invoice.Invoice__c;

        try {
            insert cv;
            return cv;
        } catch (DMLException e) {
            System.debug(e);
            return null;
        }
    }

    private static HttpResponse invoicePDFCallout(String invoiceId) {

        String credential = 'BexioStore';
        String accessToken = Int_Helper_Reserved.getToken();

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio PDF #' + invoiceId + '(invoicePDFCallout)';
        log.Description__c = '';

        String auth = 'Bearer ' + accessToken;
        String apiEndpoint = 'callout:' + credential + '/2.0/kb_invoice/' + invoiceId + '/pdf';
        System.debug(apiEndpoint);

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            System.debug(res);
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

    public class Bexio_PDF {
        public String name { get; set; }
        public String content { get; set; }
    }
}