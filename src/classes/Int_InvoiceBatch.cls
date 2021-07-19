public with sharing class Int_InvoiceBatch implements Database.Batchable<Integer>, Database.Stateful, Database.AllowsCallouts {

    private Integer allCountObject {get; set;}
    private Integer chunkSize = 200;
    private String lastDateUpdate;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        getDate();
        getCountObject();
        return Int_Utils.generateCountOfChuncks(this.allCountObject, this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Invoice__c> invoices = Int_Helper.getInvoices(this.chunkSize * (batchIndexes[0] - 1), this.chunkSize, lastDateUpdate);
    }

    public void finish(Database.BatchableContext BC) {
        if (!Test.isRunningTest()) {
            System.scheduleBatch(new Int_InvoiceBatchProduct(), 'Product`s Batch', 1, 1);
        }
    }

    private void getDate() {
        List<Invoice__c> invoices = [SELECT Id, Update_in_Bexio__c FROM Invoice__c WHERE Update_in_Bexio__c != null ORDER BY Update_in_Bexio__c DESC LIMIT 1];
        if (invoices.size() > 0) {
            this.lastDateUpdate = invoices.get(0).Update_in_Bexio__c.format('yyyy-MM-dd');
        } else {
            this.lastDateUpdate = '2017-03-24';
        }
    }

    public void getCountObject() {

        List<Object> getObject = Int_Helper.getInvoices(0,0, lastDateUpdate);
        this.allCountObject = getObject.size();
    }
}