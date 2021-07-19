/**
 * Created by max1m on 28.06.21.
 */

public with sharing class ReminderBatch implements Database.Batchable<sObject>, Schedulable {

    public final static Map<String, Integer> days = new Map<String, Integer>();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        days.putAll(daysToStages([
                SELECT Id, Days_to_stage_1__c, Days_to_stage_2__c, Days_to_stage_3__c
                FROM Settings_Reminder_email__c
        ]));

        return Database.getQueryLocator(
                'SELECT ID, Count_days__c, Last_change_date_of_stage__c, Picture_Status__c, ' +
                        'Due_Date__c, Overdue_days__c FROM Reminder_email__c'

        );
    }

    public void execute(Database.BatchableContext BC, List<Reminder_email__c> scope) {
        for (Reminder_email__c reminder : scope) {
            updateReminders(reminder);
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
        Utils.checkReminderEmails();
    }

    private Reminder_email__c updateReminders(Reminder_email__c reminder) {

        reminder.Count_days__c = reminder.Last_change_date_of_stage__c.daysBetween(Date.today());
        reminder.Overdue_days__c = reminder.Due_Date__c.daysBetween(Date.today());

        if (reminder.Picture_Status__c == 'Sent (Overdue)' || reminder.Picture_Status__c == 'Sent (Stage 2)'
                || reminder.Picture_Status__c == 'Sent (Stage 3)') {
            if (reminder.Count_days__c > days.get(reminder.Picture_Status__c)) {
                reminder.Picture_Status__c = reminder.Picture_Status__c == 'Sent (Overdue)' ? 'Stage 2' :
                        (reminder.Picture_Status__c == 'Sent (Stage 2)' ? 'Stage 3' : 'Overdue (Stage 3)');
            }
        }

        return reminder;
    }

    private static Map<String, Integer> daysToStages(List<Settings_Reminder_email__c> settings) {

        //Map with default values
        Map<String, Integer> daysDefault = new Map<String, Integer>{
                'Sent (Overdue)' => 10, 'Sent (Stage 2)' => 10, 'Sent (Stage 3)' => 10
        };

        if (settings.size() > 0) {
            if (settings.get(0).Days_to_stage_1__c != 0) {
                daysDefault.put('Sent (Overdue)', Integer.valueOf(settings.get(0).Days_to_stage_1__c));
            }
            if (settings.get(0).Days_to_stage_2__c != 0) {
                daysDefault.put('Sent (Stage 2)', Integer.valueOf(settings.get(0).Days_to_stage_2__c));
            }
            if (settings.get(0).Days_to_stage_3__c != 0) {
                daysDefault.put('Sent (Stage 3)', Integer.valueOf(settings.get(0).Days_to_stage_3__c));
            }
        }

        return daysDefault;
    }

    public void execute(SchedulableContext ctx) {
        System.scheduleBatch(new ReminderBatch(), 'Reminder Email Batch', 1, 1);
    }
}