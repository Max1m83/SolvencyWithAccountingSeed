/**
 * Created by max1m on 04.03.21.
 */

public with sharing class Int_AccountBatch implements Database.Batchable<Integer>, Database.AllowsCallouts {

    private Integer allCountObject {get; set;}
    private Integer chunkSize = 200;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        getCountObject();
        return Int_Utils.generateCountOfChuncks(this.allCountObject, this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Account> accounts = Int_RequestHelper.getAccounts(this.chunkSize * (batchIndexes[0] - 1), this.chunkSize);
    }

    public void finish(Database.BatchableContext BC) {
        //System.scheduleBatch(new Int_InvoiceBatch(), 'Invoice Batch', 1, 1);
    }

    public void getCountObject() {

        List<Object> getObject = Int_RequestHelper.getCountAccounts();
        this.allCountObject = getObject.size();
    }
}