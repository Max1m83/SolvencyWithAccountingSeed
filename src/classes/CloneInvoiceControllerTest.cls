@isTest
public with sharing class CloneInvoiceControllerTest {

    @isTest static void closedOpportunityTest() {

        Map<String, String> accOpp = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('5', accOpp.get('Opportunity'), accOpp.get('Account'));
        List<Product2> products = Int_TestCreateObject.createProducts(2);
        Int_TestCreateObject.createInvoicesProduct('5', products);

        String invoiceIdClone = CloneInvoiceController.cloneInvoice(invoiceId);

        List<Invoice__c> invoices = [SELECT Id, Opportunity__c, Account__c FROM Invoice__c WHERE Id = :invoiceIdClone];

        System.assertEquals(1, invoices.size());
        System.assertEquals(accOpp.get('Opportunity'), invoices.get(0).Opportunity__c);
        System.assertEquals(accOpp.get('Account'), invoices.get(0).Account__c);
    }
}