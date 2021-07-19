/**
 * Created by max1m on 23.06.21.
 */

trigger CandidateTrigger on Candidate__c (before insert, before update) {
    if (Trigger.isInsert && Trigger.isBefore) {
        Handler.candidateBeforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        Handler.candidateBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}