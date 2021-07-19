/**
 * Created by max1m on 16.04.21.
 */
@isTest
public with sharing class PDFClassTest {

    @isTest static void getRecurringInvoicePositiveTest() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('PDF', 'Get', 'success'));
        Map<String, String> resultMap = new Map<String, String>();
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('12', accOpp.get('Opportunity'), accOpp.get('Account'));

        //Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.startTest();
        resultMap = PDFClass.previewInvoice(invoiceId);
        Test.stopTest();

        System.assertEquals('SUCCESS', resultMap.get('Status'));
    }

    @isTest static void getRecurringInvoicePositiveAttachmentTest() {

        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('12', accOpp.get('Opportunity'), accOpp.get('Account'));
        Invoice__c invoice = [SELECT Id, Invoice__c FROM Invoice__c WHERE Id = :invoiceId LIMIT 1];
        invoice.Invoice__c = '2020-12';
        PDFClass.Bexio_PDF bexioObject = new PDFClass.Bexio_PDF();
        bexioObject.content = '2020-12';
        bexioObject.content = 'Test';

        Attachment attachment = new Attachment();

        Test.startTest();
        attachment = PDFClass.createPDF(bexioObject, invoice);
        Test.stopTest();

        System.debug(attachment);

        System.assertEquals('2020-12.pdf', attachment.Name);
    }

    @isTest static void getRecurringInvoiceNegativeTest() {

        Map<String, String> resultMap = new Map<String, String>();

        String AccountId = Int_TestCreateObject.accountCreate();

        Test.startTest();
        resultMap = PDFClass.previewInvoice(AccountId);
        Test.stopTest();

        System.assertEquals('ERROR', resultMap.get('Status'));
    }
}