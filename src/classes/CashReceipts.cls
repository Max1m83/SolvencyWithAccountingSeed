/**
 * Created by max1m on 30.12.20.
 */

public with sharing class CashReceipts {

    public static void createCashReceipts(List<AcctSeed__Billing__c> billings) {

        Map<Id, List<AcctSeed__Billing__c>> customers = customerBilling(billings);
        List<AcctSeed__Billing_Cash_Receipt__c> billCashGroup = new List<AcctSeed__Billing_Cash_Receipt__c>();
        Map<Id, AcctSeed__Cash_Receipt__c> cashId = new Map<Id, AcctSeed__Cash_Receipt__c>();

        AcctSeed__GL_Account__c glAccount = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '4900-Customer Payment Discounts'];
        System.debug('#####');
        System.debug(glAccount);

        for (Id customerId : customers.keySet()) {
            AcctSeed__Cash_Receipt__c cash = new AcctSeed__Cash_Receipt__c();
            cash.AcctSeed__Account__c = customerId;
            cash.AcctSeed__Ledger__c = customers.get(customerId).get(0).AcctSeed__Ledger__c;
            cash.CurrencyIsoCode = customers.get(customerId).get(0).CurrencyIsoCode;
            cash.AcctSeed__Purpose__c = 'Customer Receipt';
            cash.AcctSeed__Accounting_Period__c = customers.get(customerId).get(0).AcctSeed__Accounting_Period__c;
            cash.AcctSeed__Status__c = 'In Process';
            cash.AcctSeed__Amount__c = customers.get(customerId).get(0).AcctSeed__Received_Amount__c;
            cash.AcctSeed__Payment_Reference__c = '1607438373652';

            //cash.AcctSeed__Receipt_Date__c =

            cashId.put(customerId, cash);
        }

        System.debug(cashId);

        insert cashId.values();

        for (Id customerId : customers.keySet()) {

            Decimal amountBill = 0;

            for (AcctSeed__Billing__c bill : customers.get(customerId)) {

                AcctSeed__Billing_Cash_Receipt__c billCash = new AcctSeed__Billing_Cash_Receipt__c();
                billCash.AcctSeed__Billing__c = bill.Id;
                billCash.AcctSeed__Accounting_Period__c = bill.AcctSeed__Accounting_Period__c;
                billCash.CurrencyIsoCode = bill.CurrencyIsoCode;
                billCash.AcctSeed__Applied_Amount__c = bill.AcctSeed__Received_Amount__c;
                billCash.AcctSeed__Cash_Receipt__c = cashId.get(customerId).Id;
                //GL Account ?
                billCash.AcctSeed__Adjustment_GL_Account__c = glAccount.Id;
                amountBill += bill.AcctSeed__Received_Amount__c;

                billCashGroup.add(billCash);
            }
            cashId.get(customerId).AcctSeed__Amount__c = amountBill;
        }

        System.debug(billCashGroup);

        //update cashId.values();
        insert billCashGroup;
    }

    private static Map<Id, List<AcctSeed__Billing__c>> customerBilling(List<AcctSeed__Billing__c> billings) {

        Map<Id, List<AcctSeed__Billing__c>> returnMap = new Map<Id, List<AcctSeed__Billing__c>>();

        for (AcctSeed__Billing__c bill : billings) {

            List<AcctSeed__Billing__c> bills = new List<AcctSeed__Billing__c>();

            if (returnMap.containsKey(bill.AcctSeed__Customer__c)) {
                bills = returnMap.get(bill.AcctSeed__Customer__c);
                bills.add(bill);
            } else {
                bills.add(bill);
            }
            returnMap.put(bill.AcctSeed__Customer__c, bills);
        }

        return returnMap;
    }
}