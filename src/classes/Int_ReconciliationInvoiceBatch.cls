/**
 * Created by max1m on 04.05.21.
 */

public with sharing class Int_ReconciliationInvoiceBatch implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject {get; set;}
    private Integer chunkSize = 200;
    private String lastDateUpdate = '2017-03-24';
    private Datetime startTime;
    private BatchId__c batch;
    private Boolean isStart;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        List<BatchId__c> batches = [SELECT InvoiceId__c, Start_Date__c, isWork__c, Finish_Date__c FROM BatchId__c];

        if (batches.size() > 0) {
            this.batch = batches.get(0);
        } else {
            this.batch = new BatchId__c();
        }
        this.batch.InvoiceId__c = null;

        getCountObject();
        return Int_Utils.generateCountOfChuncks(this.allCountObject, 1, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Invoice__c> invoices = Int_Helper.getInvoices(this.chunkSize * (batchIndexes[0] - 1), this.chunkSize, lastDateUpdate);
        upsert invoices;
    }

    public void finish(Database.BatchableContext BC) {


        this.batch.InvoiceId__c = BC.getJobId();

        if (!Test.isRunningTest() && this.batch.isWork__c) {

            this.batch.isWork__c = false;
            upsert this.batch;
            System.debug('finish');
            System.scheduleBatch(new Int_InvoiceBatchProduct(), 'Product`s Batch', 1, 1);
        }
    }

    public void getCountObject() {

        if (this.batch.isWork__c) {

            this.batch.Start_Date__c = Datetime.now();
            this.startTime = Datetime.now();
            this.allCountObject = Int_Helper.getCountInvoicesRecon(lastDateUpdate);
            this.isStart = true;

        } else {
            this.allCountObject = 0;
            this.isStart = false;
        }

        System.debug(this.allCountObject);
    }
}