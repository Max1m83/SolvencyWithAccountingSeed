public with sharing class StatusEmailController {

    @AuraEnabled
    public static Map<String, Object> getEmailLogs() {

        Map<String, Object> returnMap = new Map<String, Object>();
        List<Object> listObjects = new List<Object>();
        List<Object> listErrorObjects = new List<Object>();

        for (Email_log__c log : [
                SELECT Id, Position__c, Email_Status__c, Status__c, Candidate__c, Sending_time__c
                FROM Email_log__c
                ORDER BY Sending_time__c DESC
                LIMIT 30
        ]) {
            Map<String, String> logs = new Map<String, String>();
            logs.put('Name', log.Candidate__c);
            logs.put('Position', log.Position__c);
            logs.put('Status', log.Email_Status__c);
            logs.put('Stage', log.Status__c);
            logs.put('Time', log.Sending_time__c.format('YYYY-MM-dd hh:mm:ss'));
            logs.put('TimeSort', log.Sending_time__c.format('YYYY-MM-dd'));
            listObjects.add(logs);

            if (log.Email_Status__c == 'Error') {
                listErrorObjects.add(logs);
            }
        }

        if (listObjects.size() > 0) {
            returnMap.put('Status', 'Success');
            returnMap.put('Emails', listObjects);
        } else {
            returnMap.put('Status', 'Success');
            returnMap.put('Emails', '');
        }

        if (listErrorObjects.size() > 0) {
            returnMap.put('EmailsError', listErrorObjects);
        } else {
            returnMap.put('EmailsError', '');
        }

        return returnMap;
    }
}