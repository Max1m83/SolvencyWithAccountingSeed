/**
 * Created by max1m on 11.03.21.
 */

public with sharing class Int_CountryBeforeAccountBatch implements Database.Batchable<Integer>, Database.AllowsCallouts {

    public Iterable<Integer> start(Database.BatchableContext BC) {

        return new List<Integer>{1};
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        System.debug('Execute');

        List<Object> getObject = Int_RequestHelper.getCountCountry();
        System.debug(getObject.size());
    }

    public void finish(Database.BatchableContext BC) {
        System.scheduleBatch(new Int_AccountBatch(), 'Account Batch', 1, 1);
        //System.scheduleBatch(new Int_CountryBeforeAccountBatch(), 'Invoice Batch', 1, 1);
    }
}