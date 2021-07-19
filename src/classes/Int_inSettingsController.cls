public with sharing class Int_inSettingsController {

    @AuraEnabled
    public static String checkIsValidAccessToken(String token) {

        String result = getCallout(token);

        List<Bexio__c> credentials = [SELECT Token__c FROM Bexio__c LIMIT 1];
        Bexio__c cred;

        if (credentials.size() > 0) {
            cred = credentials.get(0);
        } else {
            cred = new Bexio__c();
        }

        cred.Token__c = token;

        if (!Test.isRunningTest()) {
            upsert cred;
        }

        return result;
    }


    @AuraEnabled
    public static Map<String, String> getSetting() {

        Map<String, String> settings = new Map<String, String>();
        settings.put('Status', 'success');
        List<Bexio__c> credentials = [SELECT Token__c FROM Bexio__c LIMIT 1];
        List<Bexio_Log__c> logs = [SELECT CreatedDate FROM Bexio_Log__c ORDER BY CreatedDate DESC LIMIT 1];
        List<BatchIndex__c> indexButch = getBatchIndex();

        if (credentials.size() > 0) {
            settings.put('token', credentials.get(0).Token__c);
            settings.put('authorized', getCallout(credentials.get(0).Token__c));
        } else {
            settings.put('token', '');
            settings.put('authorized', 'Unauthorized');
        }

        settings.put('nextTime', correctDateString(getNextTimeBatch(indexButch)));
        settings.put('frequency', indexButch.size() > 0 ? (indexButch.get(0).isActive__c ? String.valueOf(indexButch.get(0).Sync_Interval_Minutes__c) : 'not') : 'not');

        if (logs.size() > 0) {
            settings.put('lastTime', correctDateString(logs.get(0).CreatedDate));
        }

        return settings;
    }

    @AuraEnabled
    public static String schedulerUpdate(String hourlyFrequency) {

        String result = 'Success';

        List<BatchIndex__c> indexBatch = getBatchIndex();
        if (hourlyFrequency == 'not' || String.isBlank(hourlyFrequency)) {

            deleteScheduler();
            indexBatch.get(0).Sync_Interval_Minutes__c = 0;
            indexBatch.get(0).isActive__c = false;
            indexBatch.get(0).Next_Batch_Date__c = null;
            update indexBatch.get(0);

        } else {

            if (indexBatch.size() > 0) {

                indexBatch.get(0).Sync_Interval_Minutes__c = Integer.valueOf(hourlyFrequency);
                indexBatch.get(0).isActive__c = true;
                indexBatch.get(0).Next_Batch_Date__c = Datetime.now().addMinutes(Integer.valueOf(indexBatch.get(0).Sync_Interval_Minutes__c));
                update indexBatch.get(0);
                Int_BatchController.controlBatch();
            } else {
                result = 'Not Activated';
            }
        }

        return (indexBatch.size() > 0 ? correctDateString(getNextTimeBatch(indexBatch)) : result);
    }

    public static void deleteScheduler() {

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection'
                LIMIT 1
        ];

        List<CronTrigger> scheduleInProgressReservation = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        if (!scheduleInProgressReservation.isEmpty()) {
            System.abortJob(scheduleInProgressReservation.get(0).Id);
        }
    }

    private static List<BatchIndex__c> getBatchIndex() {
        return [
                SELECT Id, Last_Batch_Date__c, Next_Batch_Date__c, isActive__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c
                FROM BatchIndex__c
                WHERE Object__c = 'Invoice' AND isActive__c = true
        ];
    }

    private static String correctDateString(Datetime correct) {
        return (correct != null ? ((correct.hour() < 10 ? '0' + String.valueOf(correct.hour()) : String.valueOf(correct.hour())) + ':' +
                (correct.minute() < 10 ? '0' + String.valueOf(correct.minute()) : String.valueOf(correct.minute())) + ' ' +
                correct.year() + '-' +
                (correct.month() < 10 ? '0' + String.valueOf(correct.month()) : String.valueOf(correct.month())) + '-' +
                (correct.day() < 10 ? '0' + String.valueOf(correct.day()) : String.valueOf(correct.day()))) : '');
    }

    private static Datetime getNextTimeBatch(List<BatchIndex__c> indexBatch) {

        return indexBatch.size() > 0 ? (indexBatch.get(0).isActive__c ? (indexBatch.get(0).Next_Batch_Date__c != null ? indexBatch.get(0).Next_Batch_Date__c : null) : null) : null;
    }

    @AuraEnabled
    public static String syncNow() {

        List<BatchIndex__c> indexBatch = getBatchIndex();
        String result = 'Success';

        if (indexBatch.size() > 0) {

            indexBatch.get(0).isActive__c = true;
            indexBatch.get(0).Next_Batch_Date__c = Datetime.now().addMinutes(-1);
            update indexBatch.get(0);

            if (!Test.isRunningTest()) {
                System.scheduleBatch(new Int_InvoiceUpdateBatch(), 'Update Batch', 1, 1);
            }

        } else {
            result = 'Not Activated';
        }
        return result;
    }

    private static String getCallout(String token) {

        String returnStatus;
        String credential = 'BexioStore';
        String auth = 'Bearer ' + token;
        String apiEndpoint = 'callout:' + credential + '/3.0/banking/payments';

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', 'application/json');
        req.setMethod('GET');
        req.setEndpoint(apiEndpoint);
        req.setTimeout(120000);

        Http sendHttp = new Http();

        try {
            HttpResponse res = sendHttp.send(req);
            if (res.getStatus() == 'OK') {
                returnStatus = 'Success';
            } else if (res.getStatus() == 'Unauthorized') {
                returnStatus = 'Unauthorized';
            } else {
                returnStatus = 'Error';
            }

        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
            System.debug('Line Number: ' + ex.getLineNumber());
        }

        return returnStatus;
    }
}