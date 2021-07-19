public with sharing class Int_SendEmailController {

    @AuraEnabled
    public static Map<String, String> GetEmail(String invoiceIds) {
        System.debug('invoiceIds invoiceIds');
        System.debug(invoiceIds);

        List<EmailTemplate> listTemplates = new List<EmailTemplate>();
        Map<String, String> getMap = new Map<String, String>();
        Set<Id> conEntityIds = new Set<Id>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];

        Opportunity opp;
        EmailTemplate et;

//        List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Invoice__c, Opportunity__c, Account__c FROM Invoice__c WHERE Id = :invoiceIds];
        List<Invoice__c> invoices = [
                SELECT Id, Bexio_Id__c, Invoice__c, Contact_groups__c, Opportunity__c, Account__c, Account__r.Name, Account__r.Account_Email__c, Opportunity__r.Email_Template_Name__c
                FROM Invoice__c
                WHERE Id = :invoiceIds
        ];
        //+++++++++++++++++++++
        if (invoices.size() > 0) {
            getMap.put('NameInvoice', invoices.get(0).Invoice__c);
            List<Contact_group__c> contactGroups = [SELECT Id, Emails_TO__c, Emails_CC__c, Name FROM Contact_group__c WHERE Name =:invoices.get(0).Contact_groups__c];
            if (contactGroups.size() > 0) {
                getMap.put('Emails_TO', contactGroups.get(0).Emails_TO__c);
                getMap.put('Emails_CC', contactGroups.get(0).Emails_CC__c);
            }
            //+++++++++++++++++++++
            Invoice__c invoice = invoices.get(0);
            //+++++++++++++++++++++
            getMap.put('AccountName', invoice.Account__r.Name);
            getMap.put('AccountEmail', invoice.Account__r.Account_Email__c);
            getMap.put('EmailTemplateName', invoice.Opportunity__r.Email_Template_Name__c);
            //+++++++++++++++++++++
            List<Opportunity> opps = [SELECT Id, Email_Template_Name__c FROM Opportunity WHERE Id = :invoice.Opportunity__c];

            if (opps.size() > 0) {
                opp = opps.get(0);
            }

            if (opps.size() > 0 && opp.Email_Template_Name__c != null) {

                listTemplates = [
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :opp.Email_Template_Name__c
                ];

                getMap.put('IsBexio', String.valueOf(String.isNotBlank(invoice.Bexio_Id__c)));

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
                    System.debug('EmailTemplate');
                    System.debug(et);
                    Messaging.SingleEmailMessage bodyTEmailMessage = createSingleEmailMessage(et, Id.valueOf(invoiceIds));
                    getMap.put('Subject', bodyTEmailMessage.Subject);
                    getMap.put('Body', bodyTEmailMessage.htmlBody);

                    List<AttachmentFile> returnList = new List<AttachmentFile>();

                    Map<String, String> attachmentMap = getAttachmentDocs(invoice);

                    for (String urlFile : attachmentMap.keySet()) {
                        AttachmentFile att = new AttachmentFile();
                        att.urlFile = urlFile;
                        att.nameFile = attachmentMap.get(urlFile);

                        returnList.add(att);
                    }

                    if (returnList.size() > 0) {
                        getMap.put('Attachments', JSON.serialize(returnList));
                    }
                }

            } else {
                getMap.put('Template', 'Not');
                getMap.put('Subject', '');
                getMap.put('Body', '');
            }
        } else {
            getMap.put('Template', 'Not');
            getMap.put('Subject', '');
            getMap.put('Body', '');
        }

        if (owea.size() > 0) {
            getMap.put('FROM', owea.get(0).Address);
        } else {
            getMap.put('FROM', '');
        }

        Map<String, String> emails = getAddress(invoiceIds);
        getMap.put('TO', emails.get('TO'));
        getMap.put('CC', emails.get('CC'));

        return getMap;
    }

    private static Map<String, String> getAddress(Id invoiceIds) {

        Map<String, String> returnMap = new Map<String, String>();
        Set<Id> conEntityIds = new Set<Id>();

        for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Invoice__c = :invoiceIds]) {

            conEntityIds.add(conBill.Contact_group__c);
        }

