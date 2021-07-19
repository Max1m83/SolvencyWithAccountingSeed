/**
 * Created by max1m on 02.11.20.
 */

trigger BillingProductTrigger on AcctSeed__Billing_Line__c (before insert, before update, after insert, after update) {

    if (Trigger.isInsert && Trigger.isBefore) {
        Handler.billingProductTriggerInsertBefore(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        Handler.billingProductTriggerInsertAfter(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        Handler.billingProductTriggerUpdateAfter(Trigger.newMap, Trigger.oldMap);
    }
}