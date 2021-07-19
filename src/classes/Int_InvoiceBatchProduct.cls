public with sharing class Int_InvoiceBatchProduct implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject {get; set;}
    private Integer chunkSize = 1;
    private List<Invoice__c> invoices;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        this.invoices = [SELECT Id, Bexio_Id__c, Invoice__c FROM Invoice__c WHERE Invoice__c != null AND Bexio_Id__c != null];
        this.allCountObject = this.invoices.size();

        return Int_Utils.generateCountOfChuncks(this.allCountObject, this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {
        
        for (Integer packageNumber : batchIndexes) {
            Integer startNumber = (packageNumber - 1)*this.chunkSize;
            for (Integer numberInvoice = 0; numberInvoice < this.chunkSize; numberInvoice++) {
                if (this.invoices.size() > startNumber + numberInvoice) {
                    List<Invoice_Product__c> products = Int_Helper.getInvoiceProducts(this.invoices.get(startNumber + numberInvoice).Bexio_Id__c);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {

        List<BatchId__c> batches = [SELECT ProductIds__c, Finish_Date__c, isWork__c FROM BatchId__c];
        BatchId__c newBatch;
        if (batches.size() == 0) {
            newBatch = new BatchId__c();
        } else {
            newBatch = batches.get(0);
        }
        newBatch.isWork__c = true;

        newBatch.ProductIds__c = BC.getJobId();
        newBatch.Finish_Date__c = Datetime.now();
        upsert newBatch;

        InvoiceEvent__e events = new InvoiceEvent__e();
        events.Status__c = 'Success';
        List<InvoiceEvent__e> newEvents = new List<InvoiceEvent__e>();
        newEvents.add(events);
        List<Database.SaveResult> results = EventBus.publish(newEvents);
    }
}