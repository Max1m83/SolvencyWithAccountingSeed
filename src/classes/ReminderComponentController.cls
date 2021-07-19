/**
 * Created by max1m on 1.06.21.
 */

public with sharing class ReminderComponentController {

    @AuraEnabled
    public static String sendEmail(String idReminder, String Body, String Subject, String toAddress, String ccAddress, List<Map<String, String>> attach) {

        String result = 'Error';
        Set<Id> attachmentIds = new Set<Id>();

        for (Map<String, String> att : attach) {
            attachmentIds.add(att.get('Id'));
        }

        List<Id> ContentDocumentIds = new List<Id>();
        List<Messaging.SingleEmailMessage> sendEmails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        List<String> ccAddresses = String.isNotBlank(ccAddress) ? ccAddress.split(',') : new List<String>();
        List<String> toEmail = String.isNotBlank(toAddress) ? toAddress.split(',') : new List<String>();

        Integer countEmails = ccAddresses.size() + toEmail.size();

        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
        List<Reminder_email__c> rems = [
                SELECT Picture_Status__c, AccountCompanyName__c, Settings_Reminder_email__c, Reminder_Stage__c, Date_sent__c, Status__c, Invoice__c
                FROM Reminder_email__c
                WHERE Id = :idReminder
        ];

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email IN :toEmail OR Email IN :ccAddresses];

        if (rems.size() > 0) {

            Reminder_email__c emailRem = rems.get(0);
            List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Invoice__c FROM Invoice__c WHERE Id = :emailRem.Invoice__c];
            List<Settings_Reminder_email__c> settings = [SELECT Stage_1__c, Stage_2__c, Stage_3__c FROM Settings_Reminder_email__c WHERE Id = :emailRem.Settings_Reminder_email__c];
            EmailTemplate et;

            if (settings.size() > 0 && emailRem.Reminder_Stage__c != 'Overdue - reminder required') {

                if (emailRem.Reminder_Stage__c == 'Stage 1') {
                    et = [SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_1__c];
                } else if (emailRem.Reminder_Stage__c == 'Stage 2') {
                    et = [SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_2__c];
                } else {
                    et = [SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_3__c];
                }

                // First, reserve email capacity for the current Apex transaction to ensure
                // that we won't exceed our daily email limits when sending email after
                // the current transaction is committed.
                Messaging.reserveSingleEmailCapacity(countEmails);

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                if (emails.size() > 0) {
//                    message.;
//                    //message.setReplyTo(emails.get(0).Id);
//                }
                message.setSaveAsActivity(true);
                message.toAddresses = toEmail;
                message.setCcAddresses(ccAddresses);

                if (owea.size() > 0) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                Contact con;
                if (contacts.size() > 0) {
                    con = contacts.get(0);
                } else {
                    con = [SELECT Id FROM Contact LIMIT 1];
                }

                message.setTemplateId(et.Id);
                message.setWhatId(emailRem.Id);
                message.setTargetObjectId(con.Id);
                message.setSubject(Subject);
                message.setHtmlBody(Body);

                List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE Id = :attachmentIds];

                for (ContentDocumentLink CDLink : [
                        SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :emailRem.Id
                ]) {
                    ContentDocumentIds.add(CDLink.ContentDocumentId);
                }

                for (ContentVersion cversion : [
                        SELECT title, ContentDocumentId,
                                PathOnClient, FileType,
                                VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId IN :ContentDocumentIds
                ]) {
                    blob WOCFbody = cversion.VersionData;

                    Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();

                    if (cversion.FileType == 'EXCEL_X' || cversion.FileType == 'ZIP' || Test.isRunningTest()) {

                        attachFile.setContentType(cversion.FileType == 'EXCEL_X' ? 'application/vnd.ms-excel' : 'application/zip');
                        attachFile.setFileName(cversion.FileType == 'EXCEL_X' ? cversion.title + '.xls' : cversion.title + '.zip');
                        attachFile.setInline(false);
                        attachFile.Body = WOCFbody;
                        attachments.add(attachFile);

                    } else if (cversion.FileType == 'PDF') {

                        attachFile.setContentType('application/pdf');
                        attachFile.setFileName(cversion.title + '.pdf');
                        attachFile.setInline(false);
                        attachFile.Body = WOCFbody;
                        attachments.add(attachFile);
                    }
                }

                if (attachmentList.size() > 0) {
                    for (Attachment att : attachmentList) {

                        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
                        attachFile.setContentType('application/pdf');
                        attachFile.setFileName(att.Name);
                        attachFile.setInline(false);
                        attachFile.Body = att.Body;
                        attachments.add(attachFile);
                    }
                }

                message.setFileAttachments(attachments);

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                        message
                };
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                    result = 'Success';
                    emailRem.Date_sent__c = Datetime.now();
                    emailRem.Status__c = 'Sent';
                    emailRem.Picture_Status__c = emailRem.Reminder_Stage__c == 'Stage 1' ? 'Sent (Overdue)' :
                            (emailRem.Reminder_Stage__c == 'Stage 2' ? 'Sent (Stage 2)' : 'Sent (Stage 3)');

                    update emailRem;

                    if (invoices.size() > 0) {
                        deleteInvoicePDF(invoices.get(0).Id);
                    }
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                    Email_log__c log = new Email_log__c();
                    log.Description__c += String.valueOf(results[0].getErrors());
                    insert log;
                }
                sendEmails.add(message);
            }
        }

        return result;
    }

    @AuraEnabled
    public static String cancelEmail(String idReminder, String status) {

        String result = 'Success';
        List<Reminder_email__c> rems = [
                SELECT Id, Reminder_Stage__c, isCancel__c, Invoice__c
                FROM Reminder_email__c
                WHERE Id = :idReminder
        ];

        if (rems.size() > 0) {
            rems.get(0).Reminder_Stage__c = status;
            rems.get(0).isCancel__c = true;
            update rems;
        } else {
            result = 'Error';
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, String> createPDF(String idReminder) {
        return createPDF_FromBexio(idReminder);
    }

    private static Map<String, String> createPDF_FromBexio(String idReminder) {

        List<AttachmentFile> attachments = new List<AttachmentFile>();
        Map<String, String> returnMap = new Map<String, String>();
        returnMap.put('Status', 'Error');

        List<Reminder_email__c> rems = [
                SELECT Id, Reminder_Stage__c, isCancel__c, Invoice__c
                FROM Reminder_email__c
                WHERE Id = :idReminder
        ];

        if (rems.size() > 0) {

            List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Invoice__c FROM Invoice__c WHERE Id = :rems.get(0).Invoice__c];

            if (invoices.size() > 0) {

                List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoices.get(0).Id];
                Attachment attach = PDFClass.createPDFCallout(invoices.get(0).Bexio_Id__c, attachmentList, invoices);

                if (attach != null) {
                    returnMap.putAll(getEmail(idReminder));
                    AttachmentFile att = new AttachmentFile();
                    att.urlFile = '/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1';
                    att.nameFile = attach.Name;
                    att.Id = attach.Id;
                    att.file = 'Attachments';
                    attachments.add(att);
                    returnMap.put('Attachments', JSON.serialize(attachments));
                    returnMap.put('Status', 'Success');
                    return returnMap;
                } else {
                    returnMap.put('Status', 'Error');
                    return returnMap;
                }
            } else {
                return returnMap;
            }
        } else {
            return returnMap;
        }
    }

    @Future
    private static void deleteInvoicePDF(String idInvoice) {
        List<Invoice__c> invoices = [SELECT Id, Invoice__c FROM Invoice__c WHERE Id = :idInvoice];
        if (invoices.size() > 0) {
            delete [SELECT Id FROM Attachment WHERE Name = :invoices.get(0).Invoice__c + '.pdf'];
        }
    }

    @AuraEnabled
    public static Map<String, String> getEmail(String idReminder) {

        Map<String, String> returnMap = new Map<String, String>();
        List<Reminder_email__c> rems = [
                SELECT Id, AccountCompanyName__c, Settings_Reminder_email__c, Reminder_Stage__c, Account__c, Invoice__c
                FROM Reminder_email__c
                WHERE Id = :idReminder
        ];

        if (rems.size() > 0) {
            returnMap.put('Status', 'Success');
            Reminder_email__c remEmail = rems.get(0);
            returnMap.put('Name', remEmail.AccountCompanyName__c);
            returnMap.putAll(createEmail(remEmail));
            returnMap.putAll(getContact(idReminder));
        } else {
            returnMap.put('Status', 'Error');
        }
        return returnMap;
    }

    private static Map<String, String> createEmail(Reminder_email__c remEmail) {

        Map<String, String> returnMap = new Map<String, String>();
        List<Settings_Reminder_email__c> settings = [SELECT Stage_1__c, Stage_2__c, Stage_3__c FROM Settings_Reminder_email__c WHERE Id = :remEmail.Settings_Reminder_email__c];

        if (settings.size() > 0) {
            returnMap.put('Status', 'Success');
            if (remEmail.Reminder_Stage__c == 'Stage 1') {
                returnMap.putAll(createTemplate([SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_1__c], remEmail));
            } else if (remEmail.Reminder_Stage__c == 'Stage 2') {
                returnMap.putAll(createTemplate([SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_2__c], remEmail));
            } else {
                returnMap.putAll(createTemplate([SELECT Id FROM EmailTemplate WHERE Name = :settings.get(0).Stage_3__c], remEmail));
            }
        } else {
            returnMap.put('Status', 'Error');
        }
        return returnMap;
    }

    private static Map<String, String> createTemplate(List<EmailTemplate> listTemplates, Reminder_email__c remEmail) {
        Map<String, String> returnMap = new Map<String, String>();
        List <Invoice__c> invoices = [SELECT Account__c, Bexio_Id__c, Invoice__c FROM Invoice__c WHERE Id = :remEmail.Invoice__c];
        if (listTemplates.size() > 0 && invoices.size() > 0) {
            returnMap.put('TemplateEmailStatus', 'Success');
            EmailTemplate et = listTemplates.get(0);
            Messaging.SingleEmailMessage bodyTEmailMessage = createSingleEmailMessage(et, invoices.get(0));
            returnMap.put('Subject', bodyTEmailMessage.Subject.removeStart(' '));
            returnMap.put('Body', bodyTEmailMessage.htmlBody.removeStart(' ').replaceAll('\\n', ''));
            returnMap.putAll(createAttachment(remEmail, invoices.get(0)));

        } else {
            returnMap.put('TemplateEmailStatus', 'Error. EmailTemplate does not exist.');
            returnMap.put('Subject', '');
            returnMap.put('Body', '');
            returnMap.put('Attachment', '');
        }
        return returnMap;
    }