//        Set<String> emailsTOExist = new Set<String>();
//        Set<String> emailsCCExist = new Set<String>();
        Map<Integer, String> toEmails = new Map<Integer, String>();
        Map<Integer, String> ccEmails = new Map<Integer, String>();

        for (Contact_group__c groupCont : [
                SELECT Id, Name, (SELECT Id, Emails__c, Recipient__c, Contact__c, Position__c FROM Contact_entities__r ORDER BY Position__c ASC)
                FROM Contact_group__c
                WHERE Id IN :conEntityIds
        ]) {

            for (Contact_entity__c conEnt : groupCont.Contact_entities__r) {

                if (conEnt.Position__c == null) {
                    continue;
                }

                if (conEnt.Recipient__c == 'TO') {
                    if (toEmails.containsKey(Integer.valueOf(conEnt.Position__c))) {
                        toEmails.put(Integer.valueOf(conEnt.Position__c), toEmails.get(Integer.valueOf(conEnt.Position__c)) + conEnt.Emails__c + '; ');
                    } else {
                        toEmails.put(Integer.valueOf(conEnt.Position__c), conEnt.Emails__c + '; ');
                    }
                    // emailsTOExist.add(conEnt.Emails__c);
                } else if (conEnt.Recipient__c == 'CC') {
                    if (ccEmails.containsKey(Integer.valueOf(conEnt.Position__c))) {
                        ccEmails.put(Integer.valueOf(conEnt.Position__c), toEmails.get(Integer.valueOf(conEnt.Position__c)) + conEnt.Emails__c + '; ');
                    } else {
                        ccEmails.put(Integer.valueOf(conEnt.Position__c), conEnt.Emails__c + '; ');
                    }
                    //  emailsCCExist.add(conEnt.Emails__c);
                }
            }
            //toEmails += groupCont.Name + '; ';
        }

        String emails = '';

        for (Integer i = 0; i < toEmails.size(); i++) {
            emails += toEmails.get(i) + '; ';
        }
        returnMap.put('TO', emails.removeEnd('; '));
        emails = '';

        for (Integer i = 0; i < ccEmails.size(); i++) {
            emails += ccEmails.get(i) + '; ';
        }
        returnMap.put('CC', emails.removeEnd('; '));

        return returnMap;
    }

    @AuraEnabled
    public static Map<String, String> previewInvoiceBexio(String invoiceIds) {

        Map<String, String> returnMaps = new Map<String, String>();
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceIds];

        if (invoices.size() > 0) {
            returnMaps.put('Status', 'Success');

            if (String.isBlank(invoices.get(0).Bexio_Id__c)) {
                returnMaps.put('Status', 'Success');
                returnMaps.put('BexioId', createInvoiceOnBexioSide(invoiceIds).Bexio_Id__c);
            } else {
                returnMaps.put('Status', 'Success');
                returnMaps.put('BexioId', invoices.get(0).Bexio_Id__c);
            }

        } else {
            returnMaps.put('Status', 'Not Invoices');
        }

        return returnMaps;
    }

    @AuraEnabled
    public static String createPDF(String invoiceIds) {
        return createInvoiceOnBexioSide(invoiceIds).Invoice__c;
    }

    @AuraEnabled
    public static String SendEmail(String invoiceIds, String Body, String Subject) {

        Set<Id> conIds = new Set<Id>();
        Contact setTargetContact = new Contact();
        List<String> toEmail = new List<String>();
        Set<Id> conEntityIds = new Set<Id>();
        List<Id> ContentDocumentIds = new List<Id>();
        List<String> ccAdresses = new List<String>();
        List<Messaging.SingleEmailMessage> sendEmails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SolvencyAnalytics AG'];
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Opportunity__c, CurrencyIsoCode, PDF_Email_Status__c, Posting_Status__c FROM Invoice__c WHERE Id = :invoiceIds];

        if (invoices.size() > 0) {
            Invoice__c invoice = invoices.get(0);

            if (invoice.Posting_Status__c == 'Approved') {

                Opportunity opp = [SELECT Id, Email_Template_Name__c FROM Opportunity WHERE Id = :invoice.Opportunity__c];

                for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Invoice__c = :invoiceIds]) {
                    conEntityIds.add(conBill.Contact_group__c);
                }

                for (Contact_group__c groupCont : [
                        SELECT Id, (SELECT Id, Contact__c, Recipient__c FROM Contact_entities__r)
                        FROM Contact_group__c
                        WHERE Id IN :conEntityIds
                ]) {
                    for (Contact_entity__c contact : groupCont.Contact_entities__r) {

                        if (contact.Recipient__c == 'TO') {
                            conIds.add(contact.Contact__c);
                        } else if (contact.Recipient__c == 'CC') {
                            ccAdresses.add(contact.Contact__c);
                        }
                    }
                }

                List<EmailTemplate> etList = [
                        SELECT Id, Body, Markup, Subject, Name, HtmlValue, Description, DeveloperName
                        FROM EmailTemplate
                        WHERE Name = :opp.Email_Template_Name__c
                        LIMIT 1
                ];

                if (etList.size() > 0) {

                    EmailTemplate et = etList.get(0);
                    et.Subject = Subject;
                    et.HtmlValue = Body;

                    Boolean isFirst = true;

                    for (Contact con : [SELECT Id, Email, Name FROM Contact WHERE Id IN :conIds]) {
                        toEmail.add(con.Email);
                        if (isFirst) {
                            setTargetContact = con;
                            isFirst = false;
                        }
                    }

                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = toEmail;
                    message.setCcAddresses(ccAdresses);

                    if (owea.size() > 0) {
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                    }

                    message.setTemplateId(et.Id);
                    message.setWhatId(invoiceIds);
                    message.setTargetObjectId(setTargetContact.Id);
                    message.setSubject(Subject);
                    message.setHtmlBody(Body);

                    List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :invoice.Id];

                    for (ContentDocumentLink CDLink : [
                            SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId = :invoice.Id
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
                        invoice.PDF_Email_Status__c = 'Sent';
                        update invoice;
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }
                    sendEmails.add(message);
                }

                return invoice.Id;
            } else {
                return 'Not Approved';
            }
        } else {
            return 'Not Invoice';
        }
    }

    @AuraEnabled
    public static Map<String, String> cancelSendEmail(String invoiceIds) {

        Map<String, String> returnMap = new Map<String, String>();
        List<Invoice__c> invoices = [SELECT Id, Invoice__c FROM Invoice__c WHERE Id = :invoiceIds];

        if (invoices.size() > 0) {
            Invoice__c invoice = invoices.get(0);
            List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoice.Id AND Name = :invoice.Invoice__c + '.pdf'];
            delete attachmentList;
        }

        returnMap.put('Status', 'Success');

        return returnMap;
    }

    @AuraEnabled
    public static Map<String, List<String>> getEmailsGroup(String invoiceIds) {

        List<String> existEmailGroup = new List<String>();
        Map<String, List<String>> emailsGroup = new Map<String, List<String>>();

        Set<Id> existIds = new Set<Id>();

        for (Contacts_for_Billing__c conBill : [
                SELECT Id, Contact_group__c
                FROM Contacts_for_Billing__c
                WHERE Invoice__c = :invoiceIds
        ]) {

            existIds.add(conBill.Contact_group__c);
        }

        for (Contact_group__c con : [
                SELECT Id, Name
                FROM Contact_group__c
                WHERE Id IN :existIds
        ]) {

            existEmailGroup.add(con.Name);
        }

        emailsGroup.put('Group', existEmailGroup);

        return emailsGroup;
    }

    @AuraEnabled
    public static String updateBilling(String invoiceIds, List<String> namesGroup) {

        List<Billing_Sent__c> insertObject = new List<Billing_Sent__c>();
        List<Contact_group__c> updateSents = new List<Contact_group__c>();
        Set<Id> existIds = new Set<Id>();
        Set<Id> existGroupIds = new Set<Id>();
        Set<Id> reqGroupIds = new Set<Id>();
        List<Attachment> attachments = new List<Attachment>();

        List<Invoice__c> invoices = [
                SELECT Id, Account__c, Multiple_Invoice__c, Posting_Status__c, Invoice__c, (SELECT Id, Contact_group__c FROM Invoice_Contact_Groups_Billing__r)
                FROM Invoice__c
                WHERE Id = :invoiceIds
        ];

        if (invoices.size() > 0 && invoices.get(0).Posting_Status__c == 'Approved') {

            for (Contacts_for_Billing__c conBill : [
                    SELECT Id, Contact_group__c
                    FROM Contacts_for_Billing__c
                    WHERE Invoice__c = :invoiceIds
            ]) {

                existGroupIds.add(conBill.Contact_group__c);
            }

            for (Contact_group__c con : [
                    SELECT Id, Name, Sending__c
                    FROM Contact_group__c
                    WHERE Id IN :existGroupIds
            ]) {
                for (String nameGroup : namesGroup) {
                    if (con.Name == nameGroup) {
                        reqGroupIds.add(con.Id);
                        con.Sending__c = true;
                        updateSents.add(con);
                    }
                }
            }

            for (Billing_Sent__c billSent : [
                    SELECT Id, Contact_group__c
                    FROM Billing_Sent__c
                    WHERE Invoice__c = :invoiceIds
            ]) {
                existIds.add(billSent.Contact_group__c);
            }

            if (invoices.size() == 1) {
                Invoice__c invoice = invoices.get(0);

                for (Contacts_for_Billing__c contBill : invoice.Invoice_Contact_Groups_Billing__r) {

                    if (!existIds.contains(contBill.Contact_group__c)) {
                        if (reqGroupIds.contains(contBill.Contact_group__c)) {
                            Billing_Sent__c sentBill = new Billing_Sent__c();
                            sentBill.Invoice__c = invoice.Id;
                            sentBill.Contact_group__c = contBill.Contact_group__c;
                            insertObject.add(sentBill);
                            String invoiceNumber = invoice.Invoice__c;
                            attachments.add(createPDFAttachment(invoice, contBill.Contact_group__c));
                        }
                    }
                }
                insert insertObject;
                update updateSents;
                if (!Test.isRunningTest()) {
                    insert attachments;
                }
                return 'Success';
            } else {
                return 'ERROR';
            }
        } else {
            return 'Not Approved';
        }
    }

    private static Attachment createPDFAttachment(Invoice__c invoiceNew, Id conId) {

        Attachment attach = new Attachment();
        Attachment attachNew = new Attachment();

        Boolean isPDF = true;

        List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :invoiceNew.Id];
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceNew.Id];

        for (Attachment att : attachmentList) {
            if (att.Name == invoiceNew.Invoice__c + '.pdf') {
                isPDF = false;
                attach = att;
            }
        }

        if (isPDF && invoices.size() > 0) {

            Invoice__c invoice = invoices.get(0);
            attach = PDFClass.createPDFCallout(invoice.Bexio_Id__c, attachmentList, invoices);
        }

        if (attach != null) {
            attachNew.Name = attach.Name;
            attachNew.IsPrivate = false;
            attachNew.ParentId = conId;
            attachNew.Body = attach.Body;

        }

