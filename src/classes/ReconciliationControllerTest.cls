@isTest
public with sharing class ReconciliationControllerTest {

    @isTest static void controllerPositive() {

        Map<String, String> statusMap = new Map<String, String>();

        Int_TestCreateObject.createBatchIndex('Invoice', 15);
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('invoice', 'Get', 'success'));

        List<CronTrigger> scheduleInProgress1 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection'
                LIMIT 2
        ];

        if (!scheduleInProgress1.isEmpty()) {
            System.abortJob(scheduleInProgress1.get(0).Id);
        }

        List<CronTrigger> scheduleInProgress2 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
                LIMIT 2
        ];

        if (scheduleInProgress2.size() > 1) {
            System.abortJob(scheduleInProgress2.get(1).Id);
        }

        Test.startTest();
        statusMap = ReconciliationController.updateAllInvoices();
        Test.stopTest();

        System.assertEquals('Success', statusMap.get('Status'));
    }

    @isTest static void controllerNegative() {

        Map<String, String> statusMap = new Map<String, String>();

        Int_TestCreateObject.createBatchIndex('Invoice', 15);
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('', 'Get', 'error'));

        List<CronTrigger> scheduleInProgress1 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection'
                LIMIT 2
        ];

        if (!scheduleInProgress1.isEmpty()) {
            System.abortJob(scheduleInProgress1.get(0).Id);
        }

        List<CronTrigger> scheduleInProgress2 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
                LIMIT 2
        ];

        if (scheduleInProgress2.size() > 1) {
            System.abortJob(scheduleInProgress2.get(1).Id);
        }

        Test.startTest();
        statusMap = ReconciliationController.updateAllInvoices();
        Test.stopTest();

        System.assertEquals('Success', statusMap.get('Status'));
    }
}