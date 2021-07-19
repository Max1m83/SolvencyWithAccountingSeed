@isTest
public with sharing class Int_BatchTest {

    @isTest static void invoiceUpdateBatchPositive() {

        Int_TestCreateObject.createBatchIndex('Invoice', -15);

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'InvoiceUpdate`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceUpdateBatch());
        Test.stopTest();

        System.assertEquals('1', [SELECT Bexio_Id__c FROM Invoice__c LIMIT 1].Bexio_Id__c);
    }

    @isTest static void paymentBatchStatusPositive() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('paymentInvoice', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'InvoicePayment`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_PaymentBatch());
        Test.stopTest();

        System.assertEquals(date.valueOf('2021-05-06 00:00:00'), [SELECT Payment_Date__c FROM Invoice__c LIMIT 1].Payment_Date__c);
    }

    @isTest static void invoiceUpdateBatchStatusPositive() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('UpdateInvoiceStatus', 'POST', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'InvoiceUpdate`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createInvoices(new List<String>{
                '1', '2'
        });

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceUpdateBatch());
        Test.stopTest();

        System.assertEquals('1', [SELECT Bexio_Id__c FROM Invoice__c LIMIT 1].Bexio_Id__c);
    }

    @isTest static void controllerPositive() {

        Int_TestCreateObject.createBatchIndex('Invoice', 15);

        System.assertEquals(0, [
                SELECT Id, NextFireTime, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection' OR CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
        ].size());

        Test.startTest();
        Int_BatchController.controlBatch();
        Test.stopTest();

        System.assertEquals(2, [
                SELECT Id, NextFireTime, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection' OR CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
        ].size());
    }

    @isTest static void defaultSchedulerBatch() {

        System.assertEquals(0, [
                SELECT Id, NextFireTime, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection' OR CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
        ].size());

        Test.startTest();
        Int_BatchController.createDefaultSchedulerBatch();
        Test.stopTest();

        System.assertEquals(2, [
                SELECT Id, NextFireTime, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection' OR CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
        ].size());
    }

    @isTest static void GetInvoicePositive() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('invoice', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Invoice`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createAccounts(new List<String>{
                '3', '5'
        });

        System.assertEquals(0, [SELECT COUNT() FROM Invoice__c]);

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceBatch());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Invoice__c]);
    }

    @isTest static void GetInvoiceNegative() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('invoice', 'Get', 'error'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Invoice`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        System.assertEquals(0, [SELECT COUNT() FROM Invoice__c]);

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceBatch());
        Test.stopTest();

        //System.assertEquals(2, [SELECT COUNT() FROM Invoice__c]);
    }

    @isTest static void GetInvoiceProductPositive() {

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Invoice Product', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Product`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createInvoices(new List<String>{
                '1'
        });

        System.assertEquals(1, [SELECT COUNT() FROM Invoice__c]);

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceBatchProduct());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Invoice_Product__c]);
    }

    @isTest static void invoiceUpdateBatchAmountPositive() {

        Int_TestCreateObject.createBatchIndex('Invoice', -15);

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'InvoiceUpdate`s Batch'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        Int_TestCreateObject.createInvoices(new List<String>{
                '1', '2'
        });

        Test.startTest();
        Id batchId = Database.executeBatch(new Int_InvoiceUpdateBatchAmount());
        Test.stopTest();

        System.assertEquals('1', [SELECT Bexio_Id__c FROM Invoice__c LIMIT 1].Bexio_Id__c);
    }

    @isTest static void invoiceUpdateBatchAmountProductPositive() {

        Int_TestCreateObject.createCredentials('Token');

        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('Update Invoice', 'Get', 'success'));

        Int_TestCreateObject.createInvoices(new List<String>{
                '1', '2'
        });

        Test.startTest();
        List<Invoice_Product__c> prods = Int_Helper_Res.getInvoiceProduct('1');
        Test.stopTest();

        System.assertEquals(250, prods.get(0).Unit_Price__c);
    }

    @isTest static void accountPUTQueueablePositive() {

        Int_TestCreateObject.createCredentials('Token');
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('create Account', 'POST', 'success'));

        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Company_name__c = 'Company';
        acc.isBexio__c = true;
        acc.BillingStreet = '520 BillingStreet';
        acc.BillingPostalCode = '8001';
        acc.BillingCity = 'Brest';
        acc.Account_Email__c = 'test@test.com';
        acc.Phone = '+375297253679';

        Test.startTest();
        insert acc;
        Test.stopTest();

        System.assertEquals('8', [SELECT Bexio_Id__c, Company_name__c, BillingStreet, BillingPostalCode, BillingCity, Account_Email__c, Phone FROM Account].get(0).Bexio_Id__c);
    }
}