//        Attachment attach = new Attachment();
//
//        PageReference pdf = Page.Invoice_pdf;
//        pdf.getParameters().put('id', invoice.Id);
//        Blob bodyAttach;
//
//        try {
//            // returns the output of the page as a PDF
//            bodyAttach = pdf.getContent();
//
//            // need to pass unit test -- current bug
//        } catch (VisualforceException e) {
//            bodyAttach = Blob.valueOf('Some Text');
//        }
//
//        String nameInvoice = invoiceNumber + '.pdf';
//        attach.Name = nameInvoice;
//        attach.IsPrivate = false;
//        attach.ParentId = conId;
//        attach.Body = bodyAttach;

        return attachNew;
    }


    public static Map<String, String> getAttachmentDocs(Invoice__c invoice) {

        List<Id> ContentDocumentIds = new List<Id>();
        List<Attachment> deleteAttachments = new List<Attachment>();
        Map<String, String> returnMap = new Map<String, String>();
        Boolean isPDF = true;

        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoice.Id];

        System.debug(attachmentList);

        for (ContentDocumentLink CDLink : [
                SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :invoice.Id
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

            if (cversion.FileType == 'EXCEL_X' || cversion.FileType == 'ZIP' || cversion.FileType == 'PDF' || Test.isRunningTest()) {

                Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();

                if (cversion.FileType == 'PDF') {
                    attachFile.setContentType('application/pdf');
                    attachFile.setFileName('.pdf');
                } else {
                    attachFile.setContentType(cversion.FileType == 'EXCEL_X' ? 'application/vnd.ms-excel' : 'application/zip');
                    attachFile.setFileName(cversion.FileType == 'EXCEL_X' ? cversion.title + '.xls' : cversion.title + '.zip');
                }
                attachFile.setInline(true);
                attachFile.Body = WOCFbody;

                if (cversion.FileType == 'PDF') {
                    returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + '.pdf');
                } else {
                    returnMap.put('/lightning/r/ContentDocument/' + cversion.ContentDocumentId + '/view', cversion.title + (cversion.FileType == 'EXCEL_X' ? '.xls' : '.zip'));
                }
            }
        }

        if (attachmentList.size() > 0) {

            for (Attachment att : attachmentList) {

                if (att.Name == invoice.Invoice__c + '.pdf') {

                    deleteAttachments.add(att);
                } else {
                    returnMap.put('/servlet/servlet.FileDownload?file=' + att.Id + '&operationContext=S1', att.Name);
                }
//                returnMap.put('/servlet/servlet.FileDownload?file=' + att.Id + '&operationContext=S1', att.Name);
            }
        }

        returnMap.putAll(createPDF_Billing(invoice));
        delete deleteAttachments;


