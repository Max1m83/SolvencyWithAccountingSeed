/**
 * Created by max1m on 09.11.20.
 */

public with sharing class MassEditBillingProductController {
    ApexPages.StandardSetController controller;

    public MassEditBillingProductController(ApexPages.StandardSetController controller) {
        this.controller = controller;
    }

//    public List<AcctSeed__Billing_Line__c> getbillings() {
//
//        Set<Id> billIds = new Set<Id>();
//
//        for (AcctSeed__Billing_Line__c bill : (AcctSeed__Billing_Line__c[]) controller.getSelected()) {
//            billIds.add(bill.Id);
//        }
//
//        return [
//                SELECT Id,Name, AcctSeed__Customer__c, AcctSeed__Status__c, AcctSeed__Type__c, AcctSeed__Total__c,
//                        AcctSeed__Accounting_Period__c, AcctSeed__Date__c, AcctSeed__Opportunity__c
//                FROM AcctSeed__Billing__c
//                WHERE Id IN :billIds
//        ];
//    }

    public PageReference editProduct() {
        System.debug(controller);
        AcctSeed__Billing_Line__c[] billingLines = new AcctSeed__Billing_Line__c[0], selRecords = (AcctSeed__Billing_Line__c[]) controller.getSelected();
        System.debug(billingLines);
        System.debug(selRecords);
        String theId = 'a0s1j000003Pr7MAAS';

        PageReference pageRef = new PageReference('/' + theId + '/related/AcctSeed__Project_Billing_Lines__r/view');
        pageRef.setRedirect(true);
        return pageRef;

//        return new ApexPages.Action('{!List}').invoke();
    }
}