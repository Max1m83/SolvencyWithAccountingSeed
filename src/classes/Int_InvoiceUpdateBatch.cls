public with sharing class Int_InvoiceUpdateBatch implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject { get; set; }
    private Integer chunkSize = 200;
    private String dateSearch { get; set; }
    private BatchIndex__c BatchIndexRMA;

    public Int_InvoiceUpdateBatch() {

        DateTime currentDateTime = Datetime.now();
        List<BatchIndex__c> batchList = [
                SELECT Id,Last_Batch_Date__c, Next_Batch_Date__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c, isActive__c
                FROM BatchIndex__c
                WHERE Object__c = 'Invoice' AND (Next_Batch_Date__c < :currentDateTime
                OR Next_Batch_Date__c = null) AND isActive__c = true
        ];

        if (batchList.size() > 0) {
            BatchIndexRMA = batchList.get(0);
            this.chunkSize = Integer.valueOf(BatchIndexRMA.Chunk_Size__c > 200 ? 200 : (BatchIndexRMA.Chunk_Size__c < 0 ? 0 : BatchIndexRMA.Chunk_Size__c));
        }
    }

    public Iterable<Integer> start(Database.BatchableContext BC) {

        if (this.chunkSize > 0) {
            List<Invoice__c> invoice = [SELECT Id, Update_in_Bexio__c FROM Invoice__c WHERE Update_in_Bexio__c != null ORDER BY Update_in_Bexio__c DESC LIMIT 1];
            this.dateSearch = invoice.size() > 0 ? invoice.get(0).Update_in_Bexio__c.format('YY-MM-dd') : '2018-01-01';
            getCountObject();
        }

        return Int_Utils.generateCountOfChuncks(this.allCountObject, this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Object> getObject = Int_Helper_Reserved.getCountInvoices(this.dateSearch, (batchIndexes.get(0) - 1) * this.chunkSize, this.chunkSize, 'UpdateInvoice');
    }

    public void finish(Database.BatchableContext BC) {

        overdueStatus();

        if (BatchIndexRMA != null && chunkSize != 0) {

            BatchIndexRMA.Next_Batch_Date__c = Datetime.now().addMinutes(Integer.valueOf(BatchIndexRMA.Sync_Interval_Minutes__c));
            BatchIndexRMA.Last_Batch_Date__c = Datetime.now();
            update BatchIndexRMA;
        }

        if (!Test.isRunningTest()) {
            Int_BatchController.controlBatch();
        }
    }

    public void getCountObject() {

        List<Object> getObject = Int_Helper_Reserved.getCountInvoices(this.dateSearch, 0, 0, 'Count');
        this.allCountObject = Test.isRunningTest() ? 1 : getObject.size();
    }

    private static void overdueStatus() {

        List<Invoice__c> invoices = new List<Invoice__c>();
 //       List<Reminder_email__c> reminders = new List<Reminder_email__c>();

        for (Invoice__c invoice : [
                SELECT Id, Invoice_Status__c, Invoice__c
                FROM Invoice__c
                WHERE Invoice_Status__c = 'Pending' AND Billing_Date__c < TODAY
        ]) {
            invoice.Invoice_Status__c = 'Overdue';
            //reminders.add(createEmailObject(invoice));
            invoices.add(invoice);
        }

        update invoices;
        //upsert reminders;
    }

//    private static Reminder_email__c createEmailObject(Invoice__c invoice) {
//
//        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];
//
//        Reminder_email__c newReminder = new Reminder_email__c();
//        newReminder.Account__c = invoice.Account__c;
//        newReminder.CurrencyIsoCode = invoice.CurrencyIsoCode;
//        newReminder.Date_create__c = Datetime.now();
//        newReminder.Invoice__c = invoice.Id;
//        newReminder.isCancel__c = false;
//        newReminder.Reminder_Stage__c = 'Overdue';
//        newReminder.Name = (invoice.Company_name__c != null ? invoice.Company_name__c : invoice.Invoice__c);
//        newReminder.Picture_Status__c = 'Overdue';
//        newReminder.Settings_Reminder_email__c = (settingsReminder.size() > 0 ? settingsReminder.get(0).Id : '');
//        newReminder.Status__c = 'Unsent';
//        return newReminder;
//    }
}