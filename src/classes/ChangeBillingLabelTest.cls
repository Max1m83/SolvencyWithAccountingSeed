/**
 * Created by max1m on 18.12.20.
 */
@isTest
public with sharing class ChangeBillingLabelTest {

    @isTest static void getBillingOriginTest() {

        Int_TestCreateObject.createInvoices(new List<String>{'1'});

        Invoice__c invoice = [SELECT Id, Invoice__c FROM Invoice__c WHERE Bexio_Id__c = '1'];
        System.assertEquals(invoice.Invoice__c, ChangeBillingLabel.getBillingOrigin(invoice.Id));
    }
}