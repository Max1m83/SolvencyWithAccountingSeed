/**
 * Created by max1m on 16.07.21.
 */
@isTest
public with sharing class MassEditControllerTest {
    @isTest static void contactExtensionTest() {

        Map<String, String> accountOpportunity = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('2', accountOpportunity.get('Opportunity'), accountOpportunity.get('Account'));
        Int_TestCreateObject.contactBilling(Int_TestCreateObject.createContact(), invoiceId, 'TO');
        Int_TestCreateObject.contactBilling(Int_TestCreateObject.createContact(), invoiceId, 'TO');
        List<Contact_entity__c> contacts = [SELECT Position__c, Recipient__c, Contact__c, Contact_group__c FROM Contact_entity__c LIMIT 30];
        Integer position = 1;
        for (Contact_entity__c con : contacts) {
            con.Position__c = position;
            position++;
        }
        update contacts;

        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(contacts);
        sc.setSelected(contacts);
        MassEditController prod = new MassEditController(sc);
        prod.save();
        Test.stopTest();

        System.assertEquals(2, prod.contacts.size());
    }

}