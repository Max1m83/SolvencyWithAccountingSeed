public with sharing class AccountAnalyticsBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Integer step = 0;
    public static String BATCH_NAME = 'Account Updater Batch';
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

    public AccountAnalyticsBatch(Integer step) {
        this.step = step;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {

        String query = 'SELECT Id, Name, Invoice_Total__c, Last12_months_invoiced__c, CurrencyIsoCode,' +
                'Sum_invoice_year__c, Sum_amounts_quar__c, Ytd_invoiced_amount__c, Ultimate_Parent__c ' +
                'FROM Account WHERE Ultimate_Parent__c = ' + String.valueOf(step);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Account> accounts) {

        Set<Id> according = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<Account> updateAccount = new List<Account>();
        List<Account> childAccounts = new List<Account>();
        Map<Id, List<AcctSeed__Billing__c>> existListBills = new Map<Id, List<AcctSeed__Billing__c>>();
        List<Id> quarterAccounting = new List<Id>();
        List<Id> thisYearAccounting = new List<Id>();
        List<Id> lastYearAccounting = new List<Id>();

        Date nowDay = Date.today();
        Date threeMounthAgo = Date.today().addMonths(-3);
        String quarter = String.valueOf(MONTH_QUARTER.get(threeMounthAgo.month()));
        Integer years = threeMounthAgo.year();
        Integer thisYear = nowDay.year();


        Map<Id, List<Opportunity>> accWithRelateOpp = new Map<Id, List<Opportunity>>();
        Map<Id, List<Account>> accWithChildAcc = new Map<Id, List<Account>>();

        Map<String, CurrencyType> curExist = new Map<String, CurrencyType>();

        for (CurrencyType curr : [SELECT Id, ConversionRate, IsoCode FROM CurrencyType]) {
            curExist.put(curr.IsoCode, curr);
        }

        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }

        childAccounts = [
                SELECT Id, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, ParentId,
                        Ytd_invoiced_amount__c, CurrencyIsoCode
                FROM Account
                WHERE ParentId IN :accIds
        ];

        for (AcctSeed__Billing__c bill : [
                SELECT Id, TotalBilling__c, AcctSeed__Customer__c, AcctSeed__Accounting_Period__c
                FROM AcctSeed__Billing__c
                WHERE AcctSeed__Customer__c IN :accIds
        ]) {

            List<AcctSeed__Billing__c> billList;

            if (existListBills.containsKey(bill.AcctSeed__Customer__c)) {
                billList = existListBills.get(bill.AcctSeed__Customer__c);
                billList.add(bill);

            } else {
                billList = new List<AcctSeed__Billing__c>();
                billList.add(bill);

            }
            existListBills.put(bill.AcctSeed__Customer__c, billList);
            according.add(bill.AcctSeed__Accounting_Period__c);
        }

        for (Account childAcc : childAccounts) {

            List<Account> accList;
            if (accWithChildAcc.containsKey(childAcc.ParentId)) {
                accList = accWithChildAcc.get(childAcc.ParentId);
                accList.add(childAcc);
            } else {
                accList = new List<Account>();
                accList.add(childAcc);
            }
            accWithChildAcc.put(childAcc.ParentId, accList);
        }

        for (AcctSeed__Accounting_Period__c period : [
                SELECT Id, Name, AcctSeed__Status__c, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                FROM AcctSeed__Accounting_Period__c
                WHERE Id IN:according
        ]) {

            if (String.valueOf(MONTH_QUARTER.get(period.AcctSeed__End_Date__c.month())) == quarter
                    &&
                    period.AcctSeed__End_Date__c.year() == years) {
                quarterAccounting.add(period.Id);
            }

            if (period.AcctSeed__End_Date__c.year() == thisYear) {
                thisYearAccounting.add(period.Id);
            }

            if (period.AcctSeed__End_Date__c > nowDay.addYears(-1) ||
                    (period.AcctSeed__End_Date__c.month() == nowDay.month() && period.AcctSeed__End_Date__c.year() == nowDay.addYears(-1).year())) {
                lastYearAccounting.add(period.Id);
            }
        }

        for (Account acc : accounts) {

            Double invoiceTotal = 0;
            Double Invoice12months = 0;
            Double InvoiceQuartol = 0;
            Double InvoiceYtd = 0;

            //Step 1. Calculate fields from relating Billings.
            if (existListBills.containsKey(acc.Id)) {

                for (AcctSeed__Billing__c billing : existListBills.get(acc.Id)) {

                    invoiceTotal += billing.TotalBilling__c;

//------------------Counting amounts from Last Quarter
                    if (quarterAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
                        InvoiceQuartol += billing.TotalBilling__c;
                    }

//------------------Counting amounts from the beginning of the year
                    if (thisYearAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
                        InvoiceYtd += billing.TotalBilling__c;
                    }

////------------------Last 12 months invoiced amount: sum of all invoices from the last 12 months
                    if (lastYearAccounting.contains(billing.AcctSeed__Accounting_Period__c)) {
                        Invoice12months += billing.TotalBilling__c;
                    }
                }

                acc.Opportunity_Invoice_Total__c = invoiceTotal;
                acc.Opportunity_Total_Last12__c = Invoice12months;
                acc.Opportunity_Invoice_Quartol__c = InvoiceQuartol;
                acc.Opportunity_Ytd__c = InvoiceYtd;
            }

            //Step 2. Calculate fields from relating Accounts.
            Double ChildinvoiceTotal = 0;
            Double ChildInvoice12months = 0;
            Double ChildInvoiceQuartol = 0;
            Double ChildInvoiceYtd = 0;

            if (accWithChildAcc.size() > 0 && accWithChildAcc.get(acc.Id) != null) {
                for (Account childAcc : accWithChildAcc.get(acc.Id)) {

                    Decimal rate = acc.CurrencyIsoCode == childAcc.CurrencyIsoCode ? 1 :
                            curExist.get(acc.CurrencyIsoCode).ConversionRate / curExist.get(childAcc.CurrencyIsoCode).ConversionRate;

                    if (childAcc == null) {
                        continue;
                    }
                    if (childAcc.Invoice_Total__c != null) {

                        ChildinvoiceTotal += childAcc.Invoice_Total__c * rate;
                        invoiceTotal += childAcc.Invoice_Total__c * rate;
                    }
                    if (childAcc.Last12_months_invoiced__c != null) {

                        ChildInvoice12months += childAcc.Last12_months_invoiced__c * rate;
                        Invoice12months += childAcc.Last12_months_invoiced__c * rate;
                    }
                    if (childAcc.Sum_amounts_quar__c != null) {

                        ChildInvoiceQuartol += childAcc.Sum_amounts_quar__c * rate;
                        InvoiceQuartol += childAcc.Sum_amounts_quar__c * rate;
                    }
                    if (childAcc.Ytd_invoiced_amount__c != null) {
                        ChildInvoiceYtd += childAcc.Ytd_invoiced_amount__c * rate;
                        InvoiceYtd += childAcc.Ytd_invoiced_amount__c * rate;
                    }

                }
            }

            acc.Invoice_Total__c = invoiceTotal;
            acc.Last12_months_invoiced__c = Invoice12months;
            acc.Sum_amounts_quar__c = InvoiceQuartol;
            acc.Ytd_invoiced_amount__c = InvoiceYtd;

            acc.ChildInvoiceTotal__c = ChildinvoiceTotal;
            acc.Child_Last12__c = ChildInvoice12months;
            acc.Child_Sum_Amount__c = ChildInvoiceQuartol;
            acc.Child_Ytd__c = ChildInvoiceYtd;

            acc.Last_Updated_Analitic_field__c = date.today();

            updateAccount.add(acc);
        }

        Database.upsert(updateAccount, false);
    }

    public void finish(Database.BatchableContext context) {

        if (step > 0) {
            step--;
            Database.executeBatch(new AccountAnalyticsBatch(step), 100);
        } else {

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
        }
    }
}