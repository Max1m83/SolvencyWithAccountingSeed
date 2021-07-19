/**
 * Created by max1m on 27.07.20.
 */

public with sharing class EgnyteController {

    @AuraEnabled
    public static Map <String, String> getURL(Id opportunityId) {

        Map <String, String> getMap = new Map<String, String> ();
        List<Opportunity> opportunities = [SELECT Id, UrlClientContracts__c, UrlStandardContracts__c, StageName FROM Opportunity WHERE Id = :opportunityId];

        getMap.put('Standard', opportunities.get(0).UrlStandardContracts__c == null ? '' : opportunities.get(0).UrlStandardContracts__c);
        getMap.put('Client', opportunities.get(0).UrlClientContracts__c == null ? '' : opportunities.get(0).UrlClientContracts__c);

        if (opportunities.get(0).StageName == 'Hand-shake agreement' || opportunities.get(0).StageName == 'Closed Won') {
            getMap.put('Record', 'ongoing business');
        } else {
            getMap.put('Record', 'Sales');
        }

        return getMap;
    }
}