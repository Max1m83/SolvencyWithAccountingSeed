/**
 * Created by max1m on 19.08.20.
 */

trigger triggerBilling on AcctSeed__Billing__c (after insert, before insert, after update, before update, after delete) {

    if (Trigger.isDelete && Trigger.isAfter) {
        Handler.billingTriggerDeleteAfter(Trigger.old);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        Handler.billingTriggerInsertAfter(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        Handler.billingTriggerUpdateAfter(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        Handler.billingTriggerUpdateBefore(Trigger.newMap, Trigger.oldMap);
    }

    if (Trigger.isInsert && Trigger.isBefore) {
        Handler.billingTriggerInsertBefore(Trigger.new);
    }
}