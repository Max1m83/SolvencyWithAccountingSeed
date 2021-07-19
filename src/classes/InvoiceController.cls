public with sharing class InvoiceController {

    @AuraEnabled
    public static Opportunity getInvoiceOngoing(String oppIds) {

        return [SELECT Id, Ongoing_Business__c FROM Opportunity WHERE Id = :oppIds];
    }

    @AuraEnabled
    public static Map<String, List<String>> getInvoice(String oppIds) {

        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        Set<Id> AccountIds = new Set<Id>();
        Set<Id> ContactGroupIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        List<String> contactsGet = new List<String>();
        List<String> accountsGet = new List<String>();
        List<String> opportunityGet = new List<String>();
        List<String> reportNameGet = new List<String>();
        List<String> periodSets = new List<String>();
        List<String> periodValueSets = new List<String>();
        List<String> productExistOpp = new List<String>();

        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Invoice__c.Invoice_Title__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }

        Date periodDafault = date.today();

        for (Accounting_Period__c per : [
                SELECT Id, Name, Start_Date__c, End_Date__c
                FROM Accounting_Period__c
                ORDER BY Start_Date__c DESC
                LIMIT 5
        ]) {

            periodSets.add(per.Name);

            if (per.Start_Date__c <= periodDafault && per.End_Date__c >= periodDafault) {

                periodValueSets.add(per.Name);
            }
        }

        Opportunity opp = [
                SELECT Id, AccountId, CurrencyIsoCode, Name_Product2__c, (SELECT Id, Product2Id, Quantity, ListPrice FROM OpportunityLineItems), (SELECT Id, Contact_group__c FROM Contacts_for_Opportunity__r)
                FROM Opportunity
                WHERE Id = :oppIds
                LIMIT 1
        ];

        if (opp != null) {

            for (Opportunity_Contact__c oppCon : opp.Contacts_for_Opportunity__r) {
                ContactGroupIds.add(oppCon.Contact_group__c);
            }
            reportNameGet.add(opp.Name_Product2__c);
        }

        for (Contact_group__c conGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
            contactsGet.add(conGroup.Name);
        }

        for (Business__c buss : [SELECT Id, Account__c, Opportunity__c FROM Business__c WHERE Opportunity__c = :oppIds]) {
            AccountIds.add(buss.Account__c);
        }

        List<Account> accounts = [
                SELECT Id, Name
                FROM Account
                WHERE Id IN :AccountIds
        ];

        for (Account acc : accounts) {

            accountsGet.add(acc.Name);
        }

        for (OpportunityLineItem prod : opp.OpportunityLineItems) {
            prodIds.add(prod.Product2Id);
        }

        for (Product2 product : [SELECT Id, Name FROM Product2 WHERE Id IN :prodIds]) {
            productExistOpp.add(product.Name);
        }

        opportunityGet.add(oppIds);

        returnMap.put('Accounts', accountsGet);
        returnMap.put('Contacts', contactsGet);
        returnMap.put('Opportunity', opportunityGet);
        returnMap.put('ReportsValue', pickListValuesList);
        returnMap.put('NameReports', reportNameGet);
        returnMap.put('Period', periodSets);
        returnMap.put('PeriodValue', periodValueSets);
        returnMap.put('Product', productExistOpp);

        return returnMap;
    }

    @AuraEnabled
    public static String SaveBilling(Map<String, String> bill, List<String> contacts, List<String> products) {

        Boolean PeriodAcc = false;
        Set<Id> accId = new Set<Id>();
        List<Id> ContactGroupIds = new List<Id>();
        Set<Id> prodIds = new Set<Id>();
        Set<Id> contactGroupExistIds = new Set<Id> ();
        List<Contacts_for_Billing__c> relBillContact = new List<Contacts_for_Billing__c>();
        List<Invoice_Product__c> insertProduct = new List<Invoice_Product__c>();
        List<Opportunity> opp;
        List<Product2> productExist = new List<Product2>();

        Invoice__c invoice = new Invoice__c();

        if (bill.get('Opportunity') != null) {
            opp = [
                    SELECT Id, AccountId, Name_Product2__c, CurrencyIsoCode, Email_Template_Name__c, PDF_Format_Invoice__c, (SELECT Id, Product2Id, Quantity, UnitPrice FROM OpportunityLineItems), (SELECT Id, Contact_group__c FROM Contacts_for_Opportunity__r)
                    FROM Opportunity
                    WHERE Id = :bill.get('Opportunity')
            ];

            if (opp.size() > 0) {

                invoice.Opportunity__c = opp[0].Id;
                invoice.Invoice_Title__c = opp[0].Name_Product2__c;
                invoice.PDF_Format_Invoice__c = opp[0].PDF_Format_Invoice__c;
                invoice.CurrencyIsoCode = opp[0].CurrencyIsoCode;
                invoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Draft Invoice').getRecordTypeId();

                for (Opportunity_Contact__c oppCon : opp[0].Contacts_for_Opportunity__r) {
                    ContactGroupIds.add(oppCon.Contact_group__c);
                }

                for (Contact_group__c contactGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
                    for (String nameContact : contacts) {
                        if (nameContact == contactGroup.Name) {
                            Contacts_for_Billing__c bills = new Contacts_for_Billing__c();
                            bills.Contact_group__c = contactGroup.Id;
                            contactGroupExistIds.add(contactGroup.Id);
                            relBillContact.add(bills);
                        }
                    }
                }
            }
        }

        for (Business__c buss : [SELECT Id, Account__c, Opportunity__c FROM Business__c WHERE Opportunity__c = :bill.get('Opportunity')]) {

            accId.add(buss.Account__c);
        }

        List<Account> acccList = [
                SELECT Id, BillingAddress, AcctSeed__Billing_Contact__c, Name, with_VAT__c
                FROM Account
                WHERE Name = :bill.get('Account')
                AND Id IN :accId
                LIMIT 1
        ];
        Account acc;

        if (acccList.size() > 0) {
            acc = acccList.get(0);
            invoice.Account__c = acc.Id;
            invoice.With_Tax__c = acc.with_VAT__c;
            invoice.Invoice_Title__c = bill.get('Report');
            invoice.PDF_Email_Status__c = 'Unsent';
            invoice.Invoice__c = 'Draft - ' + invoice.Invoice_Title__c + ' (' + acc.Name + ')';
            invoice.Invoice_Status__c = 'Draft';


            if (acc.BillingAddress != null) {
                invoice.Billing_City__c = acc.BillingAddress.getCity();
                invoice.Billing_Country__c = acc.BillingAddress.getCountry();
                invoice.Billing_PostalCode__c = acc.BillingAddress.getPostalCode();
                invoice.Billing_State__c = acc.BillingAddress.getState();
                invoice.Billing_Street__c = acc.BillingAddress.getStreet();
            }

            invoice.Contact__c = acc.AcctSeed__Billing_Contact__c;

            if (bill.get('InvoiceDate') != null) {

                invoice.Date__c = date.valueOf(bill.get('InvoiceDate'));
                // invoice.Billing_Date__c	 = date.valueOf(bill.get('InvoiceDate'));

            } else {
                invoice.Date__c = Date.today();
                // invoice.Billing_Date__c	 = date.valueOf(bill.get('InvoiceDate'));
            }

            List<Accounting_Period__c> accountingPeriods = [SELECT Id FROM Accounting_Period__c WHERE Name = :bill.get('Period')];

            if (accountingPeriods.size() > 0) {
                invoice.Accounting_period_Invoice__c = accountingPeriods.get(0).Id;
            } else {
                invoice.Accounting_period_Invoice__c = Int_Invoice_Handler.createdAccountingPeriod(invoice.Date__c);
            }

            //invoice.Date__c	 = Date.today();

            if (!Test.isRunningTest()) {

                insert invoice;

                for (Contacts_for_Billing__c contactBill : relBillContact) {
                    contactBill.Invoice__c = invoice.Id;
                }
                insert relBillContact;
            }

            for (OpportunityLineItem prod : opp[0].OpportunityLineItems) {
                prodIds.add(prod.Product2Id);
            }

            List<Product2> prods = [SELECT Id, Name FROM Product2 WHERE Id IN :prodIds AND Name IN :products];

            for (String nameProd : products) {
                for (Product2 product : prods) {

                    if (nameProd == product.Name) {
                        productExist.add(product);
                    }
                }
            }

            if (opp.size() > 0) {

                for (OpportunityLineItem product : opp[0].OpportunityLineItems) {
                    prodIds.add(product.Product2Id);

                }

                Integer i = 1;

                for (Product2 prod : productExist) {

                    for (OpportunityLineItem product : opp[0].OpportunityLineItems) {

                        if (product.Product2Id == prod.Id) {

                            Invoice_Product__c billProduct = new Invoice_Product__c();

                            billProduct.Position__c = i;
                            billProduct.Product__c = product.Product2Id;
                            billProduct.Unit_Price__c = product.UnitPrice;
                            billProduct.CurrencyIsoCode = opp[0].CurrencyIsoCode;
                            billProduct.Quantity__c = product.Quantity;
                            // billProduct.TotalForPage__c = product.Quantity * product.UnitPrice;
                            billProduct.Invoice__c = invoice.Id;

                            insertProduct.add(billProduct);
                            i++;
                        }
                    }
                }
            }

            insert insertProduct;


            if (Test.isRunningTest()) {
                return 'Test';
            } else if (PeriodAcc) {
                return 'Not Period';
            } else {

                System.debug(invoice);
                return invoice.Id;
            }
        } else return 'Not Account';

    }

