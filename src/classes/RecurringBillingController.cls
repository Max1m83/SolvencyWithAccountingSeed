/**
 * Created by max1m on 25.11.20.
 */

public with sharing class RecurringBillingController {

    @AuraEnabled
    public static Map<String, List<String>> getRecurringInvoice(Id billId) {

//        System.debug(billId);
//
//        Map<String, List<String>> returnMap = new Map<String, List<String>>();
//        Set<Id> ContactGroupIds = new Set<Id>();
//        List<String> contactsGet = new List<String>();
//        List<String> accountsGet = new List<String>();
//        List<String> nameGet = new List<String>();
//
//        List<String> listStatus = new List<String>();
//        Schema.DescribeFieldResult fieldResultStatus = AcctSeed__Recurring_Billing__c.AcctSeed__Status__c.getDescribe();
//        List<Schema.PicklistEntry> pleStatus = fieldResultStatus.getPicklistValues();
//        for (Schema.PicklistEntry pickListVal : pleStatus) {
//            listStatus.add(pickListVal.getLabel());
//        }
//
//        List<String> listFrequency = new List<String>();
//        Schema.DescribeFieldResult fieldResult = AcctSeed__Recurring_Billing__c.AcctSeed__Billing_Frequency__c.getDescribe();
//        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//        for (Schema.PicklistEntry pickListVal : ple) {
//            listFrequency.add(pickListVal.getLabel());
//        }
//
//        AcctSeed__Billing__c billing = [SELECT Id, AcctSeed__Customer__c, AcctSeed__Opportunity__c FROM AcctSeed__Billing__c WHERE Id = :billId LIMIT 1];
//
//        System.debug(billing);
//
//        for (Account acc : [
//                SELECT Id, Name
//                FROM Account
//                WHERE Id = :billing.AcctSeed__Customer__c
//        ]) {
//
//            accountsGet.add(acc.Name);
//        }
//
//        Opportunity opp = [
//                SELECT Id, AccountId, Name, CurrencyIsoCode, Name_Product2__c, (SELECT Id, Product2Id, Quantity, ListPrice FROM OpportunityLineItems), (SELECT Id, Contact_group__c FROM Contacts_for_Opportunity__r)
//                FROM Opportunity
//                WHERE Id = :billing.AcctSeed__Opportunity__c
//                LIMIT 1
//        ];
//
//        if (opp != null) {
//            nameGet.add(opp.Name);
//        }
//
//        for (Contacts_for_Billing__c bill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billId]) {
//            ContactGroupIds.add(bill.Contact_group__c);
//        }
//
//        for (Contact_group__c conGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
//            contactsGet.add(conGroup.Name);
//        }
//
//        returnMap.put('Accounts', accountsGet);
//        returnMap.put('Name', nameGet);
//        returnMap.put('Contacts', contactsGet);
//        returnMap.put('Status', listStatus);
//        returnMap.put('Frequency', listFrequency);

        return null;
    }

    @AuraEnabled
    public static String SaveBilling(Map<String, String> bill, List<String> contacts) {

        return 'Not Account';


        Set<Id> accId = new Set<Id>();
        Set<Id> ContactGroupIds = new Set<Id>();
        List<Contact_group__c> contactsGroup = new List<Contact_group__c>();
        List<Contacts_for_Billing__c> contactGroupExist = new List<Contacts_for_Billing__c>();
        AcctSeed__Billing__c invoice;
        AcctSeed__Billing__c billingExist;
        Boolean isCreateInvoice = bill.get('CreateInvoice') == 'true' ? true : false;

        //we need to think about how to link it
        //AcctSeed__GL_Account__c accountGL = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '4000-Product Revenue' LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '3401-Gross proceeds credit operations'];

        AcctSeed__Recurring_Billing__c recurringBilling = new AcctSeed__Recurring_Billing__c();
        List<Rec_Billing_Contact_Groups__c> relBillContact = new List<Rec_Billing_Contact_Groups__c>();
        List<AcctSeed__Recurring_Billing_Line__c> insertProduct = new List<AcctSeed__Recurring_Billing_Line__c>();
        List<AcctSeed__Billing_Line__c> insertBillingProduct = new List<AcctSeed__Billing_Line__c>();

        if (bill.get('Billing') != null) {

            billingExist = [
                    SELECT Id, AcctSeed__Customer__c, billing_number__c, CurrencyIsoCode, AcctSeed__Opportunity__c, Name_Product__c, Billing_Company_Name__c, AcctSeed__Discount_Percent__c
                            , (
                            SELECT Id, Name, Number__c, AcctSeed__Product__c, AcctSeed__Hours_Units__c, AcctSeed__Rate__c
                            FROM AcctSeed__Project_Billing_Lines__r
                            ORDER BY Name ASC
                    )
                    FROM AcctSeed__Billing__c
                    WHERE Id = :bill.get('Billing')
                    LIMIT 1
            ];
            recurringBilling.AcctSeed__Opportunity__c = billingExist.AcctSeed__Opportunity__c;
            recurringBilling.CurrencyIsoCode = billingExist.CurrencyIsoCode;
            recurringBilling.Name = 'Recurring Billing (Billing #' + billingExist.billing_number__c + ')';
            recurringBilling.Invoice_Title__c = billingExist.Name_Product__c;


            for (Contacts_for_Billing__c billContact : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :bill.get('Billing')]) {
                ContactGroupIds.add(billContact.Contact_group__c);
            }

            for (Contact_group__c contactGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
                for (String nameContact : contacts) {

                    if (nameContact == contactGroup.Name) {
                        Rec_Billing_Contact_Groups__c bills = new Rec_Billing_Contact_Groups__c();
                        bills.Contact_group__c = contactGroup.Id;
                        relBillContact.add(bills);
                        contactsGroup.add(contactGroup);

                        Contacts_for_Billing__c billInvoice = new Contacts_for_Billing__c();
                        billInvoice.Contact_group__c = contactGroup.Id;
                        contactGroupExist.add(billInvoice);
                    }
                }
            }
        }

        if (bill.get('Status') != null) {

            Schema.DescribeFieldResult fieldResultStatus = AcctSeed__Recurring_Billing__c.AcctSeed__Status__c.getDescribe();
            List<Schema.PicklistEntry> pleStatus = fieldResultStatus.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : pleStatus) {

                if (pickListVal.getLabel() == bill.get('Status')) {
                    recurringBilling.AcctSeed__Status__c = bill.get('Status');
                }
            }
        }

        if (bill.get('Frequency') != null) {

            Schema.DescribeFieldResult fieldResultStatus = AcctSeed__Recurring_Billing__c.AcctSeed__Billing_Frequency__c.getDescribe();
            List<Schema.PicklistEntry> pleFrequency = fieldResultStatus.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : pleFrequency) {

                if (pickListVal.getLabel() == bill.get('Frequency')) {
                    recurringBilling.AcctSeed__Billing_Frequency__c = bill.get('Frequency');
                }
            }
        }

        if (bill.get('InvoiceDate') != null) {

            recurringBilling.AcctSeed__Next_Billing_Date__c = date.valueOf(bill.get('InvoiceDate'));

        } else {
            recurringBilling.AcctSeed__Next_Billing_Date__c = Date.today();
        }

        for (Business__c buss : [SELECT Id, Account__c, Opportunity__c From Business__c WHERE Opportunity__c = :bill.get('Opportunity')]) {

            accId.add(buss.Account__c);
        }




        List<Account> acccList = [SELECT Id, BillingAddress, AcctSeed__Billing_Contact__c FROM Account WHERE Id = :billingExist.AcctSeed__Customer__c LIMIT 1];
        Account acc;

        if (acccList.size() > 0) {
            acc = acccList.get(0);
            recurringBilling.AcctSeed__Customer__c = acc.Id;

            if (!Test.isRunningTest()) {

                insert recurringBilling;

                for (Rec_Billing_Contact_Groups__c contactBill : relBillContact) {
                    contactBill.Recurring_Billing__c = recurringBilling.Id;
                }

                insert relBillContact;
            }

            if (isCreateInvoice && recurringBilling != null) {

                invoice = billingExist.clone(false, false, false, false);
                invoice.AcctSeed__Recurring_Billing__c = recurringBilling.Id;

                if (!Test.isRunningTest()) {
                    insert invoice;

                    for (Contacts_for_Billing__c billInvoice : contactGroupExist) {
                        billInvoice.Billing__c = invoice.Id;
                    }
                    insert contactGroupExist;
                }
            }

            for (AcctSeed__Billing_Line__c billProd : billingExist.AcctSeed__Project_Billing_Lines__r) {

                AcctSeed__Recurring_Billing_Line__c billRecurringProduct = new AcctSeed__Recurring_Billing_Line__c();
                billRecurringProduct.AcctSeed__Product__c = billProd.AcctSeed__Product__c;

                if (glAccounts.size() > 0) {
                    billRecurringProduct.AcctSeed__Revenue_GL_Account__c = glAccounts.get(0).Id;
                }

                billRecurringProduct.AcctSeed__Recurring_Billing__c = recurringBilling.Id;
                billRecurringProduct.AcctSeed__Quantity__c = billProd.AcctSeed__Hours_Units__c;
                billRecurringProduct.AcctSeed__Rate__c = billProd.AcctSeed__Rate__c;
                insertProduct.add(billRecurringProduct);

                if (isCreateInvoice) {
                    AcctSeed__Billing_Line__c billProduct = new AcctSeed__Billing_Line__c();

                    billProduct = billProd.clone(false, false, false, false);
                    billProduct.AcctSeed__Billing__c = invoice.Id;
                    billProduct.AcctSeed__Revenue_GL_Account__c = glAccounts.get(0).Id;
                    insertBillingProduct.add(billProduct);
                }
            }

            if (!Test.isRunningTest()) {
                insert insertProduct;
                insert insertBillingProduct;
            }

            if (Test.isRunningTest()) {
                return 'Test';
            } else {
                return recurringBilling.Id;
            }

        } else return 'Not Account';
    }
}