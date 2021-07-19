/**
 * Created by max1m on 07.05.21.
 */

public with sharing class Int_InvoiceUpdateBatchAmount implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject { get; set; }
    private Integer chunkSize = 200;
    private String dateSearch { get; set; }
    private BatchIndex__c BatchIndexRMA;
    private List<String> invoiceIds = new List<String>();

    public Int_InvoiceUpdateBatchAmount() {

        DateTime currentDateTime = Datetime.now();
        List<BatchIndex__c> batchList = [
                SELECT Id,Last_Batch_Date__c, Next_Batch_Date__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c, isActive__c
                FROM BatchIndex__c
                WHERE Object__c = 'Invoice' AND (Next_Batch_Date__c < :currentDateTime
                OR Next_Batch_Date__c = null) AND isActive__c = true
        ];

        if (batchList.size() > 0) {
            BatchIndexRMA = batchList.get(0);
            this.chunkSize = Integer.valueOf(BatchIndexRMA.Chunk_Size__c <= 0 ? 0 : 1);
        }
    }

    public Iterable<Integer> start(Database.BatchableContext BC) {

        if (this.chunkSize > 0) {
            List<Invoice__c> invoice = [SELECT Id, Update_in_Bexio__c, Account__c, CurrencyIsoCode FROM Invoice__c WHERE Update_in_Bexio__c != null ORDER BY Update_in_Bexio__c DESC LIMIT 1];
            this.dateSearch = invoice.size() > 0 ? invoice.get(0).Update_in_Bexio__c.addDays(-1).format('YY-MM-dd') : '2018-01-01';
            System.debug(this.dateSearch);
            getCountObject();
        }

        return Int_Utils.generateCountOfChuncks(this.allCountObject, 1, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {
        List<Invoice_Product__c> products = Int_Helper_Res.getInvoiceProduct(this.invoiceIds.get(batchIndexes[0]-1));
    }

    public void finish(Database.BatchableContext BC) {

        overdueStatus();
        Utils.checkReminderEmails();
        System.scheduleBatch(new Int_PaymentBatch(), 'InvoicePayment`s Batch', 1, 1);
    }

    public void getCountObject() {

        List<String> resultList = Int_Helper_Res.getCountInvoices(this.dateSearch);

        this.invoiceIds.addAll(resultList);
        this.allCountObject = resultList.size();
    }

    private static void overdueStatus() {

        List<Invoice__c> invoices = new List<Invoice__c>();
        List<Reminder_email__c> reminders = new List<Reminder_email__c>();

        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];
        for (Invoice__c invoice : [
                SELECT Id, Invoice_Status__c, Invoice__c, Account__c, CurrencyIsoCode, Company_name__c
                FROM Invoice__c
                WHERE Invoice_Status__c = 'Pending' AND Billing_Date__c < TODAY
        ]) {
            invoice.Invoice_Status__c = 'Overdue';
            reminders.add(Utils.createEmailObject(invoice, settingsReminder));
            invoices.add(invoice);
        }

        update invoices;
        upsert reminders;
    }
}