/**
 * Created by max1m on 15.12.20.
 */

public with sharing class ChangeBillingLabel {

    @AuraEnabled
    public static String getBillingOrigin(String billId) {
        return getBillingNumber(billId);
    }

    public static String getBillingNumber(String billId) {
        Invoice__c billing = [SELECT Id,Invoice__c FROM Invoice__c WHERE Id = :billId];
        return billing.Invoice__c ;
    }
}