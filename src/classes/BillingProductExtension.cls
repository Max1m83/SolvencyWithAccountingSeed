/**
 * Created by max1m on 13.01.21.
 */

public with sharing class BillingProductExtension {

    private final Id billId;

    public String streetValue { get; set; }

    public BillingProductExtension(ApexPages.StandardController stdController) {

        billId = stdController.getId();

        AcctSeed__Billing__c bill = [
                SELECT Id,AcctSeed__Billing_Street__c
                FROM AcctSeed__Billing__c
                WHERE Id = :billId
                LIMIT 1
        ];

        if (bill.AcctSeed__Billing_Street__c != null ) {
            this.streetValue = bill.AcctSeed__Billing_Street__c.replaceAll('\\r\\n', '<br/>');
        }
    }
}