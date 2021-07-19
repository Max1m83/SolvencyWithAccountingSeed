/**
 * Created by max1m on 31.05.21.
 */
@isTest
public with sharing class TriggerTest {

    @isTest
    private static void InvoiceGroupTrigger() {

        Int_TestCreateObject.createInvoices(new List<String>{'1','2'});
        List<Invoice__c> invoices = [SELECT Id FROM Invoice__c WHERE Bexio_Id__c =: '1'];

        if (invoices.size() > 0) {
            Int_TestCreateObject.contactBilling(Int_TestCreateObject.createContact(), invoices.get(0).Id, 'TO');
        }

        List<Contacts_for_Billing__c> contacts = [SELECT Id FROM Contacts_for_Billing__c];

        Test.StartTest();
        update contacts;
        delete contacts;
        Test.StopTest();
    }
}