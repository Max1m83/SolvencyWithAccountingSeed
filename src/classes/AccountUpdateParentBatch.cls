/**
 * Created by max1m on 04.09.20.
 */

public with sharing class AccountUpdateParentBatch implements Database.Batchable<SObject>, Database.Stateful {

    public static String BATCH_NAME = 'Account Updater Batch';

    public Database.QueryLocator start(Database.BatchableContext context) {

        String query = 'SELECT Id, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, Ytd_invoiced_amount__c FROM Account WHERE ParentId = null';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Account> accounts) {

        Set<Id> accIds = new Set<Id>();
        Map<Id, List<Account>> mapAcc = new Map<Id, List<Account>>();
        List<Account> updateAccount = new List<Account>();

        for (Account acc : accounts) {
                accIds.add(acc.Id);
        }

        for (Account acc : [SELECT Id, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, ParentId,
                             Sum_amounts_quar__c, Ytd_invoiced_amount__c FROM Account WHERE ParentId IN :accIds]) {

            List<Account> accList;
            if (mapAcc.containsKey(acc.ParentId)) {
                accList = mapAcc.get(acc.ParentId);
                accList.add(acc);
            } else {
                accList = new List<Account>();
            }
            mapAcc.put(acc.ParentId, accList);
        }

        for (Account acc : accounts) {

            Double invoiceTotal = 0;
            Double Invoice12months = 0;
            Double InvoiceQuartol = 0;
            Double InvoiceYtd = 0;

            System.debug(acc);
            System.debug(mapAcc.get(acc.Id));

            if (mapAcc.get(acc.Id) == null) {continue;}

            for (Account accRelated : mapAcc.get(acc.Id)) {

                if (accRelated == null) {continue;}
                if (accRelated.Invoice_Total__c != null) {invoiceTotal += accRelated.Invoice_Total__c;}
                if (accRelated.Last12_months_invoiced__c != null) {Invoice12months += accRelated.Last12_months_invoiced__c;}
                if (accRelated.Sum_amounts_quar__c != null) {InvoiceQuartol += accRelated.Sum_amounts_quar__c;}
                if (accRelated.Ytd_invoiced_amount__c != null) {InvoiceYtd += accRelated.Ytd_invoiced_amount__c;}
            }

            acc.Invoice_Total__c = invoiceTotal;
            acc.Last12_months_invoiced__c = Invoice12months;
            acc.Sum_amounts_quar__c = InvoiceQuartol;
            acc.Ytd_invoiced_amount__c = InvoiceYtd;
            updateAccount.add(acc);
        }

//        List<AcctSeed__Billing__c> billingList = [
//                SELECT Id, AcctSeed__Date__c, AcctSeed__Total__c, AcctSeed__Customer__c, AcctSeed__Accounting_Period__c
//                FROM AcctSeed__Billing__c
//                WHERE AcctSeed__Customer__c IN :accIds
//        ];
//
//        for (AcctSeed__Billing__c bill : billingList) {
//            according.add(bill.AcctSeed__Accounting_Period__c);
//        }
//
//        for (AcctSeed__Accounting_Period__c period : [
//                SELECT Id, Name, AcctSeed__Status__c, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
//                FROM AcctSeed__Accounting_Period__c
//                WHERE Id IN:according
//        ]) {
//            if (String.valueOf(MONTH_QUARTER.get(period.AcctSeed__End_Date__c.month())) == quarter
//                    &&
//                    period.AcctSeed__End_Date__c.year() == years) {
//                quarterAccounting.add(period.Id);
//            }
//
//            if (period.AcctSeed__End_Date__c.year() == thisYear) {
//                thisYearAccounting.add(period.Id);
//            }
//
//            if (period.AcctSeed__End_Date__c > nowDay.addYears(-1) ||
//                    (period.AcctSeed__End_Date__c.month() == nowDay.month() && period.AcctSeed__End_Date__c.year() == nowDay.addYears(-1).year())) {
//                lastYearAccounting.add(period.Id);
//            }
//        }
//
//        for (AcctSeed__Billing__c bill : billingList) {
//
//            if (billingsMap.containsKey(bill.AcctSeed__Customer__c)) {
//
//                List<AcctSeed__Billing__c> existBilling = billingsMap.get(bill.AcctSeed__Customer__c);
//                existBilling.add(bill);
//                billingsMap.remove(bill.AcctSeed__Customer__c);
//                billingsMap.put(bill.AcctSeed__Customer__c, existBilling);
//
//            } else {
//                List<AcctSeed__Billing__c> newBillings = new List<AcctSeed__Billing__c>();
//                newBillings.add(bill);
//                billingsMap.put(bill.AcctSeed__Customer__c, newBillings);
//            }
//        }
//
//        for (Account acc : accounts) {
//
//            Double summThisYears = 0;
//            Double summLastQuat = 0;
//            Double summLastYear = 0;
//
//            if (billingsMap.containsKey(acc.Id)) {
//
//                for (AcctSeed__Billing__c billing : billingsMap.get(acc.Id)) {
//
////------------------Counting amounts from Last Quarter
//                    if (quarterAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
//                        summLastQuat += billing.AcctSeed__Total__c;
//                    }
//
////------------------Counting amounts from the beginning of the year
//                    if (thisYearAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
//                        summThisYears += billing.AcctSeed__Total__c;
//                    }
//
//////------------------Last 12 months invoiced amount: sum of all invoices from the last 12 months
//                    if (lastYearAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
//                        summLastYear += billing.AcctSeed__Total__c;
//                    }
//
//                    acc.Ytd_invoiced_amount__c = summThisYears;
//                    acc.Sum_amounts_quar__c = summLastQuat;
//                    acc.Last12_months_invoiced__c = summLastYear;
//
//                }
//            }
//            updateAccount.add(acc);
//        }

        Database.upsert(updateAccount, false);
        System.debug(updateAccount);
    }

    public void finish(Database.BatchableContext context) {

//        AccountsUpdaterScheduler scheduler = new AccountsUpdaterScheduler();
//        String CRON_EXP = '0 0/10 0 ? * 1/1 *';

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

        System.schedule(BATCH_NAME + '1', '0 10 * * * ?', new AccountsUpdaterScheduler());
        System.schedule(BATCH_NAME + '2', '0 25 * * * ?', new AccountsUpdaterScheduler());
        System.schedule(BATCH_NAME + '3', '0 40 * * * ?', new AccountsUpdaterScheduler());
        System.schedule(BATCH_NAME + '4', '0 55 * * * ?', new AccountsUpdaterScheduler());
        // String jobID = System.schedule(BATCH_NAME, CRON_EXP, scheduler);
        //System.scheduleBatch(new AccountUpdateBatch(), 'Opp`s Batch', 1);
    }
}