public with sharing class OpportunityUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {

    public static String BATCH_NAME = 'Opportunity Updater Batch';
    private static final Map<Integer, Integer> MONTH_QUARTER = new Map<Integer, Integer>{
            1 => 1,
            2 => 1,
            3 => 1,
            4 => 2,
            5 => 2,
            6 => 2,
            7 => 3,
            8 => 3,
            9 => 3,
            10 => 4,
            11 => 4,
            12 => 4
    };

    public Database.QueryLocator start(Database.BatchableContext context) {

        String query = 'SELECT Id, Name, Amounts_in_currency__c, Last12_months_invoiced__c, CurrencyIsoCode, Invoices_Ytd_local__c, Invoices_12_months_rolling_local__c, Invoices_Annual_forecast_local__c, Invoices_last_completed_Q_local__c, Sum_amounts_quar__c, Ytd_invoiced_amount__c FROM Opportunity';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Opportunity> opportunities) {

        System.debug(opportunities);

        Set<Id> oppIds = new Set<Id>();
        List<Id> quarterAccounting = new List<Id>();
        List<Id> thisYearAccounting = new List<Id>();
        List<Id> lastYearAccounting = new List<Id>();
        Set<Id> periodIds = new Set<Id>();
        Map<String, CurrencyType> curExist = new Map<String, CurrencyType>();
        List<Opportunity> updateOpportunity = new List<Opportunity>();
        Map<Id, List<Invoice__c>> invoicesMap = new Map<Id, List<Invoice__c>>();

        for (CurrencyType curr : [SELECT Id, ConversionRate, IsoCode FROM CurrencyType]) {
            curExist.put(curr.IsoCode, curr);
        }

        System.debug(curExist);

        Date nowDay = Date.today();
        System.debug('nowDay-->' + nowDay);
        Date threeMounthAgo = Date.today().addMonths(-3);
        System.debug('threeMounthAgo-->' + threeMounthAgo);
        String quarter = String.valueOf(MONTH_QUARTER.get(threeMounthAgo.month()));
        System.debug('threeMounthAgo.month()--->' + threeMounthAgo.month());
        System.debug('quarter--->' + quarter);
        Integer years = threeMounthAgo.year();
        System.debug('years--->' + years);
        Integer thisYear = nowDay.year();
        System.debug('thisYear--->' + thisYear);

        for (Opportunity opp : opportunities) {
            oppIds.add(opp.Id);
            invoicesMap.put(opp.Id, new List<Invoice__c>());
        }

        System.debug(invoicesMap);
        System.debug(oppIds);

        for (Invoice__c invoice : [
                SELECT Id, Accounting_period_Invoice__c, Date__c, Total_with_Discount__c, Opportunity__c
                FROM Invoice__c
                WHERE Opportunity__c IN :oppIds
        ]) {
            periodIds.add(invoice.Accounting_period_Invoice__c);
            invoicesMap.get(invoice.Opportunity__c).add(invoice);
        }

        System.debug(periodIds);
        System.debug(invoicesMap);

        for (Accounting_Period__c period : [
                SELECT Id, Name, Status__c, Start_Date__c, End_Date__c
                FROM Accounting_Period__c
                WHERE Id IN:periodIds
        ]) {

            if (String.valueOf(MONTH_QUARTER.get(period.End_Date__c.month())) == quarter
                    &&
                    period.End_Date__c.year() == years) {
                quarterAccounting.add(period.Id);
            }

            if (period.End_Date__c.year() == thisYear) {
                thisYearAccounting.add(period.Id);
            }

            if (period.End_Date__c > nowDay.addYears(-1) ||
                    (period.End_Date__c.month() == nowDay.month() && period.End_Date__c.year() == nowDay.addYears(-1).year())) {
                lastYearAccounting.add(period.Id);
            }
        }
        System.debug('quarterAccounting--->' + quarterAccounting);
        System.debug('thisYearAccounting--->' + thisYearAccounting);
        System.debug('lastYearAccounting--->' + lastYearAccounting);

        for (Opportunity opp : opportunities) {

            System.debug(opp.Name);

            Double summThisYears = 0;
            Double summLastQuat = 0;
            Double summLastYear = 0;
            Double sumInvoice = 0;

            for (Invoice__c invoice : invoicesMap.get(opp.Id)) {

                sumInvoice += invoice.Total_with_Discount__c;

//------------------Counting amounts from Last Quarter
                if (quarterAccounting.contains(invoice.Accounting_period_Invoice__c)) {
                    summLastQuat += invoice.Total_with_Discount__c;
                    System.debug('summLastQuat-->' + summLastQuat);
                }

//------------------Counting amounts from the beginning of the year
                if (thisYearAccounting.contains(invoice.Accounting_period_Invoice__c)) {
                    summThisYears += invoice.Total_with_Discount__c;
                    System.debug('summThisYears-->' + summThisYears);
                }

////------------------Last 12 months invoiced amount: sum of all invoices from the last 12 months
                if (lastYearAccounting.contains(invoice.Accounting_period_Invoice__c)) {
                    summLastYear += invoice.Total_with_Discount__c;
                    System.debug('summLastYear-->' + summLastYear);
                }
            }

            opp.Ytd_invoiced_amount__c = summThisYears;
            opp.Amounts_in_currency__c = sumInvoice;
            opp.Sum_amounts_quar__c = summLastQuat;
            opp.Last12_months_invoiced__c = summLastYear;

            System.debug(opp.Ytd_invoiced_amount__c);
            System.debug(opp.Amounts_in_currency__c);
            System.debug(opp.Sum_amounts_quar__c);
            System.debug(opp.Last12_months_invoiced__c);

            CurrencyType cur = curExist.get(opp.CurrencyIsoCode);

            if (cur.ConversionRate != null || cur.ConversionRate != 0) {

                opp.Invoices_12_months_rolling_local__c = 'CHF ' + (opp.Last12_months_invoiced__c / cur.ConversionRate).setscale (2).format();
                opp.Invoices_Annual_forecast_local__c = 'CHF ' + ((opp.Sum_amounts_quar__c * 4) / cur.ConversionRate).setscale (2).format();
                opp.Invoices_last_completed_Q_local__c = 'CHF ' + (opp.Sum_amounts_quar__c / cur.ConversionRate).setscale (2).format();
                opp.Invoices_Ytd_local__c = 'CHF ' + (opp.Ytd_invoiced_amount__c / cur.ConversionRate).setscale (2).format();
            }

            updateOpportunity.add(opp);
        }

        update updateOpportunity;
    }

    public void finish(Database.BatchableContext context) {

        String CRON_EXP = '0 0 * * * ?';

        List<CronTrigger> scheduleInProgress1 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :BATCH_NAME + '1'
                LIMIT 1
        ];

        if (!scheduleInProgress1.isEmpty()) {
            System.abortJob(scheduleInProgress1.get(0).Id);
        }

        List<CronTrigger> scheduleInProgress2 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :BATCH_NAME + '2'
                LIMIT 1
        ];

        if (!scheduleInProgress2.isEmpty()) {
            System.abortJob(scheduleInProgress2.get(0).Id);
        }

        List<CronTrigger> scheduleInProgress3 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :BATCH_NAME + '3'
                LIMIT 1
        ];

        if (!scheduleInProgress3.isEmpty()) {
            System.abortJob(scheduleInProgress3.get(0).Id);
        }

        List<CronTrigger> scheduleInProgress4 = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :BATCH_NAME + '4'
                LIMIT 1
        ];

        if (!scheduleInProgress4.isEmpty()) {
            System.abortJob(scheduleInProgress4.get(0).Id);
        }

        System.schedule(BATCH_NAME + '1', '0 0 * * * ?', new OpportunityUpdaterScheduler());
        System.schedule(BATCH_NAME + '2', '0 15 * * * ?', new OpportunityUpdaterScheduler());
        System.schedule(BATCH_NAME + '3', '0 30 * * * ?', new OpportunityUpdaterScheduler());
        System.schedule(BATCH_NAME + '4', '0 45 * * * ?', new OpportunityUpdaterScheduler());
    }
}