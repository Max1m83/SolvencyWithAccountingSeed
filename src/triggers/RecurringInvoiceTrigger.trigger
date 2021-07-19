/**
 * Created by max1m on 27.05.21.
 */

trigger RecurringInvoiceTrigger on Recurring_Invoice__c (before insert, before update, after insert, after update) {

    if (Trigger.isInsert && Trigger.isBefore) {
        Handler.recurringInvoiceBeforeInsert(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        Handler.recurringInvoiceBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}