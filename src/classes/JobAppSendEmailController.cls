public with sharing class JobAppSendEmailController {

    private static Contact con;

    @AuraEnabled
    public static Map<String, String> GetEmail(String status, String oldStatus, String jobAppIds) {

        Map<String, String> getMap = new Map<String, String>();
        getMap.put('Job', status);

        Job_Application__c job = [SELECT Id, Position__c FROM Job_Application__c WHERE Id = :jobAppIds];

        List<Position__c> positions = [
                SELECT Id, Template_Email_for_stage_Contact_verifi__c, Rejected_Contact_verified__c, Rejected_Phone_interview__c, Rejected_Test__c, Rejected_Any_other_stage__c,
                        Template_Email_for_stage_Final_intervie__c, Template_Email_for_stage_Hired__c, Template_Email_for_stage_New__c, Template_Email_for_stage_Phone_intervie__c,
                        Template_Email_for_stage_Rejected__c, Template_Email_for_stage_Test__c, Travel_Required__c, Sender_email__c, Emails_for_Test_Stage__c
                FROM Position__c
                WHERE Id = :job.Position__c
        ];

        if (positions.size() > 0) {

            if (status == 'New') {
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_New__c
                ], jobAppIds));

            } else if (status == 'Contact verified') {
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_Contact_verifi__c
                ], jobAppIds));

            } else if (status == 'Phone interview') {
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_Phone_intervie__c
                ], jobAppIds));

            } else if (status == 'Test') {
                getMap.put('CC', positions.get(0).Emails_for_Test_Stage__c);
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_Test__c
                ], jobAppIds));

            } else if (status == 'Final interview') {
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_Final_intervie__c
                ], jobAppIds));

            } else if (status == 'Hired') {
                getMap.putAll(createEmailBuilding([
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :positions.get(0).Template_Email_for_stage_Hired__c
                ], jobAppIds));

            } else if (status == 'Rejected') {

                if (oldStatus == 'Contact verified') {

                    getMap.putAll(createEmailBuilding([
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Rejected_Contact_verified__c
                    ], jobAppIds));

                } else if (oldStatus == 'Phone interview') {

                    getMap.putAll(createEmailBuilding([
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Rejected_Phone_interview__c
                    ], jobAppIds));

                } else if (oldStatus == 'Test') {
                    getMap.putAll(createEmailBuilding([
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Rejected_Test__c
                    ], jobAppIds));

                } else {
                    getMap.putAll(createEmailBuilding([
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Rejected_Any_other_stage__c
                    ], jobAppIds));
                }
            }

            if (jobAppIds != null) {
                getMap.putAll(getContact(jobAppIds, positions));
            }
        }

        return getMap;
    }

    @AuraEnabled
    public static String SendEmail(String jobAppIds, String status, String Body, String Subject, String ccEmails) {
        return createSendEmail(jobAppIds, status, Body, Subject, ccEmails);
    }

    public static String createSendEmail(String jobAppIds, String status, String Body, String Subject, String ccEmails) {

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Boolean isError = false;
        List<EmailTemplate> etList;
        String result = 'Success';

        List<Job_Application__c> jobs = [
                SELECT Id, Position__c,Picklist__c, CandidateName__c, Candidate__c
                FROM Job_Application__c
                WHERE Id = :jobAppIds
        ];

        Email_log__c log = new Email_log__c();
        log.Sending_time__c = Datetime.now();
        log.Description__c += 'jobAppIds--->' + jobAppIds + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'Status--->' + status + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'Body--->' + Body + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'Subject--->' + Subject + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';

        if (jobs.size() > 0) {

            Job_Application__c job = jobs.get(0);
            log.Status__c = job.Picklist__c;
            log.Candidate__c = job.CandidateName__c;

            List<Position__c> positions = [
                    SELECT Id, Template_Email_for_stage_Contact_verifi__c, Name,
                            Template_Email_for_stage_Final_intervie__c, Template_Email_for_stage_Hired__c, Template_Email_for_stage_New__c, Template_Email_for_stage_Phone_intervie__c,
                            Template_Email_for_stage_Rejected__c, Template_Email_for_stage_Test__c, Travel_Required__c, Sender_email__c,
                            Rejected_Contact_verified__c, Rejected_Phone_interview__c, Rejected_Test__c, Rejected_Any_other_stage__c
                    FROM Position__c
                    WHERE Id = :job.Position__c
            ];

            if (positions.size() > 0) {

                log.Position__c = positions.get(0).Name;

                if (status == 'New') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_New__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Contact verified') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_Contact_verifi__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Phone interview') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_Phone_intervie__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Test') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_Test__c
                    ];
                    if (etList.size() > 0) {
                        for (Messaging.SingleEmailMessage test : emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions)) {
                            if (String.isNotBlank(ccEmails)) {
                                ccEmails = ccEmails.replaceAll(',', ';').replaceAll(' ', '');              
                                //List<String> listAddress = ccEmails.split(';');
                                List<String> listAddress = new List<String>();
                                listAddress.add('koltunevichmax1m@gmail.com');
                                listAddress.add('maxkolt@tut.by');
                                listAddress.add('maxim.koltunevich@succraft.com');
                                if (listAddress.size() > 0) {
                                   test.ccAddresses = listAddress;
                                    system.debug('---------------------------------------------------');
                                    system.debug(listAddress);
                                    //Map<Id, Contact> cons = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Email = :listAddress]);
                                    //test.setCcAddresses(new List<Id> (cons.keySet())); 
                                    //system.debug(test);
                                
                                }
                            }
                            messages.add(test);
                        }
//                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
//                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Final interview') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_Final_intervie__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Hired') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Template_Email_for_stage_Hired__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }

                } else if (status == 'Rejected') {

                    etList = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName, FolderName, TemplateType, FolderId
                            FROM EmailTemplate
                            WHERE Name = :positions.get(0).Rejected_Contact_verified__c OR Name = :positions.get(0).Rejected_Phone_interview__c OR Name = :positions.get(0).Rejected_Test__c OR Name = :positions.get(0).Rejected_Any_other_stage__c
                    ];
                    if (etList.size() > 0) {
                        messages.addAll(emailCreated([SELECT Id, Candidate_s_email__c, Picklist__c, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)],
                                etList.get(0), Body, Subject, positions));
                    } else {
                        result = 'Error';
                    }
                }

                System.debug(messages);

                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                for (Messaging.SendEmailResult rr : results) {
                    System.debug(rr);
                    System.debug(rr.IsSuccess());
                    if (!rr.IsSuccess()) {
                        log.Description__c += String.valueOf(rr.getErrors());
                        isError = true;
                    }
                }

            } else {
                isError = true;
                log.Description__c += '!!!!!!!!!!!!!!!!!!!!!!' + '\n';
                log.Description__c += 'Job haven`t the Position.';
            }

        } else {

            isError = true;
            log.Description__c += '!!!!!!!!!!!!!!!!!!!!!!' + '\n';
            log.Description__c += 'Job does not exist.' + '\n';
        }

        if (isError) {
            log.Email_Status__c = 'Error';
        } else {
            log.Email_Status__c = 'Success';
        }

        insert log;
        return result;
    }

    @AuraEnabled
    public static String scheduler(String jobAppIds, String status, String Body, String Subject, String nameCandidate, String startDay, String endDay, String ccEmails) {

        if (startDay.length() > 16) {

            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String minutes = startDay.mid(14, 2);
            Integer hours = Integer.valueOf(startDay.mid(11, 2)) + 1;
            Integer days = Integer.valueOf(startDay.mid(8, 2));
            Integer mounths = Integer.valueOf(startDay.mid(5, 2));
            Integer years = Integer.valueOf(startDay.left(4));
            Datetime dateTimeScheduler = Datetime.newInstance(Integer.valueOf(startDay.left(4)),
                    Integer.valueOf(startDay.mid(5, 2)),
                    Integer.valueOf(startDay.mid(8, 2)),
                    Integer.valueOf(startDay.mid(11, 2)),
                    Integer.valueOf(startDay.mid(14, 2)), 0);

            String timeZone = UserInfo.getTimeZone().getID();

            if (timeZone == 'Europe/Berlin') {
                hours = hours;
            }

            String sch = '0 ' + minutes + ' ' + hours + ' ' + days + ' ' + mounths + ' ?';

            String jobName = 'Send email to Candidate ' + nameCandidate + ' (' + jobAppIds + ')';

            List<CronTrigger> scheduleInProgress = [
                    SELECT Id, NextFireTime
                    FROM CronTrigger
                    WHERE CronJobDetail.Name = :jobName
                    LIMIT 1
            ];

            if (!scheduleInProgress.isEmpty()) {
                System.abortJob(scheduleInProgress.get(0).Id);
            }

            EmailScheduledClass reminder = new EmailScheduledClass(jobAppIds, status, Body, Subject, jobName, ccEmails);

            String jobID = System.schedule(jobName, sch, reminder);
            return 'Success';

        } else {
            return 'Error';
        }
    }

    private static List<Messaging.SingleEmailMessage> emailCreated(List<Job_Application__c> jobs, EmailTemplate et, String Body, String Subject, List<Position__c> positions) {

        System.debug('Create Emails');

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        List<Id> ContentDocumentIds = new List<Id>();

        if  (jobs.size() > 0 && positions.size() > 0) {
            Job_Application__c job = jobs.get(0);
            List<Candidate__c> candidates = [SELECT Email__c, Contact__c, First_Name__c, Last_Name__c FROM Candidate__c WHERE Id =: job.Candidate__c];
            OrgWideEmailAddress[] owea = new List<OrgWideEmailAddress>();
            owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :positions.get(0).Sender_email__c];
            if (owea.size() == 0) {
                owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
            }
            if (candidates.size() > 0) {
                Candidate__c candidate = candidates.get(0);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setOrgWideEmailAddressId(owea.get(0).Id);

                List<String> listAddress = new List<String>();
                listAddress.add(job.Candidate_s_email__c);

                message.toAddresses = listAddress;
                message.setSubject(Subject);
                message.setHtmlBody(Body);
                message.setTemplateId(et.Id);
                message.setWhatId(job.Id);

                List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :candidate.Contact__c];
                Contact conNew;

                if (contacts.size() > 0) {
                    conNew = contacts.get(0);
                } else {
                    String email = String.isNotBlank(candidate.Email__c) ? candidate.Email__c : 'solvency@solvency.com';
                    List<Contact> contactExist = [SELECT Id FROM Contact WHERE Email = :email];
                    if (contactExist.size() > 0 ) {
                         conNew = contactExist.get(0);
                    } else {
                        conNew = new Contact();
                        conNew.LastName = String.isNotBlank(candidate.Last_Name__c) ? candidate.Last_Name__c : 'Unknown';
                        conNew.FirstName = candidate.First_Name__c;
                        conNew.Email = email;
                        insert conNew;
                    } 

                    candidate.Contact__c = conNew.Id;
                    update candidate;
                }
                message.setTargetObjectId(conNew.Id);

                List <ContentDocumentLink> docs = [
                        SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :et.Id
                ];

                if (docs.size() > 0) {

                    for (ContentDocumentLink CDLink : [
                            SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId = :et.Id
                    ]) {

                        ContentDocumentIds.add(CDLink.ContentDocumentId);
                    }

                    for (ContentVersion cversion : [
                            SELECT title,
                                    PathOnClient, FileType,
                                    VersionData
                            FROM ContentVersion
                            WHERE ContentDocumentId IN :ContentDocumentIds
                    ]) {
                        blob WOCFbody = cversion.VersionData;

                        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
                        attachFile.setContentType('application/zip');
                        attachFile.setFileName(cversion.title);
                        attachFile.setInline(false);
                        attachFile.Body = WOCFbody;

                        attachments.add(attachFile);

                    }
                    message.setFileAttachments(attachments);
                }
                emailMessages.add(message);
            }
        }
        return emailMessages;
    }

    private static Map<String, String> createEmailBuilding(List<EmailTemplate> listTemplates, String jobAppIds) {

        System.debug('createEmailBuilding');

        Map<String, String> getMap = new Map<String, String>();
        List<Id> ContentDocumentIds = new List<Id>();
        List<Attachment> attachments = new List<Attachment>();

        getMap.put('Status', 'SUCCESS');

        EmailTemplate et;

        if (listTemplates.size() == 0) {

            getMap.put('Status', 'Error. EmailTemplate does not exist.');
            getMap.put('Template', 'Not');
            getMap.put('Subject', '');
            getMap.put('Body', '');
            getMap.put('Attachment', '');
        } else if (listTemplates.size() > 1) {

            getMap.put('Status', 'Error. There is more than one template with the same name.');
            getMap.put('Template', 'More');
            getMap.put('Subject', '');
            getMap.put('Body', '');
            getMap.put('Attachment', '');
        } else {

            et = listTemplates.get(0);

            Messaging.SingleEmailMessage bodyTEmailMessage = createSingleEmailMessage(et, Id.valueOf(jobAppIds));

            getMap.put('Subject', bodyTEmailMessage.Subject.removeStart(' '));
            getMap.put('Body', bodyTEmailMessage.htmlBody.removeStart(' ').replaceAll('\\n', ''));

            List <ContentDocumentLink> docs = [
                    SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :et.Id
            ];

            if (docs.size() > 0) {

                Attachment att = new Attachment();

                List<String> nameAttachmentDocuments = new List<String>();

                for (ContentDocumentLink CDLink : [
                        SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :et.Id
                ]) {

                    ContentDocumentIds.add(CDLink.ContentDocumentId);
                }

                for (ContentVersion cversion : [
                        SELECT Id, title, ContentDocumentId,
                                PathOnClient, FileType,
                                VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId IN :ContentDocumentIds
                ]) {

                    if (String.valueOf(cversion.title).indexOfAnyBut('.' + cversion.FileType.toLowerCase()) != -1) {
                        att.nameFile = String.valueOf(cversion.title) + '.' + cversion.FileType.toLowerCase();
                    } else {
                        nameAttachmentDocuments.add(String.valueOf(cversion.title));
                        att.nameFile = String.valueOf(cversion.title);
                    }
                    att.urlFile = '/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view';
                    attachments.add(att);

                }
                getMap.put('Attachments', JSON.serialize(attachments));
            } else {
                getMap.put('Attachments', '');
            }
        }

        return getMap;
    }

    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailTemplate et, Id jobId) {

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Name = 'Recruiting'];
        if (contacts.size() > 0) {
            con = contacts.get(0);
        } else {
            con = [SELECT Id FROM Contact LIMIT 1];
        }

        return Messaging.renderStoredEmailTemplate(et.Id, con.Id, jobId);
    }

    private static Map<String, String> getContact(String jobAppIds, List<Position__c> positions) {

        Map<String, String> getMap = new Map<String, String>();

        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];

        if (positions.size() > 0 && String.isNotBlank(positions.get(0).Sender_email__c)) {
            getMap.put('FROM', positions.get(0).Sender_email__c);
        } else if (owea.size() > 0) {
            getMap.put('FROM', owea.get(0).Address);
        } else {
            getMap.put('Status', 'Error. Do not specify the address of the organization.');
            getMap.put('FROM', '');
        }

        Job_Application__c job = [SELECT Id, Candidate__c FROM Job_Application__c WHERE Id = :Id.valueOf(jobAppIds)];

        if (job != null) {
            Candidate__c candidate = [SELECT Id, Email__c, Last_Name__c, First_Name__c FROM Candidate__c WHERE Id = :Id.valueOf(job.Candidate__c)];

            if (candidate != null) {
                getMap.put('TO', String.valueOf(candidate.Email__c));
                getMap.put('CandidateName', String.valueOf(candidate.Last_Name__c) + ' ' + String.valueOf(candidate.First_Name__c));
            }
        }
        return getMap;
    }

    public class Attachment {
        public String nameFile {
            get;
            set;
        }
        public String urlFile {
            get;
            set;
        }
    }
}