/**
 * Created by max1m on 12.01.21.
 */

trigger ContactTrigger on Contact (after update) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        Handler.contactAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}