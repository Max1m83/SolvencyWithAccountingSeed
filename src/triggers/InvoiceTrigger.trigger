/**
 * Created by max1m on 15.03.21.
 */

trigger InvoiceTrigger on Invoice__c (after insert, before update, after update, after delete, before insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        Handler.invoiceTriggerAfterInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        Handler.invoiceTriggerBeforeInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Trigger');
        Handler.invoiceTriggerAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}