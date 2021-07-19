/**
 * Created by max1m on 16.07.21.
 */

public with sharing class MassEditController
{

    public ApexPages.StandardSetController stdCntrlr {get; set;}
    public List<Contact_entity__c> contacts { get; set; }

    public MassEditController(ApexPages.StandardSetController controller) {

        stdCntrlr = controller;
        List<ContactSortObject> sortContacts = new List<ContactSortObject>();
        List<Contact_entity__c> returnContacts = new List<Contact_entity__c>();
        Map<Id, Contact_entity__c> contactsMap = new Map<Id, Contact_entity__c>();
        Set<Id> contIds = new Set<Id>();
        List<Contact_entity__c> contacts = (List<Contact_entity__c>) controller.getSelected();

        for (Contact_entity__c cont : contacts) {
            contIds.add(cont.Id);
        }

        for (Contact_entity__c cont : [SELECT Position__c, Recipient__c, Contact__c, Contact_group__c FROM Contact_entity__c WHERE Id IN :contIds]) {
            contactsMap.put(cont.Id, cont);
            ContactSortObject sortObject = new ContactSortObject(Integer.valueOf(cont.Position__c), cont.Id);
            sortContacts.add(sortObject);
        }
        sortContacts.sort();

        for (ContactSortObject sortObject : sortContacts) {
            returnContacts.add(contactsMap.get(sortObject.Id));
        }
        this.contacts = returnContacts;
    }

    public PageReference save() {
        update contacts;
        if (contacts.size() > 0) {
            PageReference pageRef = new PageReference('/lightning/r/' + contacts.get(0).Contact_group__c + '/related/Contact_entities__r/view');
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            PageReference pageRef = new PageReference('/lightning/page/home');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }

    public with sharing class ContactSortObject implements Comparable {

        public Integer position;
        public String Id;

        public ContactSortObject(Integer position, String Id) {
            this.position = position;
            this.Id = Id;
        }

        public Integer compareTo(Object compareTo) {

            ContactSortObject emp = (ContactSortObject) compareTo;
            if (position == emp.position) {
                return 0;
            } else if (position > emp.position) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}