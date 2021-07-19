public with sharing class ReminderEmailBatch implements Database.Batchable<Integer>, Database.Stateful, Schedulable {

    private List<Reminder_email__c> reminders;
    private Integer chunkSize = 200;
    private Map<String, Integer> days;

    public Iterable<Integer> start(Database.BatchableContext BC) {

        this.reminders = [
                SELECT Id, Count_days__c, Last_change_date_of_stage__c, Picture_Status__c
                FROM Reminder_email__c
        ];
        this.days = daysToStages([
                SELECT Id, Days_to_stage_1__c, Days_to_stage_2__c, Days_to_stage_3__c
                FROM Settings_Reminder_email__c
        ]);

        return Int_Utils.generateCountOfChuncks(this.reminders.size(), this.chunkSize, 1);
    }

    public void execute(Database.BatchableContext BC, List<Integer> batchIndexes) {

        List<Reminder_email__c> updatedRemainder = new List<Reminder_email__c>();

        Integer startIndex = (batchIndexes[0] - 1) * 200;
        Integer finishIndex = batchIndexes[0] * 200 < this.reminders.size() ? batchIndexes[0] * 200 : this.reminders.size();

        for (Integer i = startIndex; i < finishIndex; i++) {
            if (i < this.reminders.size()) {
                updatedRemainder.add(updateReminders(this.reminders.get(i)));
            }
        }
        update updatedRemainder;
    }

    public void finish(Database.BatchableContext BC) {
        Utils.checkReminderEmails();
    }

    private static Map<String, Integer> daysToStages(List<Settings_Reminder_email__c> settings) {

        //Map with default values
        Map<String, Integer> days = new Map<String, Integer>{
                'Sent (Overdue)' => 10, 'Sent (Stage 2)' => 10, 'Sent (Stage 3)' => 10
        };

        if (settings.size() > 0) {
            if (settings.get(0).Days_to_stage_1__c != 0) {
                days.put('Sent (Overdue)', Integer.valueOf(settings.get(0).Days_to_stage_1__c));
            }
            if (settings.get(0).Days_to_stage_2__c != 0) {
                days.put('Sent (Stage 2)', Integer.valueOf(settings.get(0).Days_to_stage_2__c));
            }
            if (settings.get(0).Days_to_stage_3__c != 0) {
                days.put('Sent (Stage 3)', Integer.valueOf(settings.get(0).Days_to_stage_3__c));
            }
        }

        return days;
    }

    private Reminder_email__c updateReminders(Reminder_email__c reminder) {

        reminder.Count_days__c = reminder.Last_change_date_of_stage__c.daysBetween(Date.today());
        if (reminder.Picture_Status__c == 'Sent (Overdue)' || reminder.Picture_Status__c == 'Sent (Stage 2)'
                || reminder.Picture_Status__c == 'Sent (Stage 3)') {
            if (reminder.Count_days__c > this.days.get(reminder.Picture_Status__c)) {
                reminder.Picture_Status__c = reminder.Picture_Status__c == 'Sent (Overdue)' ? 'Stage 2' :
                        (reminder.Picture_Status__c == 'Sent (Stage 2)' ? 'Stage 3' : 'Overdue (Stage 3)');
            }
        }

        return reminder;
    }

    public void execute(SchedulableContext ctx) {
        System.scheduleBatch(new ReminderEmailBatch(), 'Reminder Email Batch', 1, 1);
    }
}