/**
 * Created by max1m on 21.12.20.
 */

trigger InvoiceGroupTrigger on Contacts_for_Billing__c (after insert, before update, after update, before delete) {

    if (Trigger.isAfter && Trigger.isInsert) {
        Handler.contactForBillingAfterInsert(Trigger.newMap);
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        Handler.contactForBillingBeforeDelete(Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        Handler.contactForBillingBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Handler.contactForBillingAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}