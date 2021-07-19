/**
 * Created by max1m on 04.05.21.
 */

public with sharing class ReconciliationController {

    @AuraEnabled
    public static Map<String, String> updateAllInvoices() {

        Map<String, String> returnMap = new Map<String, String>();

        List<BatchId__c> batches = [SELECT InvoiceId__c, Start_Date__c, isWork__c, Finish_Date__c FROM BatchId__c];

        if (batches.size() > 0 && batches.get(0).isWork__c) {
            Id batchId = Database.executeBatch(new Int_ReconciliationInvoiceBatch());
            returnMap.put('Status', 'Success');
        } else {
            returnMap.put('Status', 'Error');
        }

        return returnMap;
    }
}