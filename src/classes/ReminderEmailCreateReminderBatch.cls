/**
 * Created by max1m on 8.06.21.
 */

public with sharing class ReminderEmailCreateReminderBatch implements Database.Batchable<Integer>, Database.Stateful, Schedulable {

    private Map<Id, Invoice__c> invoices;
    private List<Invoice__c> overdueInvoices;
    private Integer chunkSize = 200;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        this.invoices = new Map<Id, Invoice__c>([
                SELECT Id, Account__c, Company_name__c, Invoice__c, CurrencyIsoCode, (SELECT Reminder_email__c FROM Invoice_Contact_Groups_Billing__r)
                FROM Invoice__c
                WHERE Invoice_Status__c = 'Overdue'
        ]);

        for (Reminder_email__c emails : [
                SELECT Invoice__c
                FROM Reminder_email__c
                WHERE Invoice__c IN :this.invoices.keySet()
        ]) {
            this.invoices.remove(emails.Invoice__c);
        }
        this.overdueInvoices = this.invoices.values();

        return Int_Utils.generateCountOfChuncks(this.overdueInvoices.size(), this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        Map<Id, Reminder_email__c> createListReminders = new Map<Id, Reminder_email__c>();
        List<Contacts_for_Billing__c> contacts = new List<Contacts_for_Billing__c>();

        Integer startIndex = batchIndexes[0] * 200;
        Integer finishIndex = (batchIndexes[0] + 1) * 200 < this.overdueInvoices.size() ? (batchIndexes[0] + 1) * 200 : this.overdueInvoices.size() - 1;

        for (Integer i = startIndex; i < finishIndex; i++) {

            createListReminders.putAll(createEmailObject(this.overdueInvoices.get(i)));

        }
        upsert createListReminders.values();

        for (Integer i = startIndex; i < finishIndex; i++) {
            contacts.addAll(updateContacts(this.overdueInvoices.get(i), createListReminders.get(this.overdueInvoices.get(i).Id)));
        }
        update contacts;
    }

    public void finish(Database.BatchableContext BC) {
        System.scheduleBatch(new ReminderEmailBatch(), 'Reminder Email Batch (Updated Reminder Emails)', 1, 1);
    }

    private static List<Contacts_for_Billing__c> updateContacts(Invoice__c invoice, Reminder_email__c reminderMap) {
        List<Contacts_for_Billing__c> returnContacts = new List<Contacts_for_Billing__c>();
        for (Contacts_for_Billing__c cont : invoice.Invoice_Contact_Groups_Billing__r) {
            cont.Reminder_email__c = reminderMap.Id;
            returnContacts.add(cont);
        }
        return returnContacts;
    }

    private static Map<Id, Reminder_email__c> createEmailObject(Invoice__c invoice) {

        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];

        Reminder_email__c newReminder = new Reminder_email__c();
        newReminder.Account__c = invoice.Account__c;
        newReminder.CurrencyIsoCode = invoice.CurrencyIsoCode;
        newReminder.Date_create__c = Datetime.now();
        newReminder.Invoice__c = invoice.Id;
        newReminder.isCancel__c = false;
        newReminder.Reminder_Stage__c = 'Overdue';
        newReminder.Name = (invoice.Company_name__c != null ? invoice.Company_name__c : invoice.Invoice__c);
        newReminder.Picture_Status__c = 'Overdue';
        newReminder.Settings_Reminder_email__c = (settingsReminder.size() > 0 ? settingsReminder.get(0).Id : '');
        newReminder.Status__c = 'Unsent';
        return new Map<Id, Reminder_email__c>{
                invoice.Id => newReminder
        };
    }

    public void execute(SchedulableContext ctx) {
        System.scheduleBatch(new ReminderEmailCreateReminderBatch(), 'Reminder Email Batch (Create Reminder Emails)', 1, 1);
    }
}