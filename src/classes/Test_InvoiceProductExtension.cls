@isTest
public with sharing class Test_InvoiceProductExtension {

    @isTest static void InvoiceProductExtensionTest() {
        Int_TestCreateObject.createInvoices(new List<String>{
                '2'
        });
        List<Product2> products = Int_TestCreateObject.createProducts(2);
        Int_TestCreateObject.createInvoicesProduct('2', products);

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController([SELECT Id FROM Invoice__c LIMIT 1]);
        InvoiceProductExtension prod = new InvoiceProductExtension(sc);
        Test.stopTest();

        System.assertEquals(2, prod.billLines.size());
    }
}