/**
 * Created by max1m on 05.02.21.
 */

global with sharing class EmailScheduledClass implements Schedulable {

    private String jobAppIds;
    private String statusWork;
    private String body;
    private String SubjectEmail;
    private String jobName;
    private String ccEmails;

    global EmailScheduledClass(String jobAppIds, String statusWork, String body, String SubjectEmail, String jobName, String ccEmails) {
        this.jobAppIds = jobAppIds;
        this.statusWork = statusWork;
        this.body = body;
        this.SubjectEmail = SubjectEmail;
        this.jobName = jobName;
        this.ccEmails = ccEmails;
    }

    global void execute(SchedulableContext sc) {

        String result = JobAppSendEmailController.createSendEmail(jobAppIds, statusWork, Body, SubjectEmail, ccEmails);

        List<CronTrigger> scheduleInProgress = [
                SELECT Id, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = :this.jobName
                LIMIT 1
        ];

        if (!scheduleInProgress.isEmpty()) {
            System.abortJob(scheduleInProgress.get(0).Id);
        }
    }
}