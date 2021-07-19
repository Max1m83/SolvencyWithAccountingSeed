/**
 * Created by max1m on 22.01.21.
 */

trigger JobApplicationTrigger on Job_Application__c (before insert, before update, after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        Handler.jobApplicationUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        Handler.jobApplicationBeforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        Handler.jobApplicationBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}