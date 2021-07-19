/**
 * Created by max1m on 17.02.21.
 */

public with sharing class SchedulerSettingsController {

    @AuraEnabled
    public static Map<String, Object> getScheduler() {

        return getAllScheduler ();
    }

    @AuraEnabled
    public static Map<String, Object> deleteScheduler(String cronId) {

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE Id = :cronId
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {

            System.abortJob(scheduleInProgress.get(0).Id);
        }

        return getAllScheduler ();
    }

    private static Map<String, Object> getAllScheduler() {

        Map<String, Object> returnMap = new Map<String, Object>();

        List<CronTrigger> listCronTrigger = [
                SELECT Id, NextFireTime, CronJobDetail.Name
                FROM CronTrigger
        ];

        if (listCronTrigger.size() > 0) {
            returnMap.put('Status', 'Success');
            List<Object> listObjects = new List<Object>();
            for (CronTrigger cron : listCronTrigger) {

                Map<String, String> objectStrings = new Map<String, String>();
                objectStrings.put('NextDate', String.valueOf(cron.NextFireTime));

                objectStrings.put('JsDate', cron.NextFireTime.year() + '-' +
                        (cron.NextFireTime.month() < 10 ? '0' + String.valueOf(cron.NextFireTime.month()) : String.valueOf(cron.NextFireTime.month())) + '-' +
                        cron.NextFireTime.day() + 'T' +
                        cron.NextFireTime.addHours(-1).hour() + ':' +
                        (cron.NextFireTime.minute() == 0 ? '00' : String.valueOf(cron.NextFireTime.minute())) +
                        ':00.789Z');
                objectStrings.put('cronId', cron.Id);

                try {
                    objectStrings.putAll(getCandidate(Id.valueOf(cron.CronJobDetail.Name.substring(cron.CronJobDetail.Name.indexOf('(') + 1,
                            cron.CronJobDetail.Name.indexOf(')')))));
                    listObjects.add(objectStrings);
                } catch (Exception e) {

                }
            }
            returnMap.put('Body', listObjects);

        } else {
            returnMap.put('Status', 'Success');
            returnMap.put('Body', '');
        }
        return returnMap;
    }

    private static Map<String, String> getCandidate(Id jobId) {

        Map<String, String> returnMap = new Map<String, String>();
        List<Job_Application__c> jobs = [SELECT Id, Candidate__c, Picklist__c, Position__c, Position__r.Name FROM Job_Application__c WHERE Id = :jobId];

        if (jobs.size() > 0) {

            List<Candidate__c> listCandidate = [SELECT Id, Last_Name__c, First_Name__c FROM Candidate__c WHERE Id = :jobs.get(0).Candidate__c];

            if (listCandidate.size() > 0) {
                returnMap.put('Status', 'Success');
                Candidate__c candidate = listCandidate.get(0);
                returnMap.put('Name', candidate.Last_Name__c + ' ' + candidate.First_Name__c);
                returnMap.put('Position', jobs.get(0).Position__r.Name);
                returnMap.put('Stage', jobs.get(0).Picklist__c);
                returnMap.put('IdCandidate', candidate.Id);
                returnMap.put('IdJob', jobs.get(0).Id);
                returnMap.put('IdPosition', jobs.get(0).Position__c);

            } else {
                returnMap.put('Status', 'Error');
            }
        } else {
            returnMap.put('Status', 'Error');
        }
        return returnMap;
    }

    private static Map<String, String> getInvoice(Id jobId) {

        Map<String, String> returnMap = new Map<String, String>();
        List<Job_Application__c> jobs = [SELECT Id, Candidate__c, Picklist__c, Position__c, Position__r.Name FROM Job_Application__c WHERE Id = :jobId];

        if (jobs.size() > 0) {

            List<Candidate__c> listCandidate = [SELECT Id, Last_Name__c, First_Name__c FROM Candidate__c WHERE Id = :jobs.get(0).Candidate__c];

            if (listCandidate.size() > 0) {
                returnMap.put('Status', 'Success');
                Candidate__c candidate = listCandidate.get(0);
                returnMap.put('Name', candidate.Last_Name__c + ' ' + candidate.First_Name__c);
                returnMap.put('Position', jobs.get(0).Position__r.Name);
                returnMap.put('Stage', jobs.get(0).Picklist__c);
                returnMap.put('IdCandidate', candidate.Id);
                returnMap.put('IdJob', jobs.get(0).Id);
                returnMap.put('IdPosition', jobs.get(0).Position__c);

            } else {
                returnMap.put('Status', 'Error');
            }
        } else {
            returnMap.put('Status', 'Error');
        }
        return returnMap;
    }
}