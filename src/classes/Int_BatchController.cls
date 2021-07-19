public with sharing class Int_BatchController {

    public static void controlBatch() {

        DateTime currentDateTime = Datetime.now();
        List<BatchIndex__c> batchList = [
                SELECT Id,Last_Batch_Date__c, Next_Batch_Date__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c
                FROM BatchIndex__c
                WHERE Object__c = 'Invoice' AND (Next_Batch_Date__c < :currentDateTime
                OR Next_Batch_Date__c = null) AND isActive__c = true
        ];

        if (batchList.size() > 0) {

            if (batchList.get(0).Object__c == 'Invoice') {
                if (!Test.isRunningTest()) {
                    System.scheduleBatch(new Int_InvoiceUpdateBatchAmount(), 'InvoiceUpdate`s Batch', 1, 1);
                }
            }

        } else {
            createSchedulerBatch();
        }
    }

    public static void createSchedulerBatch() {

        List<BatchIndex__c> batchIndexList = [
                SELECT Id,Last_Batch_Date__c, Next_Batch_Date__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c
                FROM BatchIndex__c
        ];

        if (batchIndexList.size() > 0 || Test.isRunningTest()) {
            Datetime timeSchedule;
            Datetime timeSchedule2;

            if (Test.isRunningTest()) {
                timeSchedule = Datetime.now().addMinutes(10);
                timeSchedule2 = Datetime.now().addHours(2);

            } else {
                timeSchedule = batchIndexList.get(0).Next_Batch_Date__c > Datetime.now().addMinutes(10) ? batchIndexList.get(0).Next_Batch_Date__c : Datetime.now().addMinutes(10);
                timeSchedule2 = batchIndexList.get(0).Next_Batch_Date__c > Datetime.now().addHours(2) ? batchIndexList.get(0).Next_Batch_Date__c.addHours(2) : Datetime.now().addHours(2);
            }

            if (timeSchedule != null) {

                Int_inSettingsController.deleteScheduler();

                String year = String.valueOf(timeSchedule.year());
                String month = String.valueOf(timeSchedule.month());
                String day = String.valueOf(timeSchedule.day());
                String hour = String.valueOf(timeSchedule.hour());
                String minute = String.valueOf(timeSchedule.minute());
                String sec = String.valueOf(timeSchedule.second());

                String CRON_EXP = sec + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ' + '?' + ' ' + year;
                String CRON_EXP2 = String.valueOf(timeSchedule2.second()) + ' ' +
                        String.valueOf(timeSchedule2.minute()) + ' ' + String.valueOf(timeSchedule2.hour()) + ' ' +
                        String.valueOf(timeSchedule2.day()) + ' ' + String.valueOf(timeSchedule2.month()) + ' ' + '?' + ' ' + String.valueOf(timeSchedule2.year());

                Int_BexioScheduler scheduler = new Int_BexioScheduler();
                String jobID = system.schedule('Bexio Schedule Connection', CRON_EXP, scheduler);
                String jobID2 = system.schedule('Bexio Schedule Connection Reservation', CRON_EXP2, scheduler);

            } else {
                createDefaultSchedulerBatch();
            }

        } else {
            createDefaultSchedulerBatch();
        }
    }

    public static void createDefaultSchedulerBatch() {

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'Bexio Schedule Connection' OR CronJobDetail.Name = :'Bexio Schedule Connection Reservation'
                LIMIT 2
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }

        if (scheduleInProgress.size() > 1) {
            System.abortJob(scheduleInProgress.get(1).Id);
        }

        Datetime now = Datetime.now().addMinutes(10);
        Int_BexioScheduler scheduler = new Int_BexioScheduler();
        String CRON_EXP = string.valueOf(now.format('s m H d M ?'));
        String jobID = system.schedule('Magento Schedule Connection', CRON_EXP, scheduler);
    }
}