/**
 * Created by max1m on 26.10.20.
 */

trigger AccountTrigger on Account (before insert, before update, after insert) {

    if (Trigger.isInsert && Trigger.isBefore) {
        Handler.accountTriggerInsertBefore(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        Int_Handler.accountTriggerInsertAfter(Trigger.new);
    }
}