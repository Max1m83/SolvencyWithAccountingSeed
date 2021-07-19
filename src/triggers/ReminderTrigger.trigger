/**
 * Created by max1m on 1.06.21.
 */

trigger ReminderTrigger on Reminder_email__c (before insert, before update, before delete) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        Handler.reminderEmailBeforeUpdate(Trigger.oldMap,Trigger.newMap);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        Handler.reminderEmailBeforeInsert(Trigger.new);
    }
}