/**
 * Created by max1m on 18.03.21.
 */

trigger InvoiceProductTrigger on Invoice_Product__c (after insert, after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        Handler.invoiceProductAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        Handler.invoiceProductAfterInsert(Trigger.newMap);
    }
}