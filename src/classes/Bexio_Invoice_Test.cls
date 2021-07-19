/**
 * Created by max1m on 13.05.21.
 */
@isTest
public with sharing class Bexio_Invoice_Test {

    @isTest static void previewInvoiceBexioTest() {

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });
        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', accOpp.get('Opportunity'), accOpp.get('Account'));

        String conId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Test.StartTest();
        Map<String, String> returnString = Int_SendEmailController.previewInvoiceBexio(invoiceId);
        Test.StopTest();

        System.assertEquals(returnString.get('Status'), 'Success');
    }
}