//    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailTemplate et, Reminder_email__c remEmail) {
//
//        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :remEmail.Account__c];
//        Contact con;
//        if (contacts.size() > 0) {
//            con = contacts.get(0);
//        } else {
//            con = [SELECT Id FROM Contact LIMIT 1];
//        }
//        return Messaging.renderStoredEmailTemplate(et.Id, con.Id, remEmail.Id);
//    }

    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailTemplate et, Invoice__c invoice) {

        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :invoice.Account__c];
        Contact con;
        if (contacts.size() > 0) {
            con = contacts.get(0);
        } else {
            con = [SELECT Id FROM Contact LIMIT 1];
        }
        return Messaging.renderStoredEmailTemplate(et.Id, con.Id, invoice.Id);
    }

    private static Map<String, String> createAttachment(Reminder_email__c remEmail, Invoice__c invoice) {

        Set<Id> ContentDocumentIds = new Set<Id>();
        List<AttachmentFile> attachments = new List<AttachmentFile>();
        List<String> nameAttachmentDocuments = new List<String>();
        Map<String, String> returnMap = new Map<String, String>();

            for (ContentDocumentLink CDLink : [
                    SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :remEmail.id
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

                AttachmentFile att = new AttachmentFile();
                if (String.valueOf(cversion.title).indexOfAnyBut('.' + cversion.FileType.toLowerCase()) != -1) {
                    att.nameFile = String.valueOf(cversion.title) + '.' + cversion.FileType.toLowerCase();
                } else {
                    nameAttachmentDocuments.add(String.valueOf(cversion.title));
                    att.nameFile = String.valueOf(cversion.title);
                }
                att.urlFile = '/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view';
                att.file = 'ContentVersion';
                att.Id = cversion.Id;
                attachments.add(att);
            }

            for (Attachment attach : [
                    SELECT Id, Name, Body
                    FROM Attachment
                    WHERE (ParentId = :invoice.Id AND Name != :invoice.Invoice__c + '.pdf') OR (ParentId = :remEmail.Id)
            ]) {
                AttachmentFile att = new AttachmentFile();
                att.urlFile = '/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1';
                att.nameFile = attach.Name;
                att.Id = attach.Id;
                att.file = 'Attachments';

                attachments.add(att);
            }


        returnMap.put('Attachments', JSON.serialize(attachments));

        return returnMap;
    }

    private static Map<String, String> getContact(Id emailId) {
        Map<String, String> returnMap = new Map<String, String>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
        String to = '';
        String cc = '';
        for (Contacts_for_Billing__c con : [SELECT Id, Emails_CC__c, Emails_TO__c FROM Contacts_for_Billing__c WHERE Reminder_email__c = :emailId]) {
            to += con.Emails_TO__c != null ? con.Emails_TO__c.removeStart('{').removeEnd('}') + ', ' : '';
            cc += con.Emails_CC__c != null ? con.Emails_CC__c.removeStart('{').removeEnd('}') + ', ': '';
        }
        returnMap.put('TO', to.removeEnd(', '));
        returnMap.put('CC', cc.removeEnd(', '));
        if (owea.size() > 0) {
            returnMap.put('FROM', owea.get(0).Address);
        } else {
            returnMap.put('FROM', '');
        }

        return returnMap;
    }

    public class AttachmentFile {
        public String nameFile {
            get;
            set;
        }
        public String urlFile {
            get;
            set;
        }
        public String file {
            get;
            set;
        }
        public String Id {
            get;
            set;
        }
    }
}