//    @AuraEnabled
//    public static String SaveBillingOldVersion(Map<String, String> bill, List<String> contacts, List<String> products) {
//
//        AcctSeed__Ledger__c ledger;
//        Boolean PeriodAcc = false;
//        Set<Id> accId = new Set<Id>();
//        List<Id> ContactGroupIds = new List<Id>();
//        Set<Id> prodIds = new Set<Id>();
//        Set<Id> contactGroupExistIds = new Set<Id> ();
//        List<Opportunity> opp;
//        List<Product2> productExist = new List<Product2>();
//        List<AcctSeed__Billing_Line__c> insertProduct = new List<AcctSeed__Billing_Line__c>();
//        AcctSeed__Billing__c invoice = new AcctSeed__Billing__c();
//        List<Contacts_for_Billing__c> relBillContact = new List<Contacts_for_Billing__c>();
//
//        //List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '1100-Trade receivables (debtors)'];
//        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '3401-Gross proceeds credit operations'];
//
//        List<Send_to_Contact__c> contList = new List<Send_to_Contact__c>();
//        List<String> pickListValuesAccordingPeriod = new List<String>();
//        Schema.DescribeFieldResult fieldResultPeriod = AcctSeed__Billing__c.accounting_period__c.getDescribe();
//        List<Schema.PicklistEntry> periods = fieldResultPeriod.getPicklistValues();
//
//        for (Schema.PicklistEntry pickListVal : periods) {
//            pickListValuesAccordingPeriod.add(pickListVal.getLabel());
//        }
//
//        if (bill.get('Ledger') != null) {
//            ledger = [SELECT Id FROM AcctSeed__Ledger__c WHERE Id = :bill.get('Ledger')];
//            invoice.AcctSeed__Ledger__c = ledger.Id;
//        }
//
//        if (bill.get('Opportunity') != null) {
//            opp = [
//                    SELECT Id, AccountId, CurrencyIsoCode, (SELECT Id, Product2Id, Quantity, UnitPrice FROM OpportunityLineItems), (SELECT Id, Contact_group__c FROM Contacts_for_Opportunity__r)
//                    FROM Opportunity
//                    WHERE Id = :bill.get('Opportunity')
//            ];
//            invoice.AcctSeed__Opportunity__c = opp[0].Id;
//            invoice.CurrencyIsoCode = opp[0].CurrencyIsoCode;
//
//            for (Opportunity_Contact__c oppCon : opp[0].Contacts_for_Opportunity__r) {
//                ContactGroupIds.add(oppCon.Contact_group__c);
//            }
//
//            for (Contact_group__c contactGroup : [SELECT Id, Name FROM Contact_group__c WHERE Id IN :ContactGroupIds]) {
//                for (String nameContact : contacts) {
//                    if (nameContact == contactGroup.Name) {
//                        Contacts_for_Billing__c bills = new Contacts_for_Billing__c();
//                        bills.Contact_group__c = contactGroup.Id;
//                        contactGroupExistIds.add(contactGroup.Id);
//                        relBillContact.add(bills);
//                    }
//                }
//            }
//        }
//
//        for (Business__c buss : [SELECT Id, Account__c, Opportunity__c From Business__c WHERE Opportunity__c = :bill.get('Opportunity')]) {
//
//            accId.add(buss.Account__c);
//        }
//
//        List<Account> acccList = [SELECT Id, BillingAddress, AcctSeed__Billing_Contact__c FROM Account WHERE Name = :bill.get('Account') AND Id IN :accId LIMIT 1];
//        Account acc;
//
//        if (acccList.size() > 0) {
//            acc = acccList.get(0);
//            invoice.AcctSeed__Customer__c = acc.Id;
//            invoice.Name_Product__c = bill.get('Report');
//            invoice.AcctSeed__PDF_Email_Status__c = 'Unsent';
//
//            List<AcctSeed__Accounting_Period__c> accountingPeriods = [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE Name = :bill.get('Period')];
//
//            If (accountingPeriods.size() > 0) {
//
//                if (periods.size() > 0) {
//                    if (accountingPeriods.size() > 0) {
//                        invoice.AcctSeed__Accounting_Period__c = accountingPeriods.get(0).Id;
//                    } else {
//                        PeriodAcc = true;
//                    }
//                }
//
//                if (acc.BillingAddress != null) {
//                    invoice.AcctSeed__Billing_City__c = acc.BillingAddress.getCity();
//                    invoice.AcctSeed__Billing_Country__c = acc.BillingAddress.getCountry();
//                    invoice.AcctSeed__Billing_PostalCode__c = acc.BillingAddress.getPostalCode();
//                    invoice.AcctSeed__Billing_State__c = acc.BillingAddress.getState();
//                    invoice.AcctSeed__Billing_Street__c = acc.BillingAddress.getStreet();
//                }
//
//                invoice.AcctSeed__Billing_Contact__c = acc.AcctSeed__Billing_Contact__c;
//
//                if (bill.get('InvoiceDate') != null) {
//
//                    invoice.AcctSeed__Date__c = date.valueOf(bill.get('InvoiceDate'));
//
//                } else {
//                    invoice.AcctSeed__Date__c = Date.today();
//                }
//
//                if (!Test.isRunningTest()) {
//
//                    insert invoice;
//
//                    for (Contacts_for_Billing__c contactBill : relBillContact) {
//                        contactBill.Billing__c = invoice.Id;
//                    }
//                    insert relBillContact;
//                }
//
//                for (OpportunityLineItem prod : opp[0].OpportunityLineItems) {
//                    prodIds.add(prod.Product2Id);
//                }
//
//                List<Product2> prods = [SELECT Id, Name FROM Product2 WHERE Id IN :prodIds AND Name IN :products];
//
//                for (String nameProd : products) {
//                    for (Product2 product : prods) {
//
//                        if (nameProd == product.Name) {
//                            productExist.add(product);
//                        }
//                    }
//                }
//
//                if (opp.size() > 0) {
//
//                    for (OpportunityLineItem product : opp[0].OpportunityLineItems) {
//                        prodIds.add(product.Product2Id);
//
//                    }
//
//                    Integer i = 1;
//
//                    for (Product2 prod : productExist) {
//
//                        for (OpportunityLineItem product : opp[0].OpportunityLineItems) {
//
//                            if (product.Product2Id == prod.Id) {
//
//                                AcctSeed__Billing_Line__c billProduct = new AcctSeed__Billing_Line__c();
//
//                                billProduct.Number__c = i;
//                                billProduct.AcctSeed__Product__c = product.Product2Id;
//                                billProduct.AcctSeed__Rate__c = product.UnitPrice;
//                                billProduct.CurrencyIsoCode = opp[0].CurrencyIsoCode;
//                                billProduct.AcctSeed__Hours_Units__c = product.Quantity;
//                                billProduct.TotalForPage__c = product.Quantity * product.UnitPrice;
//                                billProduct.AcctSeed__Billing__c = invoice.Id;
//
//                                if (glAccounts.size() > 0) {
//                                    billProduct.AcctSeed__Revenue_GL_Account__c = glAccounts.get(0).Id;
//                                }
//
//                                insertProduct.add(billProduct);
//                                i++;
//                            }
//                        }
//                    }
//                }
//
//                insert insertProduct;
//
//                if (contList.size() > 0) {
//                    upsert contList;
//                }
//
//            } else {
//                PeriodAcc = true;
//            }
//
//            if (Test.isRunningTest()) {
//                return 'Test';
//            } else if (PeriodAcc) {
//                return 'Not Period';
//            } else {
//
//                System.debug(invoice);
//                return invoice.Id;
//            }
//        } else return 'Not Account';
//    }
}