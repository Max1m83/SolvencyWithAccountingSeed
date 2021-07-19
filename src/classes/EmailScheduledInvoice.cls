/**
 * Created by sergei on 7/14/21.
 */

global with sharing class EmailScheduledInvoice implements Schedulable {

    private String body;
    private String subjectEmail;
    private String jobName;
    private String accountEmail;
    private String emailTemplateName;
    private Id invoiceId;
    private String emailsCC;
    private String emailsTO;

    global EmailScheduledInvoice(String body, String subject, String jobName, String accountEmail, String emailTemplateName, Id invoiceId, String emailsCC, String emailsTO) {
        this.body = body;
        this.subjectEmail = subject;
        this.jobName = jobName;
        this.accountEmail = accountEmail;
        this.emailTemplateName = emailTemplateName;
        this.invoiceId = invoiceId;
        this.emailsCC = emailsCC;
        this.emailsTO = emailsTO;
    }

    public void execute(SchedulableContext param1) {
        String result = Int_SendEmailController.createSendEmailInvoice(body, subjectEmail, accountEmail, emailTemplateName, invoiceId, emailsCC, emailsTO);

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