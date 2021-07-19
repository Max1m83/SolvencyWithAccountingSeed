/**
 * Created by max1m on 18.01.21.
 */

public with sharing class CloseOpportunityController {

    @AuraEnabled
    public static List<String> setLostReasonOpportunity() {

        List<String> pickListValuesList = new List<String>();

        Schema.DescribeFieldResult fieldResult = Opportunity.LostReason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }

        return pickListValuesList;
    }

    @AuraEnabled
    public static String closedOpportunity(Id OppId, String reason) {

        Opportunity opp = [SELECT Id, LostReason__c, RecordTypeId FROM Opportunity WHERE Id = :OppId];

        opp.LostReason__c = reason;
        opp.StageName = 'Closed';
        opp.RecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Lost Opportunity').getRecordTypeId();

        update opp;

        return 'SUCCESS';
    }
}