//        if (isPDF) {
//            returnMap.putAll(createPDF_Billing(invoice));
//        }

        return returnMap;
    }

    public static Map<String, String> createPDF_Billing(Invoice__c invoiceOld) {

        Map<String, String> returnMap = new Map<String, String>();

        List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :invoiceOld.Id];
        List<Invoice__c> invoices = [SELECT Id, Invoice__c, Bexio_Id__c FROM Invoice__c WHERE Id = :invoiceOld.Id];
        if (invoices.size() > 0) {
            Invoice__c invoice = invoices.get(0);
            Attachment attach = PDFClass.createPDFCallout(invoice.Bexio_Id__c, attachmentList, invoices);
            returnMap.put('/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1', attach.Name);
        }
//        Invoice__c invoice = [SELECT Id, Invoice__c FROM Invoice__c WHERE Id = :invoiceOld.id];
//
//        Map<String, String> returnMap = new Map<String, String>();
//
//        Attachment attach = new Attachment();
//
//        PageReference pdf = Page.Invoice_pdf;
//        pdf.getParameters().put('id', invoice.Id);
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
//        String nameInvoice = invoice.Invoice__c + '.pdf';
//        attach.Name = nameInvoice;
//        attach.IsPrivate = false;
//        attach.ParentId = invoice.Id;
//        attach.Body = bodyAttach;
//
//        insert attach;
//
//        returnMap.put('/servlet/servlet.FileDownload?file=' + attach.Id + '&operationContext=S1', attach.Name);
        System.debug(returnMap);

        return returnMap;
    }

    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailTemplate et, Id billId) {

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        return Messaging.renderStoredEmailTemplate(et.Id, con.Id, billId);
    }

    private static Invoice__c createInvoiceOnBexioSide(String invoiceId) {

        Invoice__c invoice = new Invoice__c();

        List<Invoice__c> invoices = [SELECT Id, Bexio_Id__c, Invoice__c, Opportunity__c, CurrencyIsoCode, PDF_Email_Status__c, Posting_Status__c FROM Invoice__c WHERE Id = :invoiceId];

        if (Test.isRunningTest() || (invoices.size() > 0 && String.isBlank(invoices.get(0).Bexio_Id__c))) {

            String result = Int_Helper_Reserved.putInvoices(invoices);
            Bexio_Billing invoiceBexio;

            if (result != null) {
                invoiceBexio = (Bexio_Billing) System.JSON.deserialize(result, Bexio_Billing.class);
            }

            if (invoiceBexio != null) {

                invoice = updateInvoices(invoiceBexio, invoiceId);
                updateInvoiceProduct(invoiceBexio, invoiceId);
            }
        }
        return invoice;
    }

    public static void updateInvoiceProduct(Bexio_Billing invoiceBexio, String invoiceId) {

        List<Invoice_Product__c> updateInvoiceProducts = new List<Invoice_Product__c>();
        Map<String, SObject> productMap = new Map<String, SObject>();

        List<Invoice_Product__c> products = [
                SELECT Id, Unit_Price__c, Total__c, Quantity__c,Bexio_Id__c, Product__r.Name, Position__c
                FROM Invoice_Product__c
                WHERE Invoice__c = :invoiceId
                ORDER BY Position__c ASC
        ];

        Integer positionInteger = 1;

        for (Invoice_Product__c prod : products) {
            productMap.put(String.valueOf(positionInteger), prod);
            positionInteger++;
        }

        for (Bexio_Billing_Position position : invoiceBexio.positions) {

            if (position.text != 'Discount' && String.isNotBlank(position.pos)) {
                Invoice_Product__c product = (Invoice_Product__c) productMap.get(position.pos);

                if (product != null) {
                    product.Position__c = Integer.valueOf(position.pos);
                    product.Bexio_Id__c = position.id;
                    updateInvoiceProducts.add(product);
                }
            }
        }

        update updateInvoiceProducts;
    }

    private static Invoice__c updateInvoices(Bexio_Billing invoiceBexio, String invoiceId) {

        List<Invoice__c> invoices = [
                SELECT Invoice__c, Bexio_Id__c, PDF_Email_Status__c, Update_in_Bexio__c, RecordTypeId, Rounding_difference__c
                FROM Invoice__c
                WHERE Id = :invoiceId
        ];
        if (invoices.size() > 0) {
            Invoice__c invoiceSalesforce = invoices.get(0);
            invoiceSalesforce.Invoice__c = invoiceBexio.document_nr;
            invoiceSalesforce.Bexio_Id__c = invoiceBexio.id;
            invoiceSalesforce.Update_in_Bexio__c = datetime.now();
            invoiceSalesforce.PDF_Email_Status__c = invoiceSalesforce.PDF_Email_Status__c != null ? invoiceSalesforce.PDF_Email_Status__c : 'Unsent';
            invoiceSalesforce.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('After create').getRecordTypeId();
            invoiceSalesforce.Rounding_difference__c = invoiceBexio.total_rounding_difference;
            //invoiceSalesforce.updateOnBexio__c = invoiceSalesforce.updateOnBexio__c ? false : true;
            update invoiceSalesforce;
            return invoiceSalesforce;
        } else {
            return null;
        }
    }

    //++++++++++++++++++++++++++++++++++++++
    @AuraEnabled
    public static String schedulerInvoices(String body, String subject, String nameInvoice, String startDay, String endDay,
    String accountEmail, String emailTemplateName, Id invoiceId, String emailsCC, String emailsTO) {
        System.debug('schedulerInvoices');
        System.debug('CC:' + emailsCC);
        System.debug('TO:' + emailsTO);
        System.debug('schedulerInvoices EMAIL');
        if (startDay.length() > 16) {
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

            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = '0 ' + minutes + ' ' + hours + ' ' + days + ' ' + mounths + ' ?';
            String jobName = 'Send an email for an invoice ' + nameInvoice;

            List<CronTrigger> scheduleInProgress = [
                    SELECT Id, NextFireTime
                    FROM CronTrigger
                    WHERE CronJobDetail.Name = :jobName
                    LIMIT 1
            ];
            if (!scheduleInProgress.isEmpty()) {
                System.abortJob(scheduleInProgress.get(0).Id);
            }
            EmailScheduledInvoice reminder = new EmailScheduledInvoice(body, subject, jobName, accountEmail, emailTemplateName, invoiceId, emailsCC, emailsTO);
            String jobID = System.schedule(jobName, sch, reminder);
            return 'Success';
        } else {
            return 'Error in class "schedulerInvoices"';
        }
    }
    //++++++++++++++++++++++++++++++++++++++
    //++++++++++++++++++++++++++++++++++++++
    public static String createSendEmailInvoice(String body, String subjectEmail, String accountEmail, String emailTemplateName, Id invoiceId, String emailsCC, String emailsTO) {
        System.debug('createSendEmailInvoice');
        String result;

        Email_log__c log = new Email_log__c();
        log.Sending_time__c = Datetime.now();
        log.Description__c += 'InvoiceId--->' + invoiceId + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'SubjectEmail--->' + subjectEmail + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'EmailTemplateName--->' + emailTemplateName + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'Body--->' + body + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'emailsCC--->' + emailsCC + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';
        log.Description__c += 'emailsTO--->' + emailsTO + '\n';
        log.Description__c += '----------------------------------------------------' + '\n';

        if (emailsTO != null) {
            String [] addresses = new String[0];
            String [] ccAddresses = new String[0];
            List<String> attachmentListId = new List<String>();
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            List <Messaging.SingleEmailMessage> messagesList = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> etList = [SELECT Id FROM EmailTemplate WHERE Name = :emailTemplateName];
            if (etList.size() > 0) {
                emailMessage.setTemplateId(etList.get(0).Id);
            }

            List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId = :invoiceId];
            if (attachmentList.size() > 0) {
                for (Attachment att : attachmentList) {
                    attachmentListId.add(att.Id);
                }
                emailMessage.setEntityAttachments(attachmentListId);
            }

            List<String> emailsTOLStrings = emailsTO.split(';');
            for (String email : emailsTOLStrings) {
                System.debug(email);
                addresses.add(email);
            }

            List<String> emailsCCLStrings = emailsCC.split(';');
            for (String emCC : emailsCCLStrings) {
                System.debug(emCC);
                ccAddresses.add(emCC);
            }

            emailMessage.setToAddresses(addresses);
            emailMessage.setCcAddresses(ccAddresses);
            emailMessage.setSubject(subjectEmail);
            emailMessage.setHtmlBody(body);
            emailMessage.setWhatId(invoiceId);
            emailMessage.setTargetObjectId(UserInfo.getUserId());
            emailMessage.setSaveAsActivity(false);
            emailMessage.setTreatTargetObjectAsRecipient(false);

            messagesList.add(emailMessage);

            Messaging.SendEmailResult [] results = Messaging.sendEmail(messagesList);

            if (results[0].success) {
                System.debug('The email Invoice was sent successfully');
            } else {
                System.debug('The email Invoice failed to send: ' + results[0].errors[0].message);
            }
            result = 'Success class "createSendEmailInvoice"';
        } else {
            result = 'Error in class "createSendEmailInvoice": emailsTO -> null';
        }
        try {
            insert log;
        } catch (DmlException ex) {
            System.debug(ex.getMessage());
        }
        return result;
    }
    //++++++++++++++++++++++++++++++++++++++

    public class AttachmentFile {
        public String nameFile { get; set; }
        public String urlFile { get; set; }
//        public String typeFile { get; set; }
//        public String idFile { get; set; }
    }

    public class Bexio_Billing {
        String id { get; set; }
        String document_nr { get; set; }
        Decimal total_rounding_difference { get; set; }
        List<Bexio_Billing_Position> positions { get; set; }
    }

    public class Bexio_Billing_Position {
        String id { get; set; }
        String text { get; set; }
        String pos { get; set; }
    }


}