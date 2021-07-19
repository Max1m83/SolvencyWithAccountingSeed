/**
 * Created by max1m on 01.10.20.
 */

public with sharing class SendEmailController {

//    @AuraEnabled
//    public static Map<String, String> GetEmail(String billIds) {
//
//        List<EmailTemplate> listTemplates = new List<EmailTemplate>();
//        Map<String, String> getMap = new Map<String, String>();
//        Set<Id> conEntityIds = new Set<Id>();
//        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
//
//        Opportunity opp;
//        EmailTemplate et;
//
//        List<AcctSeed__Billing__c> bills = [SELECT Id, Billing_Number_cal__c, AcctSeed__Opportunity__c FROM AcctSeed__Billing__c WHERE Id = :billIds];
//
//        if (bills.size() > 0) {
//            AcctSeed__Billing__c bill = bills.get(0);
//            opp = [SELECT Id, Email_Template_Name__c FROM Opportunity WHERE Id = :bill.AcctSeed__Opportunity__c];
//
//            if (opp.Email_Template_Name__c != null) {
//
//                listTemplates = [
//                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
//                        FROM EmailTemplate
//                        WHERE Name = :opp.Email_Template_Name__c
//                ];
//
//                if (listTemplates.size() == 0) {
//
//                    getMap.put('Template', 'Not');
//                    getMap.put('Subject', '');
//                    getMap.put('Body', '');
//                } else if (listTemplates.size() > 1) {
//
//                    getMap.put('Template', 'More');
//                    getMap.put('Subject', '');
//                    getMap.put('Body', '');
//                } else {
//
//                    et = listTemplates.get(0);
//                    Messaging.SingleEmailMessage bodyTEmailMessage = createSingleEmailMessage(et, Id.valueOf(billIds));
//                    getMap.put('Subject', bodyTEmailMessage.Subject);
//                    getMap.put('Body', bodyTEmailMessage.htmlBody);
//
//                    List<AttachmentFile> returnList = new List<AttachmentFile>();
//
//                    Map<String, String> attachmentMap = getAttachmentDocs(bill);
//
//                    for (String urlFile : attachmentMap.keySet()) {
//                        AttachmentFile att = new AttachmentFile();
//                        att.urlFile = urlFile;
//                        att.nameFile = attachmentMap.get(urlFile);
//
//                        returnList.add(att);
//                    }
//
//                    if (returnList.size() > 0) {
//                        getMap.put('Attachments', JSON.serialize(returnList));
//                    }
//                }
//
//            } else {
//                getMap.put('Template', 'Not');
//                getMap.put('Subject', '');
//                getMap.put('Body', '');
//            }
//        } else {
//            getMap.put('Template', 'Not');
//            getMap.put('Subject', '');
//            getMap.put('Body', '');
//        }
//
//        if (owea.size() > 0) {
//            getMap.put('FROM', owea.get(0).Address);
//        } else {
//            getMap.put('FROM', '');
//        }
//
//        for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billIds]) {
//
//            conEntityIds.add(conBill.Contact_group__c);
//        }
//
//        String toEmails = '';
//
//        Set<String> emailsTOExist = new Set<String>();
//        Set<String> emailsCCExist = new Set<String>();
//
//        for (Contact_group__c groupCont : [
//                SELECT Id, Name, (SELECT Id, Emails__c, Recipient__c, Contact__c FROM Contact_entities__r)
//                FROM Contact_group__c
//                WHERE Id IN :conEntityIds
//        ]) {
//
//            for (Contact_entity__c conEnt : groupCont.Contact_entities__r) {
//
//                if (conEnt.Recipient__c == 'TO') {
//                    emailsTOExist.add(conEnt.Emails__c);
//                } else if (conEnt.Recipient__c == 'CC') {
//                    emailsCCExist.add(conEnt.Emails__c);
//                }
//            }
//
//            toEmails += groupCont.Name + '; ';
//        }
//
//        getMap.put('TO', emailsTOExist.toString());
//        getMap.put('CC', emailsCCExist.toString());
//
//        return getMap;
//    }

//    //Map<Id, Name>
//    private static Map<String, String> getAttachmentDocs(AcctSeed__Billing__c bill) {
//
//        List<Id> ContentDocumentIds = new List<Id>();
//        Map<String, String> returnMap = new Map<String, String>();
//        Boolean isPDF = true;
//
//        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :bill.Id];
//
//        System.debug(attachmentList);
//
//        for (ContentDocumentLink CDLink : [
//                SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
//                FROM ContentDocumentLink
//                WHERE LinkedEntityId = :bill.Id
//        ]) {
//            ContentDocumentIds.add(CDLink.ContentDocumentId);
//        }
//
//        for (ContentVersion cversion : [
//                SELECT title, ContentDocumentId,
//                        PathOnClient, FileType,
//                        VersionData
//                FROM ContentVersion
//                WHERE ContentDocumentId IN :ContentDocumentIds
//        ]) {
//            blob WOCFbody = cversion.VersionData;
//
//            if (cversion.FileType == 'EXCEL_X') {
//
//                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
//                attachFile.setContentType('application/vnd.ms-excel');
//                attachFile.setFileName(cversion.title + '.xls');
//                attachFile.setInline(false);
//                attachFile.Body = WOCFbody;
//                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.xls');
//
//            } else if (cversion.FileType == 'ZIP') {
//
//                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
//                attachFile.setContentType('application/zip');
//                attachFile.setFileName(cversion.title + '.zip');
//                attachFile.setInline(false);
//                attachFile.Body = WOCFbody;
//                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.zip');
//            } else if (cversion.FileType == 'PDF') {
//                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
//                attachFile.setContentType('application/pdf');
//                attachFile.setFileName(cversion.title + '.pdf');
//                attachFile.setInline(false);
//                attachFile.Body = WOCFbody;
//                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.pdf');
//            } else {
//                System.debug(cversion.FileType);
//            }
//        }
//
//        if (attachmentList.size() > 0) {
//
//            for (Attachment att : attachmentList) {
//                if (att.Name == bill.Billing_Number_cal__c + '.pdf') {
//                    isPDF = false;
//                }
//                returnMap.put('/servlet/servlet.FileDownload?file=' + att.Id + '&operationContext=S1', att.Name);
//            }
//        }
//
//        if (isPDF) {
//            returnMap.putAll(createPDF_Billing(bill));
//        }
//
//        return returnMap;
//    }
//
//    private static Map<String, String> createPDF_Billing(AcctSeed__Billing__c bill) {
//
//        Map<String, String> returnMap = new Map<String, String>();
//
//        Attachment attach = new Attachment();
//
//        PageReference pdf = Page.InvoiceSolvencyWithQuantity;
//        pdf.getParameters().put('id', bill.Id);
//        Blob bodyAttach;
//
//        try {
//
//            // returns the output of the page as a PDF
//            bodyAttach = pdf.getContent();
//
//            // need to pass unit test -- current bug
//        } catch (VisualforceException e) {
//            bodyAttach = Blob.valueOf('Some Text');
//        }
//
//        String nameInvoice = bill.Billing_Number_cal__c + '.pdf';
//
//        attach.Name = nameInvoice;
//        attach.IsPrivate = false;
//        attach.ParentId = bill.Id;
//        attach.Body = bodyAttach;
//
//        insert attach;
//
//        returnMap.put('/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1', attach.Name);
//
//        return returnMap;
//    }
//
//    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailTemplate et, Id billId) {
//
//        Contact con = [SELECT Id FROM Contact LIMIT 1];
//
//        return Messaging.renderStoredEmailTemplate(et.Id, con.Id, billId);
//    }

//    @AuraEnabled
//    public static String SendEmail(String billIds, String Body, String Subject) {
//
//        Set<Id> conIds = new Set<Id>();
//        Contact setTargetContact = new Contact();
//        List<String> toEmail = new List<String>();
//        Set<Id> conEntityIds = new Set<Id>();
//        List<Id> ContentDocumentIds = new List<Id>();
//        List<String> ccAdresses = new List<String>();
//        List<Messaging.SingleEmailMessage> sendEmails = new List<Messaging.SingleEmailMessage>();
//        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
//        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
//
//        AcctSeed__Billing__c bill = [SELECT Id, AcctSeed__Received_Amount__c, CurrencyIsoCode, AcctSeed__Accounting_Period__c, AcctSeed__Ledger__c, AcctSeed__Customer__c, AcctSeed__Opportunity__c, Billing_Number_cal__c, AcctSeed__Status__c, AcctSeed__PDF_Email_Status__c FROM AcctSeed__Billing__c WHERE Id = :billIds];
//
//        if (bill.AcctSeed__Status__c == 'Approved') {
//
//            Opportunity opp = [SELECT Id, Email_Template_Name__c FROM Opportunity WHERE Id = :bill.AcctSeed__Opportunity__c];
//
//            for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billIds]) {
//                conEntityIds.add(conBill.Contact_group__c);
//            }
//
//            for (Contact_group__c groupCont : [
//                    SELECT Id, (SELECT Id, Contact__c, Recipient__c FROM Contact_entities__r)
//                    FROM Contact_group__c
//                    WHERE Id IN :conEntityIds
//            ]) {
//                for (Contact_entity__c contact : groupCont.Contact_entities__r) {
//
//                    if (contact.Recipient__c == 'TO') {
//                        conIds.add(contact.Contact__c);
//                    } else if (contact.Recipient__c == 'CC') {
//                        ccAdresses.add(contact.Contact__c);
//                    }
//                }
//            }
//
//            List<EmailTemplate> etList = [
//                    SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
//                    FROM EmailTemplate
//                    WHERE Name = :opp.Email_Template_Name__c
//                    LIMIT 1
//            ];
//
//            if (etList.size() > 0) {
//
//                EmailTemplate et = etList.get(0);
//                et.Subject = Subject;
//                et.HtmlValue = Body;
//
//                Boolean isFirst = true;
//
//                for (Contact con : [SELECT Id, Email, Name FROM Contact WHERE Id IN :conIds]) {
//                    toEmail.add(con.Email);
//                    if (isFirst) {
//                        setTargetContact = con;
//                        isFirst = false;
//                    }
//                }
//
//                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                message.toAddresses = toEmail;
//                message.setCcAddresses(ccAdresses);
//
//                if (owea.size() > 0) {
//                    message.setOrgWideEmailAddressId(owea.get(0).Id);
//                }
//
//                message.setTemplateId(et.Id);
//                message.setWhatId(billIds);
//                message.setTargetObjectId(setTargetContact.Id);
//                message.setSubject(Subject);
//                message.setHtmlBody(Body);
//
//                List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :bill.Id];
//
//                for (ContentDocumentLink CDLink : [
//                        SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
//                        FROM ContentDocumentLink
//                        WHERE LinkedEntityId = :bill.Id
//                ]) {
//                    ContentDocumentIds.add(CDLink.ContentDocumentId);
//                }
//
//                for (ContentVersion cversion : [
//                        SELECT title, ContentDocumentId,
//                                PathOnClient, FileType,
//                                VersionData
//                        FROM ContentVersion
//                        WHERE ContentDocumentId IN :ContentDocumentIds
//                ]) {
//                    blob WOCFbody = cversion.VersionData;
//
//                    Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
//
//                    if (cversion.FileType == 'EXCEL_X') {
//
//                        System.debug('jjjjjj');
//
//                        attachFile.setContentType('application/vnd.ms-excel');
//                        attachFile.setFileName(cversion.title);
//                        attachFile.setInline(false);
//                        attachFile.Body = WOCFbody;
//                        attachments.add(attachFile);
//
//                    } else if (cversion.FileType == 'ZIP') {
//
//                        attachFile.setContentType('application/zip');
//                        attachFile.setFileName(cversion.title);
//                        attachFile.setInline(false);
//                        attachFile.Body = WOCFbody;
//                        attachments.add(attachFile);
//                    }
//                }
//
//                if (attachmentList.size() > 0) {
//                    for (Attachment att : attachmentList) {
//
//                        Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
//                        attachFile.setContentType('application/pdf');
//                        attachFile.setFileName(att.Name);
//                        attachFile.setInline(false);
//                        attachFile.Body = att.Body;
//                        attachments.add(attachFile);
//                    }
//                }
//                message.setFileAttachments(attachments);
//
//                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
//                        message
//                };
//                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
//                if (results[0].success) {
//                    System.debug('The email was sent successfully.');
//                    bill.AcctSeed__PDF_Email_Status__c = 'Sent';
//                    update bill;
//                } else {
//                    System.debug('The email failed to send: ' + results[0].errors[0].message);
//                }
//                sendEmails.add(message);
//            }
//
//            return billIds;
//
//        } else {
//            return 'Not Approved';
//        }
//    }

 /*   @AuraEnabled
    public static Map<String, String> GetEmailMultipleBilling(String groupIds) {

        List<EmailTemplate> listTemplates = new List<EmailTemplate>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> billIds = new Set<Id>();
        Set<String> emailsTOExist = new Set<String>();
        Set<String> emailsCCExist = new Set<String>();
        Map<String, String> getMap = new Map<String, String>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];

        Map<String, String> attachmentMap = new Map<String, String>();

        for (Contact_entity__c groups : [SELECT Id, Contact__c, Emails__c, Recipient__c FROM Contact_entity__c WHERE Contact_group__c = :groupIds]) {

            if (groups.Recipient__c == 'TO') {
                emailsTOExist.add(groups.Emails__c);
                conIds.add(groups.Contact__c);
            } else if (groups.Recipient__c == 'CC') {
                emailsCCExist.add(groups.Emails__c);
            }
        }

        for (Billing_Sent__c bill : [
                SELECT Id, Invoice__c
                FROM Billing_Sent__c
                WHERE Contact_group__c = :groupIds
        ]) {
            billIds.add(bill.Invoice__c);
        }

        if (billIds.size() > 0) {

            for (Invoice__c invoice : [
                    SELECT Id, Account__c
                    FROM Invoice__c
                    WHERE Id IN :billIds
            ]) {
                accIds.add(invoice.Account__c);
                System.debug('!');
                attachmentMap.putAll(createPDF_Billing(invoice));

                System.debug('FF');
            }

            if (accIds.size() > 0) {

                System.debug('ggg');

                List<Contact_group__c> groups = [SELECT Id, Template_Name__c FROM Contact_group__c WHERE Id = :groupIds];
                List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id = :conIds];

                String nameTemplate = '';

                if (groups.size() > 0) {

                    getMap.put('Status', 'Success');

                    nameTemplate = groups.get(0).Template_Name__c;
                    listTemplates = [
                            SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                            FROM EmailTemplate
                            WHERE Name = :nameTemplate
                    ];

                    EmailTemplate et;
                    List<Account> acc = [SELECT Id FROM Account WHERE Id IN :accIds LIMIT 1];

                    if (listTemplates.size() == 0) {

                        getMap.put('Template', 'Not');
                        getMap.put('Subject', '');
                        getMap.put('Body', '');

                    } else if (listTemplates.size() > 1) {

                        getMap.put('Template', 'More');
                        getMap.put('Subject', '');
                        getMap.put('Body', '');

                    } else {

                        et = listTemplates.get(0);

                        if (contacts.size() > 0 && acc.size() > 0) {

                            Contact con = contacts.get(0);
                            Messaging.SingleEmailMessage bodyTEmailMessage = Messaging.renderStoredEmailTemplate(et.Id, con.Id, acc.get(0).Id);
                            getMap.put('Subject', bodyTEmailMessage.Subject);
                            getMap.put('Body', bodyTEmailMessage.htmlBody);

                            List<AttachmentFile> returnList = new List<AttachmentFile>();

                            attachmentMap.putAll(getAttachmentDocsMultiEmails(groups.get(0)));

                            for (String urlFile : attachmentMap.keySet()) {
                                AttachmentFile att = new AttachmentFile();
                                att.urlFile = urlFile;
                                att.nameFile = attachmentMap.get(urlFile);
                                returnList.add(att);
                            }

                            if (returnList.size() > 0) {
                                getMap.put('Attachments', JSON.serialize(returnList));
                            } else {
                                getMap.put('Attachments', '');
                            }
                        }
                    }
                } else {
                    getMap.put('Status', 'Error');
                }
            } else {
                getMap.put('Status', 'No Customer');
            }
        } else {
            getMap.put('Status', 'No Billing');
        }

        if (owea.size() > 0) {
            getMap.put('FROM', owea.get(0).Address);
        } else {
            getMap.put('FROM', '');
        }

        // getMap.put('TO', emails.removeEnd ('; '));
        getMap.put('TO', emailsTOExist.toString());
        getMap.put('CC', emailsCCExist.toString());

        System.debug('Return');
        System.debug(getMap);

        return getMap;
    }

    private static Map<String, String> createPDF_Billing(Invoice__c invoiceOld) {

        Map<String, String> returnMap = new Map<String, String>();

        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoiceOld.Id];
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceOld.Id];
        if (invoices.size() > 0) {
            Invoice__c invoice = invoices.get(0);
            Attachment attach = PDFClass.createPDFCallout(invoice.Bexio_Id__c, attachmentList, invoices);
            returnMap.put('/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1', attach.Name);
            System.debug(attach.Name);
        }

        return returnMap;
    }

    @AuraEnabled
    public static String SendEmailWithMultipleBilling(String groupIds, String Body, String Subject, List<String> urls) {

        Set<Id> conIds = new Set<Id>();
        Set<Id> billIds = new Set<Id>();
        List<String> emails = new List<String>();
        List<String> ccAdresses = new List<String>();
        List<Attachment> attachListDelete = new List<Attachment>();
        List<Billing_Sent__c> deleteObject = new List<Billing_Sent__c>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> attachId = new Set<Id>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
        Contact_group__c groupExist = [SELECT Id, Sending__c, Template_Name__c FROM Contact_group__c WHERE Id = :groupIds LIMIT 1];

        if (urls.size() > 0) {
            attachId = getAttachmentIds(urls);

            for (Attachment att : [SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachId]) {

                if (att.Name.endsWith('.pdf')) {
                    Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
                    attachFile.setContentType('application/pdf');
                    attachFile.setFileName(att.Name);
                    attachFile.setInline(false);
                    attachFile.Body = att.Body;
                    attachments.add(attachFile);
                    attachListDelete.add(att);
                }
            }
        }

        for (ContentVersion cversion : [SELECT Id, FileType, Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN :attachId]) {

            Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
            blob WOCFbody = cversion.VersionData;

            if (cversion.FileType == 'EXCEL_X') {

                attachFile.setContentType('application/vnd.ms-excel');
                attachFile.setFileName(cversion.title + '.xls');
                attachFile.setInline(false);
                attachFile.Body = WOCFbody;
                attachments.add(attachFile);

            } else if (cversion.FileType == 'ZIP') {

                attachFile.setContentType('application/zip');
                attachFile.setFileName(cversion.title + '.zip');
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

        for (Contact_entity__c groups : [SELECT Id, Contact__c, Recipient__c FROM Contact_entity__c WHERE Contact_group__c = :groupIds]) {

            if (groups.Recipient__c == 'TO') {
                conIds.add(groups.Contact__c);
            } else if (groups.Recipient__c == 'CC') {
                ccAdresses.add(groups.Contact__c);
            }
        }

        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id = :conIds];

        for (Contact con : contacts) {
            if (String.isNotEmpty(con.Email)) {
                emails.add(con.Email);
            }
        }

        String result;

        List<EmailTemplate> etList = [
                SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                FROM EmailTemplate
                WHERE Name = :groupExist.Template_Name__c
                LIMIT 1
        ];

        if (etList.size() > 0) {

            EmailTemplate et = etList.get(0);
            Contact con = contacts.get(0);

            for (Billing_Sent__c bill : [
                    SELECT Id, Invoice__c
                    FROM Billing_Sent__c
                    WHERE Contact_group__c = :groupIds
            ]) {
                billIds.add(bill.Invoice__c);
                deleteObject.add(bill);
            }

            for (Invoice__c invoice : [
                    SELECT Id, Account__c
                    FROM Invoice__c
                    WHERE Id IN :billIds
            ]) {
                accIds.add(invoice.Account__c);
            }

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = emails;
            if (owea.size() > 0) {
                message.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            List<Account> acc = [SELECT Id FROM Account WHERE Id IN :accIds LIMIT 1];

            if (acc.size() > 0) {
                message.setTemplateId(et.Id);
                message.setWhatId(acc.get(0).Id);
                message.setCcAddresses(ccAdresses);
                message.setTargetObjectId(con.Id);
                message.setOrgWideEmailAddressId(owea[0].Id);
                message.setFileAttachments(attachments);
                message.setSubject(Subject);
                message.setHtmlBody(Body);
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                        message
                };

                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                    result = 'Success';
                    groupExist.Sending__c = false;
                    update groupExist;
                    //update updateBill;
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                    result = 'Error';
                }

                if (deleteObject.size() > 0) {
                    delete deleteObject;
                    delete attachListDelete;
                }

                return result;
            } else {
                return 'No Account';
            }


        } else {
            return 'No Template';
        }
    }

    private static Map<String, String> getAttachmentDocsMultiEmails(Contact_group__c groups) {

        List<Id> ContentDocumentIds = new List<Id>();
        Map<String, String> returnMap = new Map<String, String>();

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :groups.Id];

        for (ContentDocumentLink CDLink : [
                SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :groups.Id
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

            if (cversion.FileType == 'EXCEL_X' || cversion.FileType == 'EXCEL') {

                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
                attachFile.setContentType('application/vnd.ms-excel');
                attachFile.setFileName(cversion.title);
                attachFile.setInline(false);
                attachFile.Body = WOCFbody;
                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.xls');
            } else if (cversion.FileType == 'ZIP') {

                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
                attachFile.setContentType('application/zip');
                attachFile.setFileName(cversion.title);
                attachFile.setInline(false);
                attachFile.Body = WOCFbody;
                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.zip');
            } else if (cversion.FileType == 'PDF') {

                System.debug('PDF');

                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
                attachFile.setContentType('application/pdf');
                attachFile.setFileName(cversion.title);
                attachFile.setInline(false);
                attachFile.Body = WOCFbody;
                returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.pdf');
            }
        }

        for (Attachment attach : [SELECT Id, Name FROM Attachment WHERE ParentId = :groups.Id]) {
            returnMap.put('/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1', attach.Name);
        }

        return returnMap;
    }

    private static Set<Id> getAttachmentIds(List<String> urls) {

        Set<Id> returnIds = new Set<Id>();
        for (String strUrl : urls) {
            if (strUrl.contains('FileDownload')) {
                returnIds.add(Id.valueOf(strUrl.substringBetween('FileDownload?file=', '&operationContext')));
            } else if (strUrl.contains('ContentDocument')) {
                returnIds.add(Id.valueOf(strUrl.substringBetween('ContentDocument/', '/view')));
            }
        }
        return returnIds;
    }

    public class AttachmentFile {
        public String nameFile { get; set; }
        public String urlFile { get; set; }
        public String typeFile { get; set; }
        public String idFile { get; set; }
    }*/
}