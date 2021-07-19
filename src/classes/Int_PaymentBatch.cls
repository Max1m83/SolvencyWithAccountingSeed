public with sharing class Int_PaymentBatch implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject {get; set;}
    private List<String> invoiceIds = new List<String>();

    public Iterable<Integer> start(Database.BatchableContext BC) {

        getCountObject();
        return Int_Utils.generateCountOfChuncks(this.allCountObject, 1, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Invoice__c> products = Int_Helper_Res.getPayments(this.invoiceIds.get(batchIndexes[0]-1));
    }

    public void finish(Database.BatchableContext BC) {

        List<BatchIndex__c> batchList = [
                SELECT Id,Last_Batch_Date__c, Next_Batch_Date__c, Object__c, Chunk_Size__c, Sync_Interval_Minutes__c, isActive__c
                FROM BatchIndex__c
                WHERE Object__c = 'Invoice' AND isActive__c = TRUE
        ];

        if (batchList.size() > 0 && batchList.get(0) != null) {
            BatchIndex__c BatchIndexRMA = batchList.get(0);
            BatchIndexRMA.Next_Batch_Date__c = Datetime.now().addMinutes(Integer.valueOf(BatchIndexRMA.Sync_Interval_Minutes__c));
            BatchIndexRMA.Last_Batch_Date__c = Datetime.now();
            update BatchIndexRMA;
        }

        if (!Test.isRunningTest()) {
            Int_BatchController.controlBatch();
        }
    }

    public void getCountObject() {

        List<Invoice__c> existInvoices = [SELECT Id, Bexio_Id__c FROM Invoice__c WHERE Invoice_Status__c = 'Paid' AND Payment_Date__c = NULL];
        this.allCountObject = existInvoices.size();

        for (Invoice__c invoice : existInvoices) {
            this.invoiceIds.add(invoice.Bexio_Id__c);
        }
    }
}