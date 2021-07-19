/**
 * Created by max1m on 28.05.21.
 */

public with sharing class RecurringInvoiceController {

    @AuraEnabled
    public static Map<String, List<String>> getRecurringInvoice(Id invoiceId) {

        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        Set<Id> ContactGroupIds = new Set<Id>();
        List<String> contactsGet = new List<String>();
        List<String> accountsGet = new List<String>();
        List<String> nameGet = new List<String>();

        List<String> listStatus = new List<String>();
        Schema.DescribeFieldResult fieldResultStatus = Recurring_Invoice__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pleStatus = fieldResultStatus.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : pleStatus) {
            listStatus.add(pickListVal.getLabel());
        }

        List<String> listFrequency = new List<String>();
        Schema.DescribeFieldResult fieldResult = Recurring_Invoice__c.Invoice_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            listFrequency.add(pickListVal.getLabel());
        }

        Invoice__c billing = [SELECT Id, Account__c, Opportunity__c FROM Invoice__c WHERE Id = :invoiceId LIMIT 1];

        for (Account acc : [
                SELECT Id, Name
                FROM Account
                WHERE Id = :billing.Account__c
        ]) {

            accountsGet.add(acc.Name);
        }

        List<Opportunity> opps = [
                SELECT Id, AccountId, Name, CurrencyIsoCode, Name_Product2__c, (SELECT Id, Product2Id, Quantity, ListPrice FROM OpportunityLineItems), (SELECT Id, Contact_group__c FROM Contacts_for_Opportunity__r)
                FROM Opportunity
                WHERE Id = :billing.Opportunity__c
                LIMIT 1
        ];

        if (opps.size() > 0) {
            nameGet.add(opps.get(0).Name);
        }

        for (Contacts_for_Billing__c bill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Invoice__c = :invoiceId]) {
            ContactGroupIds.add(bill.Contact_group__c);
        }

        for (Contact_group__c conGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
            contactsGet.add(conGroup.Name);
        }

        returnMap.put('Accounts', accountsGet);
        returnMap.put('Name', nameGet);
        returnMap.put('Contacts', contactsGet);
        returnMap.put('Status', listStatus);
        returnMap.put('Frequency', listFrequency);

        return returnMap;
    }

    @AuraEnabled
    public static String SaveBilling(Map<String, String> bill, List<String> contacts) {

        Set<Id> accId = new Set<Id>();
        Set<Id> ContactGroupIds = new Set<Id>();
        List<Contact_group__c> contactsGroup = new List<Contact_group__c>();
        List<Contacts_for_Billing__c> contactGroupExist = new List<Contacts_for_Billing__c>();
        Invoice__c invoice;
        Invoice__c billingExist;
        Account acc;
        Boolean isCreateInvoice = bill.get('CreateInvoice') == 'true' ? true : false;

        Recurring_Invoice__c recurringBilling = new Recurring_Invoice__c();
        List<Rec_Billing_Contact_Groups__c> relBillContact = new List<Rec_Billing_Contact_Groups__c>();
        List<Recurring_Invoice_Line__c> insertProduct = new List<Recurring_Invoice_Line__c>();
        List<Invoice_Product__c> insertBillingProduct = new List<Invoice_Product__c>();

        if (bill.get('Billing') != null) {

            List <Invoice__c> invoices = [
                    SELECT Account__c, Billing_City__c, Billing_Country__c, CurrencyIsoCode, Billing_PostalCode__c, Billing_State__c, With_Tax__c,
                            Billing_Street__c, DescriptionAnnex__c, Discount__c, Invoice_Title__c, Opportunity__c, Rounding_difference__c
                            , (
                            SELECT Description__c, Name, Discount_Bexio__c, Position__c, Product__c, Quantity__c, Unit_Price__c, CurrencyIsoCode
                            FROM Invoice_Products__r
                            ORDER BY Position__c ASC
                    )
                    FROM Invoice__c
                    WHERE Id = :bill.get('Billing')
                    LIMIT 1
            ];

            if (invoices.size() > 0) {

                billingExist = invoices.get(0);

                List<Account> accList = [SELECT Id, BillingAddress, AcctSeed__Billing_Contact__c FROM Account WHERE Id = :billingExist.Account__c LIMIT 1];

                if (accList.size() > 0) {
                    acc = accList.get(0);

                    recurringBilling.Opportunity__c = billingExist.Opportunity__c;
                    recurringBilling.Invoice__c = billingExist.Id;
                    recurringBilling.With_Tax__c = billingExist.With_Tax__c;
                    recurringBilling.CurrencyIsoCode = billingExist.CurrencyIsoCode;
                    recurringBilling.Name = String.isNotBlank(bill.get('Name')) ? bill.get('Name') : 'Recurring Invoice (Invoice # ' + billingExist.Invoice__c + ')';
                    recurringBilling.Invoice_Title__c = billingExist.Invoice_Title__c;
                    recurringBilling.Account__c = acc.Id;
                    recurringBilling.Rounding_difference__c = billingExist.Rounding_difference__c;

                    for (Contacts_for_Billing__c billContact : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Invoice__c = :bill.get('Billing')]) {
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

                    if (bill.get('Status') != null) {

                        Schema.DescribeFieldResult fieldResultStatus = Recurring_Invoice__c.Status__c.getDescribe();
                        List<Schema.PicklistEntry> pleStatus = fieldResultStatus.getPicklistValues();
                        for (Schema.PicklistEntry pickListVal : pleStatus) {

                            if (pickListVal.getLabel() == bill.get('Status')) {
                                recurringBilling.Status__c = bill.get('Status');
                            }
                        }
                    }

                    if (bill.get('Frequency') != null) {

                        Schema.DescribeFieldResult fieldResultStatus = Recurring_Invoice__c.Invoice_Frequency__c.getDescribe();
                        List<Schema.PicklistEntry> pleFrequency = fieldResultStatus.getPicklistValues();
                        for (Schema.PicklistEntry pickListVal : pleFrequency) {

                            if (pickListVal.getLabel() == bill.get('Frequency')) {
                                recurringBilling.Invoice_Frequency__c = bill.get('Frequency');
                            }
                        }
                    }
                    System.debug(bill.get('InvoiceDate'));

                    if (bill.get('InvoiceDate') != null) {

                        recurringBilling.Next_Invoice_Date__c = date.valueOf(bill.get('InvoiceDate'));

                    } else {
                        recurringBilling.Next_Invoice_Date__c = Date.today();
                    }

                    for (Business__c buss : [SELECT Id, Account__c, Opportunity__c From Business__c WHERE Opportunity__c = :bill.get('Opportunity')]) {

                        accId.add(buss.Account__c);
                    }

                        insert recurringBilling;

                        for (Rec_Billing_Contact_Groups__c contactBill : relBillContact) {
                            contactBill.Recurring_Invoice__c = recurringBilling.Id;
                        }

                        insert relBillContact;

                    if (isCreateInvoice && recurringBilling != null) {

                        invoice = billingExist.clone(false, false, false, false);
                        invoice.Recurring_Invoice__c = recurringBilling.Id;
                        invoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Draft Invoice').getRecordTypeId();
                        invoice.PDF_Email_Status__c = 'Unsent';
                        invoice.Invoice_Status__c = 'Draft';
                        
                        if (bill.get('InvoiceDate') != null) {

                            invoice.Date__c = date.valueOf(bill.get('InvoiceDate'));

                        } else {
                            invoice.Date__c = Date.today();
                        }

                        invoice.Invoice__c = 'Recurring Invoice - ' + ' (' + recurringBilling.Name + ')';
                        invoice.Accounting_period_Invoice__c = Int_Invoice_Handler.getAccountingPeriod(invoice.Date__c);

//                        if (!Test.isRunningTest()) {
                            insert invoice;

                            for (Contacts_for_Billing__c billInvoice : contactGroupExist) {
                                billInvoice.Invoice__c = invoice.Id;
                            }
                            insert contactGroupExist;
//                        }
                    }

                    for (Invoice_Product__c billProd : billingExist.Invoice_Products__r) {

                        insertProduct.add(createRecurringInvoice(billProd, recurringBilling));

                        if (isCreateInvoice) {
                            Invoice_Product__c billProduct = new Invoice_Product__c();

                            billProduct = billProd.clone(false, false, false, false);
                            billProduct.Invoice__c = invoice.Id;
                            insertBillingProduct.add(billProduct);
                        }
                    }

//                    if (!Test.isRunningTest()) {
                        insert insertProduct;
                        insert insertBillingProduct;
//                    }

                    return Test.isRunningTest() ? 'Test' : recurringBilling.Id;

                } else return 'Not Account';

            } else return 'Not Account';

        } else return 'Not Account';
    }

    private static Recurring_Invoice_Line__c createRecurringInvoice(Invoice_Product__c billProd, Recurring_Invoice__c recurringBilling) {

        Recurring_Invoice_Line__c billRecurringProduct = new Recurring_Invoice_Line__c();

        billRecurringProduct.Product__c = billProd.Product__c;
        billRecurringProduct.Recurring_Invoice__c = recurringBilling.Id;
        billRecurringProduct.Quantity__c = billProd.Quantity__c;
        billRecurringProduct.Unit_Price__c = billProd.Unit_Price__c;
        billRecurringProduct.CurrencyIsoCode = billProd.CurrencyIsoCode;
        billRecurringProduct.Description__c = billProd.Description__c;
        billRecurringProduct.Discount__c = billProd.Discount_Bexio__c;
        billRecurringProduct.Position__c = billProd.Position__c;

        return billRecurringProduct;
    }
}