/**
 * Created by max1m on 23.12.20.
 */

trigger ContactEntityTrigger on Contact_entity__c (after insert, after update, after delete) {

    if (Trigger.isInsert && Trigger.isAfter) {
        Handler.contactEntityTriggerInsertAfter(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        System.debug('Contact_entity__c');
        Handler.contactEntityTriggerUpdateAfter(Trigger.new);
    }

    if (Trigger.isDelete && Trigger.isAfter) {
        Handler.contactEntityTriggerDeleteAfter(Trigger.old);
    }
}