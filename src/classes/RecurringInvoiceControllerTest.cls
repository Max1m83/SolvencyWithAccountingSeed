/**
 * Created by max1m on 3.06.21.
 */
@isTest
public with sharing class RecurringInvoiceControllerTest {

    @isTest static void getRecurringInvoiceTest() {
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        Id contactId = Int_TestCreateObject.createContact();
        Int_TestCreateObject.createInvoicesProduct('1', Int_TestCreateObject.createProducts(5));
        Int_TestCreateObject.contactBilling(contactId, invoiceId, 'TO');
        Int_TestCreateObject.contactBilling(contactId, invoiceId, 'CC');

        Map<String, String> mapsInvoice = new Map<String, String>();
        mapsInvoice.put('Account', oppAcc.get('Account'));
        mapsInvoice.put('Billing', invoiceId);
        mapsInvoice.put('InvoiceDate', '2021-02-02');
        mapsInvoice.put('Status', 'Active');
        mapsInvoice.put('Name', oppAcc.get('Account'));
        mapsInvoice.put('CreateInvoice', 'true');

        Test.startTest();
        Map<String, List<String>> resultMap = RecurringInvoiceController.getRecurringInvoice(invoiceId);
        mapsInvoice.put('Frequency', resultMap.get('Frequency')[0]);
        String result = RecurringInvoiceController.SaveBilling(mapsInvoice, resultMap.get('Contacts'));
        Test.stopTest();

        System.assertEquals('TestAccount', resultMap.get('Accounts')[0]);
        System.assertEquals('OppInContact', resultMap.get('Name')[0]);
        System.assertEquals('Test', result);
    }
}