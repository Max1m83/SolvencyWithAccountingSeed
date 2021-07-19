/**
 * Created by max1m on 22.10.20.
 */

public with sharing class cloneBillingPage {
    ApexPages.StandardSetController controller;

    public cloneBillingPage(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }

    public List<AcctSeed__Billing__c> getbillings() {

        Set<Id> billIds = new Set<Id>();

        for (AcctSeed__Billing__c bill : (AcctSeed__Billing__c[]) controller.getSelected()) {
            billIds.add(bill.Id);
        }

        return [
                SELECT Id,Name, AcctSeed__Customer__c, AcctSeed__Status__c, AcctSeed__Type__c, AcctSeed__Total__c,
                        AcctSeed__Accounting_Period__c, AcctSeed__Date__c, AcctSeed__Opportunity__c
                FROM AcctSeed__Billing__c
                WHERE Id IN :billIds
        ];
    }

    public PageReference cloneAndReparent() {

        Map<Id, List<AcctSeed__Billing_Line__c>> mapProduct = new Map<Id, List<AcctSeed__Billing_Line__c>> ();
        List<AcctSeed__Billing_Line__c> insertProd = new List<AcctSeed__Billing_Line__c>();

        AcctSeed__Billing__c[] newRecords = new AcctSeed__Billing__c[0], selRecords = (AcctSeed__Billing__c[]) controller.getSelected();

        String queryBilling = String.format(
                'SELECT {0} FROM {1} WHERE ID IN (\'\'{2}\'\')',
                new String[]{
                        String.join(
                                new List<String>(
                                        AcctSeed__Billing__c.SObjectType.getDescribe().fields.getMap().keySet()
                                ),
                                ','
                        ),
                        String.valueOf(AcctSeed__Billing__c.SObjectType),
                        String.join(
                                new List<Id >(
                                        new Map<Id, AcctSeed__Billing__c>(selRecords).keySet()
                                ), '\',\''
                        )
                }
        );

        String queryProduct = String.format(
                'SELECT {0} FROM {1} WHERE AcctSeed__Billing__c IN (\'\'{2}\'\')',
                new String[]{
                        String.join(
                                new List<String>(
                                        AcctSeed__Billing_Line__c.SObjectType.getDescribe().fields.getMap().keySet()
                                ),
                                ','
                        ),
                        String.valueOf(AcctSeed__Billing_Line__c.SObjectType),
                        String.join(
                                new List<Id >(
                                        new Map<Id, AcctSeed__Billing__c>(selRecords).keySet()
                                ), '\',\''
                        )
                }
        );

        for (AcctSeed__Billing_Line__c billingProduct : (AcctSeed__Billing_Line__c[]) Database.query(queryProduct)) {

            if (mapProduct.containsKey(billingProduct.AcctSeed__Billing__c)) {
                List<AcctSeed__Billing_Line__c> products = mapProduct.get(billingProduct.AcctSeed__Billing__c);
                products.add(billingProduct);
                mapProduct.put(billingProduct.AcctSeed__Billing__c, products);
            } else {
                List<AcctSeed__Billing_Line__c> products = new List<AcctSeed__Billing_Line__c>();
                products.add(billingProduct);
                mapProduct.put(billingProduct.AcctSeed__Billing__c, products);
            }
        }

        for (AcctSeed__Billing__c record : (AcctSeed__Billing__c[]) Database.query(queryBilling)) {
            AcctSeed__Billing__c newBill = record.clone(false, false, false, false);
            newBill.AcctSeed__Date__c = Date.today();
            if (!Test.isRunningTest()) {
                newBill.AcctSeed__Accounting_Period__c = null;
            }
            newRecords.add(newBill);
        }

        insert newRecords;

        for (AcctSeed__Billing__c record : newRecords) {

            if (mapProduct.containsKey(record.getCloneSourceId())) {
                for (AcctSeed__Billing_Line__c prod : mapProduct.get(record.getCloneSourceId())) {
                    AcctSeed__Billing_Line__c newProduct = prod.clone(false, false, false, false);
                    newProduct.AcctSeed__Billing__c = record.Id;
                    insertProd.add(newProduct);
                }
            }
        }

        insert insertProd;

        return new ApexPages.Action('{!List}').invoke();
    }
}