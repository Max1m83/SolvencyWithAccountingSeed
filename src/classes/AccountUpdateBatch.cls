/**
 * Created by max1m on 06.08.20.
 */

public with sharing class AccountUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {

    public static String BATCH_NAME = 'Account Updater Batch';

    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('AccountUpdateBatch');

        String query = 'SELECT Id, Invoice_Total__c, Last12_months_invoiced__c, Sum_invoice_year__c, Sum_amounts_quar__c, Ytd_invoiced_amount__c FROM Account';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Account> accounts) {

        Set<Id> accIds = new Set<Id>();
        Map<Id, Opportunity> existListOpp = new Map<Id, Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        List<Account> updateAccount = new List<Account>();
        Map<Id, List<Opportunity>> mapOpp = new Map<Id, List<Opportunity>>();

        for (Account acc : accounts) {

                accIds.add(acc.Id);
        }

        List <Business__c> existBusinesses = [SELECT Id, Account__c, Opportunity__c FROM Business__c WHERE Account__c IN :accIds];

        for (Business__c buss : existBusinesses) {
            oppIds.add(buss.Opportunity__c);
        }

        for (Opportunity opp : [
                SELECT Id, Amounts_in_currency__c, Sum_invoice_year__c, Last12_months_invoiced__c, Sum_amounts_quar__c, Ytd_invoiced_amount__c
                FROM Opportunity
                WHERE Id IN :oppIds
        ]) {

            existListOpp.put(opp.Id, opp);
        }

        for (Business__c buss : existBusinesses) {

            List<Opportunity> oppList;
            if (mapOpp.containsKey(buss.Account__c)) {
                oppList = mapOpp.get(buss.Account__c);
                oppList.add(existListOpp.get(buss.Opportunity__c));
            } else {
                oppList = new List<Opportunity>();
            }
            mapOpp.put(buss.Account__c, oppList);
        }

        for (Account acc : accounts) {

            Double invoiceTotal = 0;
            Double Invoice12months = 0;
            Double InvoiceQuartol = 0;
            Double InvoiceYtd = 0;

            if (mapOpp.get(acc.Id) == null) {continue;}
            for (Opportunity opp : mapOpp.get(acc.Id)) {

                if (opp == null) {continue;}
                if (opp.Amounts_in_currency__c != null) {invoiceTotal += opp.Amounts_in_currency__c;}
                if (opp.Last12_months_invoiced__c != null) {Invoice12months += opp.Last12_months_invoiced__c;}
                if (opp.Sum_amounts_quar__c != null) {InvoiceQuartol += opp.Sum_amounts_quar__c;}
                if (opp.Ytd_invoiced_amount__c != null) {InvoiceYtd += opp.Ytd_invoiced_amount__c;}
            }

            acc.Invoice_Total__c = invoiceTotal;
            acc.Last12_months_invoiced__c = Invoice12months;
            acc.Sum_amounts_quar__c = InvoiceQuartol;
            acc.Ytd_invoiced_amount__c = InvoiceYtd;
            updateAccount.add(acc);
        }

        Database.upsert(updateAccount, false);
        System.debug(updateAccount);
    }

    public void finish(Database.BatchableContext context) {

        System.scheduleBatch(new AccountUpdateParentBatch(), BATCH_NAME, 2);
    }
}