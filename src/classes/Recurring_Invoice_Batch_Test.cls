/**
 * Created by max1m on 4.06.21.
 */
@isTest
public with sharing class Recurring_Invoice_Batch_Test {

    @isTest static void recurringInvoiceBatchTest() {

        String recId = Int_TestCreateObject.createRecurringInvoice(Date.today().addDays(-2));
        System.assertEquals(0, [SELECT Id FROM Invoice__c WHERE Recurring_Invoice__c = :recId].size());

        Test.startTest();
        Id batchId = Database.executeBatch(new Recurring_Invoice_Batch());
        Test.stopTest();

        System.debug([SELECT Id FROM Invoice__c WHERE Recurring_Invoice__c = :recId]);
        System.assertEquals(1, [SELECT Id FROM Invoice__c WHERE Recurring_Invoice__c = :recId].size());
    }
}