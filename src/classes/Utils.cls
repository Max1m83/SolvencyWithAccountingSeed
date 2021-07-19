/**
 * Created by max1m on 15.06.21.
 */

public with sharing class Utils {

    public static Reminder_email__c createEmailObject(Invoice__c invoice, List<Settings_Reminder_email__c> settingsReminder ) {

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
        return newReminder;
    }

    public static void checkReminderEmails() {

        Set<Id> invoiceIds = new Set<Id>();
        List<Reminder_email__c> reminders = new List<Reminder_email__c>();

        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];

        for (Reminder_email__c rem : [SELECT Invoice__c FROM Reminder_email__c]) {
            invoiceIds.add(rem.Invoice__c);
        }

        for (Invoice__c invoice : [
                SELECT Id, Account__c, CurrencyIsoCode, Company_name__c, Invoice__c
                FROM Invoice__c
                WHERE Invoice_Status__c = 'Overdue' AND Id NOT IN :invoiceIds
        ]) {
            reminders.add(createEmailObject(invoice, settingsReminder));
        }

        insert reminders;
    }
}