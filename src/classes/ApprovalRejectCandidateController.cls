/**
 * Created by max1m on 23.06.21.
 */

public with sharing class ApprovalRejectCandidateController {

    @AuraEnabled
    public static String approve(String idJobApplication) {

        List<Job_Application__c> candidates = [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: idJobApplication];

        if (candidates.size() > 0) {
            candidates.get(0).Stage_Progress__c = 'Approved';
            update candidates;
            return 'Success';
        } else {
            return 'Error';
        }
    }

    @AuraEnabled
    public static String rejected(String idJobApplication) {

        List<Job_Application__c> candidates = [SELECT Stage_Progress__c FROM Job_Application__c WHERE Id =: idJobApplication];

        if (candidates.size() > 0) {
            candidates.get(0).Stage_Progress__c = 'Rejected';
            update candidates;
            return 'Success';
        } else {
            return 'Error';
        }
    }
}