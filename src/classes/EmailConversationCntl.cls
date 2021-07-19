/**
 * Created by max1m on 01.10.20.
 */

global with sharing class EmailConversationCntl {
    @AuraEnabled
    global static List<EmailMessage> getEmailMessages(String billIds){


        Set<Id> conIds = new Set<Id>();
        Set<Id> conEntityIds = new Set<Id>();
        List<Contact> contacts = new List<Contact>();
        List<EmailMessage> allEmailMessages = new List<EmailMessage>();

        for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billIds ]) {
            conEntityIds.add(conBill.Contact_group__c);
        }

        for (Contact_group__c groupCont : [SELECT Id,
        (SELECT Id, Contact__c FROM Contact_entity__r)
        FROM Contact_group__c WHERE Id IN :conEntityIds]) {
            for (Contact_entity__c contact : groupCont.Contact_entity__r) {
                conIds.add(contact.Contact__c);
            }
        }

        for (Contact con : [SELECT Id, Email, Name FROM Contact WHERE Id IN :conIds]) {
            contacts.add(con);
        }

        EmailTemplate template = [Select id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName from EmailTemplate where name = 'Test Template Name' limit 1];



        EmailMessage mess = new EmailMessage();
        mess.EmailTemplateId = template.Id;
        mess.EmailTemplateId = template.Id;
        if (contacts.size() >0) {
            mess.CcAddress = contacts[0].Email;
        }
        allEmailMessages.add(mess);


        return allEmailMessages;

    }

    @AuraEnabled
    global static string getpassemaildetails(String RecordId){

        List<Contact> contacts = new List<Contact>();

        for (Account acc : [SELECT Id, OwnerId, (SELECT Id, OwnerId FROM Contacts) FROM Account]) {
           for (Contact con : acc.Contacts) {
               if (con.OwnerId != acc.OwnerId) {
                   con.OwnerId = acc.OwnerId;
                   contacts.add(con);
               }
           }
        }
        update contacts;

        return 'sylvester@stalone.de';
    }


    @AuraEnabled
    global static EmailMessage getemailAddress(String EMsgId){
        system.debug('>>>>>>>>>>Id>>>'+ EMsgId);
        string emid = EMsgId;
        system.debug('>>>>>>>>>>RecordId>>>'+ emid);
        List<EmailMessage> passemid = [select id,FromAddress,TextBody,ToAddress,Subject,HtmlBody,Incoming from EmailMessage WHERE id =: emid limit 1];
        string email='';

        return passemid[0];
    }
}