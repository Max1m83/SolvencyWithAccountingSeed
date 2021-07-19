/**
 * Created by max1m on 20.08.20.
 */

public with sharing class Handler {

    public static List<Opportunity> timeLineEdit(List<Opportunity> oppNew) {

        Map<Integer, String> MONTH_QUARTER = new Map<Integer, String>{
                1 => 'Q1',
                2 => 'Q1',
                3 => 'Q1',
                4 => 'Q2',
                5 => 'Q2',
                6 => 'Q2',
                7 => 'Q3',
                8 => 'Q3',
                9 => 'Q3',
                10 => 'Q4',
                11 => 'Q4',
                12 => 'Q4'
        };

        List<Opportunity> returnOpp = new List<Opportunity>();
        List<Schema.PicklistEntry> yearsValue = Opportunity.fields.Years__c.getDescribe().getpicklistvalues();

        for (Opportunity opp : oppNew) {

            Date threeMounthAgo = opp.CloseDate.addMonths(3);
            String timeLineMounth = MONTH_QUARTER.get(threeMounthAgo.month());
            String timeLineYears = String.valueOf(threeMounthAgo.year());
            Boolean isExistValueYears = false;

            for (Schema.PicklistEntry picklistYears : yearsValue) {
                if (picklistYears.value == timeLineYears) {
                    isExistValueYears = true;
                }
            }

            if (isExistValueYears) {
                opp.Years__c = timeLineYears;
                opp.Quarter__c = timeLineMounth;
            }
            returnOpp.add(opp);
        }

        return returnOpp;
    }

    public static void candidateBeforeInsert(List<Candidate__c> newCandidates) {

    }

    private static Contact CandidateContact(Candidate__c candidate, Contact conNew) {

        conNew.LastName = String.isNotBlank(candidate.Last_Name__c) ? candidate.Last_Name__c : 'Unknown';
        conNew.FirstName = candidate.First_Name__c;
        conNew.Email = String.isNotBlank(candidate.Email__c) ? candidate.Email__c : 'solvency@solvency.com';
        return conNew;
    }

    public static void candidateBeforeUpdate(Map<Id, Candidate__c> newCandidates, Map<Id, Candidate__c> oldCandidates) {
        //Always new Candidate should be have the Stage Progress  Pending
        Map<Id, Candidate__c> updateContact = new Map<Id, Candidate__c>();
        Map<Candidate__c, Contact> candidatesMap = new Map<Candidate__c, Contact>();
        List<Contact> contacts = new List<Contact>();
        for (Candidate__c candidate : newCandidates.values()) {
            if (candidate.Last_Name__c != oldCandidates.get(candidate.Id).Last_Name__c ||
                    candidate.First_Name__c != oldCandidates.get(candidate.Id).First_Name__c ||
                    candidate.Email__c != oldCandidates.get(candidate.Id).Email__c) {
                if (candidate.Contact__c != null) {
                    updateContact.put(candidate.Contact__c, candidate);
                } else {
                    Contact conNew = new Contact();
                    conNew = CandidateContact(candidate, conNew);
                    candidatesMap.put(candidate, conNew);
                    System.debug(conNew);
                }
            }
        }
        for (Contact con : [SELECT Id FROM Contact WHERE Id = :updateContact.keySet()]) {
            con = CandidateContact(updateContact.get(con.Id), con);
            contacts.add(con);
        }
        update contacts;
        insert candidatesMap.values();

        for (Candidate__c candidate : candidatesMap.keySet()) {
            candidate.Contact__c = candidatesMap.get(candidate).Id;
        }
    }

    public static void reminderEmailBeforeInsert(List<Reminder_email__c> newReminderEmails) {

        for (Reminder_email__c reminder : newReminderEmails) {
            reminder.Date_create__c = reminder.Date_create__c == null ? Datetime.now() : reminder.Date_create__c;
            updateDateLastChangeDate(reminder);
        }
    }

    public static void reminderEmailBeforeUpdate(Map<Id, Reminder_email__c> reminderEmailsOld, Map<Id, Reminder_email__c> reminderEmailsNew) {
        createEventReminderEmails(reminderEmailsOld, reminderEmailsNew);
        for (Reminder_email__c reminder : reminderEmailsNew.values()) {
            if (reminder.Reminder_Stage__c != reminderEmailsOld.get(reminder.Id).Reminder_Stage__c) {
                updateDateLastChangeDate(reminder);
            }
        }
    }

    private static void updateDateLastChangeDate(Reminder_email__c newReminderEmail) {
        newReminderEmail.Last_change_date_of_stage__c = Date.today();
        newReminderEmail.Count_days__c = 0;
    }

    private static void createEventReminderEmails(Map<Id, Reminder_email__c> reminderEmailsOld, Map<Id, Reminder_email__c> reminderEmailsNew) {
        for (Reminder_email__c reminder : reminderEmailsNew.values()) {
            if (reminder.Reminder_Stage__c != reminderEmailsOld.get(reminder.Id).Reminder_Stage__c) {

                if (reminder.Reminder_Stage__c != 'Overdue') {
                    if (!reminder.isCancel__c) {
                        Event_Reminder_emails__e event = new Event_Reminder_emails__e();
                        event.RemEmail_Ids__c = reminder.Id;
                        event.Status__c = reminderEmailsOld.get(reminder.Id).Reminder_Stage__c;
                        List<Event_Reminder_emails__e> newEvents = new List<Event_Reminder_emails__e>();
                        newEvents.add(event);
                        List<Database.SaveResult> results = EventBus.publish(newEvents);

                        if (results.get(0).isSuccess()) {
                            System.debug('Successfully published event.');
                        } else {
                            for (Database.Error err : results.get(0).getErrors()) {
                                String result = 'Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage();

                                System.debug(result);
                                createLog('Event Reminder Publish', result, 'Error');
                            }
                        }
                    } else {
                        reminder.isCancel__c = false;
                    }
                }
                if (reminder.Reminder_Stage__c == 'Stage 2') {
                    reminder.Picture_Status__c = 'Stage 2';
                } else if (reminder.Reminder_Stage__c == 'Stage 3') {
                    reminder.Picture_Status__c = 'Stage 3';
                } else {
                    reminder.Picture_Status__c = 'Overdue';
                }
            }
        }
    }

    private static void createLog(String typeLog, String description, String status) {

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = typeLog;
        log.Description__c = description;
        log.Status__c = status;

        insert log;
    }

    public static void recurringInvoiceBeforeInsert(List<Recurring_Invoice__c> invoices) {
        //updateNextDayCreateInvoice(invoices);
        for (Recurring_Invoice__c recurring : invoices) {
            if (recurring.Next_Invoice_Date__c == null) {
                recurring.Next_Invoice_Date__c = Date.today();
            }
        }
    }

    public static void recurringInvoiceBeforeUpdate(Map<Id, Recurring_Invoice__c> invoicesOld, Map<Id, Recurring_Invoice__c> invoicesNew) {

        List<Recurring_Invoice__c> updateNextDay = new List<Recurring_Invoice__c>();

        for (Recurring_Invoice__c rec : invoicesNew.values()) {
            if (rec.Last_Invoice_Date__c != invoicesOld.get(rec.Id).Last_Invoice_Date__c || rec.Invoice_Frequency__c != invoicesOld.get(rec.Id).Invoice_Frequency__c) {
                updateNextDay.add(rec);
            }
        }
        updateNextDayCreateInvoice(updateNextDay);
    }

    private static void updateNextDayCreateInvoice(List<Recurring_Invoice__c> invoices) {

        for (Recurring_Invoice__c invoice : invoices) {
            if (invoice.Status__c == 'Active' && !Test.isRunningTest()) {

                Date dateLastDate = invoice.Last_Invoice_Date__c != null ? invoice.Last_Invoice_Date__c : Date.today();

                if (invoice.Invoice_Frequency__c == 'Monthly') {
                    invoice.Next_Invoice_Date__c = dateLastDate.addMonths(1);
                } else if (invoice.Invoice_Frequency__c == 'Quarterly') {
                    invoice.Next_Invoice_Date__c = dateLastDate.addMonths(3);
                } else if (invoice.Invoice_Frequency__c == 'Semi-annual') {
                    invoice.Next_Invoice_Date__c = dateLastDate.addMonths(6);
                } else if (invoice.Invoice_Frequency__c == 'Annual') {
                    invoice.Next_Invoice_Date__c = dateLastDate.addMonths(12);
                }
            }
        }
    }

    public static void invoiceProductAfterUpdate(Map<Id, Invoice_Product__c> newProducts, Map<Id, Invoice_Product__c> oldProducts) {
        changeDescriptionAnnexInvoice(newProducts.values());
    }

    public static void invoiceProductAfterInsert(Map<Id, Invoice_Product__c> newProducts) {
        changeDescriptionAnnexInvoice(newProducts.values());
    }

//    public static void accountTriggerInsertAfter(List<Account> newInsertAccount) {
//        createAccountOnBexioSide(newInsertAccount);
//    }

    public static void accountTriggerInsertBefore(List<Account> newInsertAccount) {

        for (Account acc : newInsertAccount) {

            if (String.isBlank(acc.Company_name__c)) {
                acc.Company_name__c = acc.Name;
            }
        }
    }

//    private static void createAccountOnBexioSide(List<Account> newInsertAccount) {
//
//        Int_Account_PUT_Queueable accountPuts = new Int_Account_PUT_Queueable(newInsertAccount);
//         // enqueue the job for processing
//        Id jobID = System.enqueueJob(accountPuts);
//    }

    public static void billingTriggerUpdateBefore(Map<Id, AcctSeed__Billing__c> newBillings, Map<Id, AcctSeed__Billing__c> oldBillings) {

//        for (AcctSeed__Billing__c bill : newBillings.values()) {
//
//            if (bill.with_VAT__c == true) {
//                bill.PageTriggerTotal__c = bill.AcctSeed__Discount_Amount__c > 0 ? bill.VAT__c + bill.AcctSeed__Sub_Total__c - bill.AcctSeed__Discount_Amount__c : bill.VAT__c + bill.AcctSeed__Sub_Total__c;
//            } else {
//                bill.PageTriggerTotal__c = 0;
//            }
//        }
//        calculateChangedBillingNumber(newBillings, oldBillings);
//        List<AcctSeed__Billing__c> billing = changePaymentStatusPicklist(newBillings.values());
    }

    public static void invoiceTriggerAfterUpdate(Map<Id, Invoice__c> invoicesNew, Map<Id, Invoice__c> invoicesOld) {
        updateReminderEmailObjects(invoicesNew, invoicesOld);
        sendMessageToElenaIfApproval(invoicesNew, invoicesOld);
        //createQueueable(updateInvoicesOnBexio(invoicesNew, invoicesOld), 'Update');
    }

    private static void sendMessageToElenaIfApproval(Map<Id, Invoice__c> invoicesNew, Map<Id, Invoice__c> invoicesOld) {
        Set<String> approvals = new Set<String>();
        Set<String> rejects = new Set<String>();

        for (Invoice__c invoice : invoicesNew.values()) {
            if (invoice.Posting_Status__c != invoicesOld.get(invoice.Id).Posting_Status__c) {
                if (invoice.Posting_Status__c == 'Approved') {
                    approvals.add(invoice.Invoice__c);
                } else if (invoice.Posting_Status__c == 'Rejected') {
                    rejects.add(invoice.Invoice__c);
                }
            }
        }
        if (approvals.size() > 0) {
            createSendMessage(approvals.toString().removeEnd('}').removeStart('{'), 'Approved');
        }
        if (rejects.size() > 0) {
            createSendMessage(rejects.toString().removeEnd('}').removeStart('{'), 'Rejected');
        }
    }

    private static void createSendMessage(String invoiceNumbers, String status) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List <String> listAddress = new List<String>();
        String Subject = (status == 'Approved' ? 'The invoice ' + invoiceNumbers + ' has been approved' : 'The invoice ' + invoiceNumbers + ' has been rejected');
        String body = (status == 'Approved' ? 'The invoice(s) ' + invoiceNumbers + ' has been approved. Hence, it is ready to be sent.' : 'The invoice(s) ' + invoiceNumbers + ' has been rejected. Please amend it.');
        listAddress.add('elittau@solvencyanalytics.com');
        //listAddress.add('maxkolt@tut.by');
        email.setToAddresses(listAddress);
        email.setSubject(Subject);
        email.setSaveAsActivity(true);

        email.setHtmlBody(body);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
        } catch (Exception ex) {
            System.debug('*********************');
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }

    private static void updateReminderEmailObjects(Map<Id, Invoice__c> invoicesNew, Map<Id, Invoice__c> invoicesOld) {

        Set<Id> reminderIds = new Set<Id>();
        Map<Id, Reminder_email__c> reminders = new Map<Id, Reminder_email__c>();
        List<Contacts_for_Billing__c> contacts = new List<Contacts_for_Billing__c>();
        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];

        for (Invoice__c invoice : invoicesNew.values()) {
            if (invoice.Invoice_Status__c != invoicesOld.get(invoice.Id).Invoice_Status__c) {
                if (invoice.Invoice_Status__c == 'Overdue') {
                    reminders.put(invoice.Id, createEmailObject(invoice, settingsReminder));
                } else {
                    reminderIds.add(invoice.Id);
                }
            }
        }
        upsert reminders.values();
        delete [SELECT Id FROM Reminder_email__c WHERE Invoice__c IN :reminderIds];

        for (Invoice__c invoice : [SELECT Id, (SELECT Id, Reminder_email__c FROM Invoice_Contact_Groups_Billing__r) FROM Invoice__c]) {
            if (reminders.containsKey(invoice.Id)) {
                contacts.addAll(createContactGroups(invoice, reminders.get(invoice.Id)));
            }
        }
        upsert contacts;
    }

    public static void invoiceTriggerAfterInsert(List<Invoice__c> invoices) {

        Map<Id, Reminder_email__c> reminders = new Map<Id, Reminder_email__c>();
        List<Contacts_for_Billing__c> contacts = new List<Contacts_for_Billing__c>();
        List<Settings_Reminder_email__c> settingsReminder = [SELECT Id FROM Settings_Reminder_email__c LIMIT 1];

        for (Invoice__c invoice : invoices) {
            if (invoice.Invoice_Status__c == 'Overdue' && invoice.Reminder_emails__r.size() == 0) {
                reminders.put(invoice.Id, createEmailObject(invoice, settingsReminder));
            }
        }
        upsert reminders.values();

        for (Invoice__c invoice : invoices) {
            if (reminders.containsKey(invoice.Id)) {
                contacts.addAll(createContactGroups(invoice, reminders.get(invoice.Id)));
            }
        }
        upsert contacts;
        //createQueueable(invoices, 'Insert');
    }

    public static void invoiceTriggerBeforeInsert(List<Invoice__c> invoices) {
        approvedInvoices (invoices);
    }

    private static Reminder_email__c createEmailObject(Invoice__c invoice, List<Settings_Reminder_email__c> settingsReminder) {

        Reminder_email__c newReminder = new Reminder_email__c();
        newReminder.Account__c = invoice.Account__c;
        newReminder.CurrencyIsoCode = invoice.CurrencyIsoCode;
        newReminder.Date_create__c = Datetime.now();
        newReminder.Invoice__c = invoice.Id;
        newReminder.isCancel__c = false;
        newReminder.Reminder_Stage__c = 'Overdue';
        newReminder.Name = (invoice.Company_name__c != null ? invoice.Company_name__c : invoice.Invoice__c);
        newReminder.Picture_Status__c = 'Overdue';
        if (settingsReminder.size() > 0) {
            newReminder.Settings_Reminder_email__c = settingsReminder.get(0).Id;
        }
        newReminder.Status__c = 'Unsent';
        return newReminder;
    }

    private static List<Contacts_for_Billing__c> createContactGroups(Invoice__c invoice, Reminder_email__c newReminder) {

        List<Contacts_for_Billing__c> updateContacts = new List<Contacts_for_Billing__c>();

        for (Contacts_for_Billing__c bill : invoice.Invoice_Contact_Groups_Billing__r) {
            bill.Reminder_email__c = newReminder.Id;
            updateContacts.add(bill);
        }

        return updateContacts;
    }

    public static void billingProductTriggerInsertAfter(List<AcctSeed__Billing_Line__c> newBillings) {
        calculatePageTriggerTotalField(newBillings);
        sortBillingProduct(newBillings);
    }

    public static void billingProductTriggerUpdateAfter(Map<Id, AcctSeed__Billing_Line__c> newBillingProds, Map<Id, AcctSeed__Billing_Line__c> oldBillingProds) {
        calculatePageTriggerTotalField(newBillingProds.values());
        sortBillingProductsForNameProduct(newBillingProds, oldBillingProds);
    }

    public static void billingProductTriggerInsertBefore(List<AcctSeed__Billing_Line__c> newBillings) {

        Set<Id> billIds = new Set<Id>();
        Map<Id, AcctSeed__Billing__c> billings = new Map<Id, AcctSeed__Billing__c>();

        for (AcctSeed__Billing_Line__c product : newBillings) {
            billIds.add(product.AcctSeed__Billing__c);
        }

        for (AcctSeed__Billing__c bill : [SELECT Id, CurrencyIsoCode FROM AcctSeed__Billing__c WHERE Id IN :billIds]) {
            billings.put(bill.Id, bill);
        }

        for (AcctSeed__Billing_Line__c product : newBillings) {

            product.CurrencyIsoCode = billings.get(product.AcctSeed__Billing__c).CurrencyIsoCode;
        }
    }

    public static void billingTriggerUpdateAfter(List<AcctSeed__Billing__c> newUpdateBillings) {
        if (newUpdateBillings != null) {
            calculateAmountOpportunity (newUpdateBillings);
        }
    }

    public static void billingTriggerInsertBefore(List<AcctSeed__Billing__c> newUpdateBillings) {

        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

        for (AcctSeed__Billing__c bill : newUpdateBillings) {
            bill.AcctSeed__Due_Date2__c = bill.AcctSeed__Date__c.addDays(30);
            oppIds.add(bill.AcctSeed__Opportunity__c);
        }

        for (Opportunity opp : [SELECT Id, Invoice_approval_required__c FROM Opportunity WHERE Id IN:oppIds]) {
            oppMap.put(opp.Id, opp);
        }

        for (AcctSeed__Billing__c bill : newUpdateBillings) {

            if (oppMap.get(bill.AcctSeed__Opportunity__c).Invoice_approval_required__c) {
                bill.AcctSeed__Status__c = 'Waiting for approval';
            } else {
                bill.AcctSeed__Status__c = 'Approved';
            }
        }

        calculationBillingNumber(newUpdateBillings);
        createInvoiceGroupBilling(newUpdateBillings);
        recurringBillingInvoiceTitle(newUpdateBillings);
        List<AcctSeed__Billing__c> billing = changePaymentStatusPicklist(newUpdateBillings);
    }

    private static void approvedInvoices(List<Invoice__c> newInvoices) {

        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();

        for (Invoice__c invoice : newInvoices) {

            invoice.Billing_Date__c = invoice.Date__c.addDays(30);
            oppIds.add(invoice.Opportunity__c);
        }

        for (Opportunity opp : [SELECT Id, Invoice_approval_required__c, OwnerId FROM Opportunity WHERE Id IN:oppIds]) {
            oppMap.put(opp.Id, opp);
        }

        for (Invoice__c invoice : newInvoices) {

            if (oppMap.get(invoice.Opportunity__c) != null && oppMap.get(invoice.Opportunity__c).Invoice_approval_required__c) {
                invoice.Posting_Status__c = 'In Process';
            } else {
                invoice.Posting_Status__c = 'Approved';
            }
            invoice.User_to_approve__c = oppMap.containsKey(invoice.Opportunity__c) ? oppMap.get(invoice.Opportunity__c).OwnerId : UserInfo.getUserId();
        }
    }

    private static List<AcctSeed__Billing__c> changePaymentStatusPicklist(List<AcctSeed__Billing__c> billings) {

        for (AcctSeed__Billing__c bill : billings) {

            if (bill.AcctSeed__Balance__c > 0) {

                if (bill.AcctSeed__Due_Date2__c < Date.today()) {
                    bill.PaymentStatusPicklist__c = 'Overdue';
                } else {
                    bill.PaymentStatusPicklist__c = 'Pending';
                }
            } else {
                bill.PaymentStatusPicklist__c = 'Paid';
            }
        }

        return billings;
    }

    public static void contactEntityTriggerInsertAfter(List<Contact_entity__c> newInsertContactEntity) {
        fillingEmails(newInsertContactEntity);
    }

    public static void contactEntityTriggerUpdateAfter(List<Contact_entity__c> newInsertContactEntity) {
        fillingEmails(newInsertContactEntity);
    }

    public static void contactEntityTriggerDeleteAfter(List<Contact_entity__c> newInsertContactEntity) {
        fillingEmails(newInsertContactEntity);
    }

    public static void billingTriggerInsertAfter(List<AcctSeed__Billing__c> newInsertBillings) {
        calculateAmountOpportunity (newInsertBillings);
    }

    public static void billingTriggerDeleteAfter(List<AcctSeed__Billing__c> oldBillings) {
        calculateAmountOpportunity (oldBillings);
    }

    public static void contactForBillingAfterInsert(Map<Id, Contacts_for_Billing__c> newGroups) {
        updateContactGroupName(newGroups.values());
        createSendToContacts(newGroups);
    }

    public static void contactForBillingBeforeDelete(Map<Id, Contacts_for_Billing__c> newGroups) {

        delete [SELECT Id FROM Send_to_Contact__c WHERE Invoice_Contact_Groups__c IN :newGroups.keySet()];
        updateContactGroupName(newGroups.values());
    }

    public static void contactForBillingBeforeUpdate(Map<Id, Contacts_for_Billing__c> oldGroups, Map<Id, Contacts_for_Billing__c> newGroups) {

        delete [SELECT Id FROM Send_to_Contact__c WHERE Invoice_Contact_Groups__c IN :oldGroups.keySet()];
        createSendToContacts(newGroups);
    }

    public static void contactForBillingAfterUpdate(Map<Id, Contacts_for_Billing__c> oldGroups, Map<Id, Contacts_for_Billing__c> newGroups) {
        updateContactGroupName(newGroups.values());
    }

    public static void jobApplicationBeforeUpdate(Map<Id, Job_Application__c> newUpdateJobApp, Map<Id, Job_Application__c> oldUpdateJobApp) {
        approvalStages(newUpdateJobApp, oldUpdateJobApp);
    }

    public static void jobApplicationUpdate(Map<Id, Job_Application__c> newUpdateJobApp, Map<Id, Job_Application__c> oldUpdateJobApp) {

        List<Event_Job_App__e> newEvents = new List<Event_Job_App__e>();
        Map<Id, Job_Application__c> sendJobs = new Map<Id, Job_Application__c>();

        for (Job_Application__c job : newUpdateJobApp.values()) {
            if (job.Picklist__c != oldUpdateJobApp.get(job.Id).Picklist__c) {
                if (job.Picklist__c == 'Contact verified') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                } else if (job.Picklist__c == 'Phone interview') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                } else if (job.Picklist__c == 'Rejected') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                } else if (job.Picklist__c == 'Test') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                } else if (job.Picklist__c == 'Final interview') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                } else if (job.Picklist__c == 'Hired') {
                    newEvents.add(new Event_Job_App__e(Status__c = job.Picklist__c, jobId__c = job.Id, Old_Status__c = oldUpdateJobApp.get(job.Id).Picklist__c, About__c = 'Email'));
                }
                sendJobs.put(job.Id, job);
            }
        }

        if (sendJobs.size() > 0) {
            notificationSend(sendJobs);
        }
        List<Database.SaveResult> results = EventBus.publish(newEvents);
    }

    private static void approvalStages(Map<Id, Job_Application__c> newUpdateJobApp, Map<Id, Job_Application__c> oldUpdateJobApp) {
        List<Event_Job_App__e> newEvents = new List<Event_Job_App__e>();
        for (Job_Application__c job : newUpdateJobApp.values()) {
            if (job.Picklist__c != oldUpdateJobApp.get(job.Id).Picklist__c && oldUpdateJobApp.get(job.Id).Picklist__c != 'New') {
                if (job.Picklist__c == 'Rejected') {
                    job.Stage_Progress__c = 'Rejected';
                } else if (job.Picklist__c == 'Declined by candidate' || job.Picklist__c == 'New') {
                    job.Stage_Progress__c = 'Approved';
                } else {
                    if (job.Stage_Progress__c == 'Approved') {
                        job.Stage_Progress__c = 'Pending';
                    } else if(job.Stage_Progress__c == 'Rejected' || oldUpdateJobApp.get(job.Id).Picklist__c == 'Rejected') {
                        job.Stage_Progress__c = 'Pending';
                    }
                    else {
                        job.Picklist__c = oldUpdateJobApp.get(job.Id).Picklist__c;
                        newEvents.add(new Event_Job_App__e(About__c = 'Refresh'));
                    }
                }
            }
        }
        List<Database.SaveResult> results = EventBus.publish(newEvents);
    }

    public static void notificationSend(Map<Id, Job_Application__c> newApplications) {

        Map<Id, List<Job_Application__c>> mapsPositions = new Map<Id, List<Job_Application__c>>();

        for (Job_Application__c job : newApplications.values()) {
            mapsPositions.put(job.Position__c, new List<Job_Application__c>());
        }

        for (Job_Application__c job : newApplications.values()) {
            mapsPositions.get(job.Position__c).add(job);
        }

        Map<Id, Position__c> positions = new Map<Id, Position__c>([
                SELECT Stage_of_Job_Application__c, Notifications_to_the_Email__c, Contact_for_notification__c,
                        Contact_for_notification__r.FirstName, Contact_for_notification__r.Email, Name
                FROM Position__c
                WHERE Id = :mapsPositions.keySet() AND Stage_of_Job_Application__c != NULL
        ]);
        Integer i = 1;

        for (Position__c pos : positions.values()) {
            List<String> selectStages = pos.Stage_of_Job_Application__c.split(';');
            for (Job_Application__c job : mapsPositions.get(pos.Id)) {
                if (selectStages.contains(job.Picklist__c) || Test.isRunningTest()) {
                    if ((i ==1 && String.isNotBlank(positions.get(job.Position__c).Contact_for_notification__r.Email)) || Test.isRunningTest()) {
                        createMassage(job, positions);
                        i++;
                    }
                }
            }
        }
    }

    private static void createMassage(Job_Application__c job, Map<Id, Position__c> positions) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List <String> listAddress = new List<String>();
        String Subject = 'New Job Application: ' + positions.get(job.Position__c).Name + '.';
        //String link = URL.getSalesforceBaseUrl().toExternalForm()+ '/' + job.Id;
        String link = 'https://solvencyanalytics.lightning.force.com/lightning/r/Job_Application__c/' + job.Id + '/view';
        String body = 'Dear '+ positions.get(job.Position__c).Contact_for_notification__r.FirstName + ','+'<br/>';
        body += '<br/>';
        body += 'This is a request for your approval for the following Job Application: ' + link +'<br/>';
        body += '<br/>';
        body +='Please click this link to approve or reject this record.';
        body += '<br/>';
        body += '<br/>';
        body +='Thank you,';
        body += '<br/>';
        body += UserInfo.getFirstName();
        listAddress.add(positions.get(job.Position__c).Contact_for_notification__r.Email);
        email.setToAddresses(listAddress);
        email.setSubject(Subject);
        email.setSaveAsActivity(true);
        email.setHtmlBody(body);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
        } catch (Exception ex) {
            System.debug('*********************');
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }

    public static void jobApplicationBeforeInsert(List<Job_Application__c> newApplication) {
        for (Job_Application__c job : newApplication) {
            job.Stage_Progress__c = 'Pending';
        }
    }

    public static void contactAfterUpdate(Map<Id, Contact> newContact, Map<Id, Contact> oldContact) {

        Set<Id> contIds = new Set<Id>();

        for (Contact con : newContact.values()) {
            if (con.Email != oldContact.get(con.Id).Email) {
                contIds.add(con.Id);
            }
            System.debug(con);
        }
        fillingEmails([
                SELECT Id, Contact_group__c, Recipient__c, Contact__c
                FROM Contact_entity__c
                WHERE Contact__c IN :contIds
        ]);
    }

    public static void calculationBillingNumber(List<AcctSeed__Billing__c> newBillings) {

        Integer year = Date.today().year();

        List<AcctSeed__Billing__c> billLast = [
                SELECT Id, Number__c, Billing_Year__c
                FROM AcctSeed__Billing__c
                WHERE Billing_Year__c = :year
                ORDER BY Number__c DESC
                LIMIT 1
        ];

        if (billLast.size() == 0) {
            changeBillingNumber(newBillings, Date.today().year(), 0);
        } else {
            changeBillingNumber(newBillings, Date.today().year(), Integer.valueOf(Date.today().year() != billLast.get(0).Billing_Year__c ? 0 : billLast.get(0).Number__c));
        }
    }

    public static void changeBillingNumber(List<AcctSeed__Billing__c> newBillings, Integer years, Integer startNumber) {

        integer step = 1;

        for (AcctSeed__Billing__c bill : newBillings) {
            bill.Billing_Year__c = years;
            bill.Number__c = startNumber + step;
            bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + String.valueOf(bill.Number__c);
            step++;
        }
    }

    private static void calculateAmountOpportunity(List<AcctSeed__Billing__c> newInsertBillings) {

        Map<Id, List<AcctSeed__Billing__c>> oppBillings = new Map<Id, List<AcctSeed__Billing__c>>();
        Map<String, CurrencyType> curExist = new Map<String, CurrencyType>();
        List<Opportunity> updateOpp = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();

        for (CurrencyType curr : [SELECT Id, ConversionRate, IsoCode FROM CurrencyType]) {
            curExist.put(curr.IsoCode, curr);
        }

        for (AcctSeed__Billing__c bill : newInsertBillings) {
            oppIds.add(bill.AcctSeed__Opportunity__c);
        }

        for (AcctSeed__Billing__c bill : [
                SELECT Id, AcctSeed__Opportunity__c, AcctSeed__Total__c
                FROM AcctSeed__Billing__c
                WHERE AcctSeed__Opportunity__c IN :oppIds
        ]) {

            oppIds.add(bill.AcctSeed__Opportunity__c);

            if (oppBillings.containsKey(bill.AcctSeed__Opportunity__c)) {
                List<AcctSeed__Billing__c> billList = oppBillings.get(bill.AcctSeed__Opportunity__c);
                billList.add(bill);
                oppBillings.put(bill.AcctSeed__Opportunity__c, billList);
            } else {
                List<AcctSeed__Billing__c> billList = new List<AcctSeed__Billing__c>();
                billList.add(bill);
                oppBillings.put(bill.AcctSeed__Opportunity__c, billList);
            }
        }

        for (Opportunity opp : [
                SELECT Id, Amounts_in_currency__c, CurrencyIsoCode
                FROM Opportunity
                WHERE Id IN :oppIds
        ]) {

            if (oppBillings.get(opp.Id) != null) {

                opp.Amounts_in_currency__c = 0;

                for (AcctSeed__Billing__c bill : oppBillings.get(opp.Id)) {

                    opp.Amounts_in_currency__c += bill.AcctSeed__Total__c;
                }

                CurrencyType cur = curExist.get(opp.CurrencyIsoCode);

                if (cur.ConversionRate != null || cur.ConversionRate != 0) {

                    opp.Amounts_in_CHF__c = 'CHF ' + (opp.Amounts_in_currency__c / cur.ConversionRate).setscale (2).format();
                }
                updateOpp.add(opp);
            }
        }

        if (updateOpp.size() > 0) {
            update updateOpp;
        }
    }

    private static void createSendToContacts(Map<Id, Contacts_for_Billing__c> newGroups) {

        List<Send_to_Contact__c> createNew = new List<Send_to_Contact__c>();
        Map<Id, Contacts_for_Billing__c> existGroup = new Map<Id, Contacts_for_Billing__c>();
        Set<Id> contactGroup = new Set<Id>();

        for (Contacts_for_Billing__c con : newGroups.values()) {
            contactGroup.add(con.Contact_group__c);
            existGroup.put(con.Contact_group__c, con);
        }

        for (Contact_entity__c con : [SELECT Id, Contact__c, Contact_group__c FROM Contact_entity__c WHERE Contact_group__c IN :contactGroup]) {

            Send_to_Contact__c newCon = new Send_to_Contact__c();
            newCon.Contact__c = con.Contact__c;
            newCon.Billing__c = existGroup.get(con.Contact_group__c).Billing__c;
            newCon.Invoice_Contact_Groups__c = existGroup.get(con.Contact_group__c).Id;
            createNew.add(newCon);
        }

        insert createNew;
    }

    private static void updateContactGroupName(List<Contacts_for_Billing__c> billings) {

        Set<Id> invoiceIds = new Set<Id>();

        for (Contacts_for_Billing__c con : billings) {
            invoiceIds.add(con.Invoice__c);
        }

        List<Invoice__c> updateInvoices = new List<Invoice__c>();

        for (Invoice__c invoice : [SELECT Contact_groups__c, (SELECT Group_Name__c FROM Invoice_Contact_Groups_Billing__r) FROM Invoice__c WHERE Id IN:invoiceIds]) {

            String nameGroup = '';
            for (Contacts_for_Billing__c con : invoice.Invoice_Contact_Groups_Billing__r) {
                nameGroup += con.Group_Name__c + '; ';
            }
            invoice.Contact_groups__c = nameGroup.removeEnd('; ');
            updateInvoices.add(invoice);
        }

        update updateInvoices;
    }

    private static void calculatePageTriggerTotalField(List<AcctSeed__Billing_Line__c> newBillingProd) {

        Set<Id> invoiceIds = new Set<Id>();
        List<AcctSeed__Billing__c> updateBillings = new List<AcctSeed__Billing__c> ();

        for (AcctSeed__Billing_Line__c billProd : newBillingProd) {
            invoiceIds.add(billProd.AcctSeed__Billing__c);
        }

        for (AcctSeed__Billing__c bill : [
                SELECT Id, with_VAT__c, AcctSeed__Discount_Amount__c, AcctSeed__Sub_Total__c, PageTriggerTotal__c, VAT__c
                FROM AcctSeed__Billing__c
                WHERE Id IN :invoiceIds
        ]) {

            if (bill.with_VAT__c == true) {
                bill.PageTriggerTotal__c = bill.AcctSeed__Discount_Amount__c > 0 ? bill.VAT__c + bill.AcctSeed__Sub_Total__c - bill.AcctSeed__Discount_Amount__c : bill.VAT__c + bill.AcctSeed__Sub_Total__c;
            } else {
                bill.PageTriggerTotal__c = 0;
            }
            updateBillings.add(bill);
        }
        update updateBillings;
    }

    private static void fillingEmails(List<Contact_entity__c> newInsertContactEntity) {

        Set<Id> conGroupIds = new Set<Id>();
        Set<Id> existIds = new Set<Id>();
        List<Contact_entity__c> contacts = new List<Contact_entity__c>();
        List<Contact_group__c> updateGroups = new List<Contact_group__c>();

        for (Contact_entity__c con : newInsertContactEntity) {
            conGroupIds.add(con.Contact_group__c);
            existIds.add(con.Id);
        }

        for (Contact_group__c gr : [
                SELECT Id, Emails__c, Emails_CC__c, Emails_TO__c, (SELECT Id, Emails__c, Recipient__c, Position__c FROM Contact_entities__r ORDER BY Position__c ASC)
                FROM Contact_group__c
                WHERE Id IN :conGroupIds
        ]) {

            Set<String> emailsExist = new Set<String>();
            Set<String> emailsTOExist = new Set<String>();
            Set<String> emailsCCExist = new Set<String>();
            String toEmails = '';
            String ccEmails = '';
            Integer position = 1;

            for (Contact_entity__c conEnt : gr.Contact_entities__r) {

                if (conEnt.Position__c != position) {
                    conEnt.Position__c = position;
                    if (!existIds.contains(conEnt.Id)) {
                        contacts.add(conEnt);
                    }
                }

                conEnt.Position__c = position;

                position++;

                if (String.isNotBlank(conEnt.Emails__c)) {
                    emailsExist.add(conEnt.Emails__c);
                    if (conEnt.Recipient__c == 'TO') {
                        toEmails += conEnt.Emails__c + '; ';
                        emailsTOExist.add(conEnt.Emails__c);
                    } else if (conEnt.Recipient__c == 'CC') {
                        ccEmails += conEnt.Emails__c + '; ';
                        emailsCCExist.add(conEnt.Emails__c);
                    }
                }
            }

            gr.Emails__c = emailsExist.toString();
            gr.Emails_CC__c = ccEmails.removeEnd('; ');
            gr.Emails_TO__c = toEmails.removeEnd('; ');

            updateGroups.add(gr);
        }

        update updateGroups;
        update contacts;
    }

    private static void calculateChangedBillingNumber(Map<Id, AcctSeed__Billing__c> newBilling, Map<Id, AcctSeed__Billing__c> oldBilling) {

//        for (AcctSeed__Billing__c bill : newBilling.values()) {
//            if (bill.billing_number__c != oldBilling.get(bill.Id).billing_number__c) {
//
//                Integer yearsInteger = String.isBlank(bill.billing_number__c.substringAfter ('-')) ? Date.today().year() : Integer.valueOf(bill.billing_number__c.substringBefore ('-'));
//                Integer monthInteger = String.isBlank(bill.billing_number__c.substringAfter ('-')) ? Integer.valueOf(bill.billing_number__c.substringBefore ('-')) : Integer.valueOf(bill.billing_number__c.substringAfter ('-'));
//
//                if (bill.Billing_Year__c != yearsInteger) {
//
//                    if (yearsInteger < 2000 || yearsInteger > 2050) {
//                        bill.Billing_Year__c = Date.today().year();
//                    } else {
//                        bill.Billing_Year__c = yearsInteger;
//                    }
//                    if (bill.Number__c > 99) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + String.valueOf(bill.Number__c);
//                    } else if (bill.Number__c > 9) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '0' + String.valueOf(bill.Number__c);
//                    } else {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '00' + String.valueOf(bill.Number__c);
//                    }
//                }
//
//                if (bill.Number__c != monthInteger) {
//                    bill.Number__c = monthInteger;
//                    if (bill.Number__c > 99) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + String.valueOf(bill.Number__c);
//                    } else if (bill.Number__c > 9) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '0' + String.valueOf(bill.Number__c);
//                    } else {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '00' + String.valueOf(bill.Number__c);
//                    }
//                }
//
//                if (bill.billing_number__c.length() != 3) {
//                    if (bill.Number__c > 99) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + String.valueOf(bill.Number__c);
//                    } else if (bill.Number__c > 9) {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '0' + String.valueOf(bill.Number__c);
//                    } else {
//                        bill.billing_number__c = String.valueOf(bill.Billing_Year__c) + '-' + '00' + String.valueOf(bill.Number__c);
//                    }
//                }
//            }
//        }
    }

    private static void sortBillingProductsForNameProduct(Map<Id, AcctSeed__Billing_Line__c> newBillingProd, Map<Id, AcctSeed__Billing_Line__c> oldBillingProd) {

        Set<Id> billIds = new Set<Id>();
        List<AcctSeed__Billing_Line__c> updateList = new List<AcctSeed__Billing_Line__c>();

        for (AcctSeed__Billing_Line__c bill : newBillingProd.values()) {
            if (bill.Number__c != oldBillingProd.get(bill.Id).Number__c && bill.Name == oldBillingProd.get(bill.Id).Name) {
                billIds.add(bill.AcctSeed__Billing__c);
            }
        }

        List<AcctSeed__Billing__c> billings = [
                SELECT Id, Name, (
                        SELECT Id, Name, Number__c, quantity__c, Description2__c, AcctSeed__Revenue_GL_Account__c,
                                TotalForPage__c, AcctSeed__Hours_Units__c, AcctSeed__Rate__c, AcctSeed__Product__c
                        FROM AcctSeed__Project_Billing_Lines__r
                        ORDER BY Name ASC
                )
                FROM AcctSeed__Billing__c
                WHERE Id IN :billIds AND AutoSort_Product__c = FALSE
        ];

        for (AcctSeed__Billing__c bill : billings) {

            List<InvoiceWrapper> invoices = new List<InvoiceWrapper>();

            for (AcctSeed__Billing_Line__c billProd : bill.AcctSeed__Project_Billing_Lines__r) {
                InvoiceWrapper inv = new InvoiceWrapper(Integer.valueOf(billProd.Number__c),
                        billProd.AcctSeed__Product__c,
                        billProd.AcctSeed__Rate__c,
                        billProd.Description2__c,
                        billProd.AcctSeed__Hours_Units__c,
                        billProd.TotalForPage__c,
                        billProd.AcctSeed__Revenue_GL_Account__c);
                invoices.add(inv);
            }

            invoices.sort();

            for (Integer i = 0; i < bill.AcctSeed__Project_Billing_Lines__r.size(); i++) {
                AcctSeed__Billing_Line__c billProd = bill.AcctSeed__Project_Billing_Lines__r.get(i);
                billProd.Number__c = invoices.get(i).numberBilling;
                billProd.AcctSeed__Product__c = invoices.get(i).productId;
                billProd.AcctSeed__Rate__c = invoices.get(i).rate;
                billProd.Description2__c = invoices.get(i).description;
                billProd.AcctSeed__Hours_Units__c = invoices.get(i).quantity;
                billProd.TotalForPage__c = invoices.get(i).totalForPage;
                billProd.AcctSeed__Revenue_GL_Account__c = invoices.get(i).revenueGLAccountId;
                updateList.add(billProd);
            }
            update updateList;
        }
    }

    private static void sortBillingProduct(List<AcctSeed__Billing_Line__c> newBillingProd) {

        Set<Id> billIds = new Set<Id>();
        List<AcctSeed__Billing_Line__c> updateList = new List<AcctSeed__Billing_Line__c>();

        for (AcctSeed__Billing_Line__c bill : newBillingProd) {
            if (bill.Number__c != 0 || bill.Number__c != null) {
                billIds.add(bill.AcctSeed__Billing__c);
            }
        }

        List<AcctSeed__Billing__c> billings = [
                SELECT Id, Name, (
                        SELECT Id, Name, Number__c, quantity__c, StringNameProduct__c, Description2__c, AcctSeed__Revenue_GL_Account__c, TotalForPage__c, AcctSeed__Hours_Units__c, AcctSeed__Rate__c, AcctSeed__Product__c
                        FROM AcctSeed__Project_Billing_Lines__r
                        ORDER BY Name ASC
                )
                FROM AcctSeed__Billing__c
                WHERE Id IN :billIds
        ];

        for (AcctSeed__Billing__c bill : billings) {

            List<InvoiceWrapperAfterInsert> invoices = new List<InvoiceWrapperAfterInsert>();

            for (AcctSeed__Billing_Line__c billProd : bill.AcctSeed__Project_Billing_Lines__r) {
                InvoiceWrapperAfterInsert inv = new InvoiceWrapperAfterInsert(Integer.valueOf(billProd.Number__c),
                        billProd.AcctSeed__Product__c,
                        billProd.AcctSeed__Rate__c,
                        billProd.Description2__c,
                        billProd.AcctSeed__Hours_Units__c,
                        billProd.TotalForPage__c,
                        billProd.AcctSeed__Revenue_GL_Account__c,
                        billProd.StringNameProduct__c);
                invoices.add(inv);
            }

            invoices.sort();

            for (Integer i = 0; i < invoices.size(); i++) {
                AcctSeed__Billing_Line__c billProd = bill.AcctSeed__Project_Billing_Lines__r.get(i);
                billProd.Number__c = i + 1;
                billProd.AcctSeed__Product__c = invoices.get(i).productId;
                billProd.AcctSeed__Rate__c = invoices.get(i).rate;
                billProd.Description2__c = invoices.get(i).description;
                billProd.AcctSeed__Hours_Units__c = invoices.get(i).quantity;
                billProd.TotalForPage__c = invoices.get(i).totalForPage;
                billProd.AcctSeed__Revenue_GL_Account__c = invoices.get(i).revenueGLAccountId;
                updateList.add(billProd);
            }
            update updateList;
        }
    }

    private static void createInvoiceGroupBilling(List<AcctSeed__Billing__c> newUpdateBillings) {

        Set<Id> recurringIds = new Set<Id>();
        Map<Id, List<Id>> mapContacts = new Map<Id, List<Id>>();
        List<AcctSeed__Billing__c> billingWithRecurring = new List<AcctSeed__Billing__c>();
        List<Contacts_for_Billing__c> insertGroup = new List<Contacts_for_Billing__c>();

        for (AcctSeed__Billing__c bill : newUpdateBillings) {
            if (bill.AcctSeed__Recurring_Billing__c != null) {
                recurringIds.add(bill.AcctSeed__Recurring_Billing__c);
                billingWithRecurring.add(bill);
            }
        }

        for (Rec_Billing_Contact_Groups__c contactGroups : [
                SELECT Id, Recurring_Billing__c, Contact_group__c
                FROM Rec_Billing_Contact_Groups__c
                WHERE Recurring_Billing__c IN :recurringIds
        ]) {

            List<Id> idContact;

            if (mapContacts.containsKey(contactGroups.Recurring_Billing__c)) {

                idContact = mapContacts.get(contactGroups.Recurring_Billing__c);

            } else {

                idContact = new List<Id>();

            }

            idContact.add(contactGroups.Contact_group__c);
            mapContacts.put(contactGroups.Recurring_Billing__c, idContact);
        }

        if (mapContacts.size() > 0) {
            for (AcctSeed__Billing__c bill : billingWithRecurring) {

                for (Id contGroup : mapContacts.get(bill.AcctSeed__Recurring_Billing__c)) {
                    Contacts_for_Billing__c billInvoice = new Contacts_for_Billing__c();
                    billInvoice.Contact_group__c = contGroup;
                    billInvoice.Billing__c = bill.Id;
                    insertGroup.add(billInvoice);
                }
            }
        }

        insert insertGroup;
    }

    private static void recurringBillingInvoiceTitle(List<AcctSeed__Billing__c> newUpdateBillings) {

        Set<Id> recIds = new Set<Id>();
        Map<Id, AcctSeed__Recurring_Billing__c> recurringBillingMap = new Map<Id, AcctSeed__Recurring_Billing__c>();

        for (AcctSeed__Billing__c bill : newUpdateBillings) {

            if (bill.AcctSeed__Recurring_Billing__c != null) {
                recIds.add(bill.AcctSeed__Recurring_Billing__c);
            }
        }

        for (AcctSeed__Recurring_Billing__c recurring : [
                SELECT Id, Invoice_Title__c
                FROM AcctSeed__Recurring_Billing__c
                WHERE Id IN :recIds
        ]) {
            recurringBillingMap.put(recurring.Id, recurring);
        }

        if (recurringBillingMap.size() > 0) {
            for (AcctSeed__Billing__c bill : newUpdateBillings) {
                if (bill.AcctSeed__Recurring_Billing__c != null) {
                    bill.Name_Product__c = recurringBillingMap.get(bill.AcctSeed__Recurring_Billing__c).Invoice_Title__c;
                }
            }
        }
    }

    public with sharing class InvoiceWrapper implements Comparable {

        public String productId;
        public String revenueGLAccountId;
        public Decimal rate;
        public Integer numberBilling;
        public String description;
        public Decimal quantity;
        public Decimal totalForPage;

        public InvoiceWrapper(Integer numberBilling, String productId, Decimal rate, String description, Decimal quantity, Decimal totalForPage, String revenueGLAccountId) {
            this.numberBilling = numberBilling;
            this.productId = productId;
            this.rate = rate;
            this.description = description;
            this.quantity = quantity;
            this.totalForPage = totalForPage;
            this.revenueGLAccountId = revenueGLAccountId;
        }

        public Integer compareTo(Object compareTo) {

            InvoiceWrapper emp = (InvoiceWrapper) compareTo;
            if (numberBilling == emp.numberBilling) {
                return 0;
            } else if (numberBilling > emp.numberBilling) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public with sharing class InvoiceWrapperAfterInsert implements Comparable {

        public String productId;
        public String productName;
        public String revenueGLAccountId;
        public Decimal rate;
        public Integer numberBilling;
        public String description;
        public Decimal quantity;
        public Decimal totalForPage;

        public InvoiceWrapperAfterInsert(Integer numberBilling, String productId, Decimal rate, String description, Decimal quantity, Decimal totalForPage, String revenueGLAccountId, String productName) {
            this.numberBilling = numberBilling;
            this.productId = productId;
            this.rate = rate;
            this.description = description;
            this.quantity = quantity;
            this.totalForPage = totalForPage;
            this.revenueGLAccountId = revenueGLAccountId;
            this.productName = productName;
        }

        public Integer compareTo(Object compareTo) {

            InvoiceWrapperAfterInsert emp = (InvoiceWrapperAfterInsert) compareTo;
            if (productName == emp.productName) {
                return 0;
            } else if (productName > emp.productName) {
                return 1;
            } else {
                return -1;
            }
        }
    }

//    public static void createQueueable(List<Invoice__c> invoices, String crud) {
//
//        System.debug('createQueueable-->' + crud);
//        System.debug(invoices);
//
//        List<Invoice__c> createInvoices = new List<Invoice__c>();
//        List<Invoice__c> updateInvoices = new List<Invoice__c>();
//
//        for (Invoice__c invoice : invoices) {
//
//            //Check it, because Invoice may be the Bexio Invoice!!!!
//            if (!invoice.isFromBexio__c && crud == 'Insert') {
//                createInvoices.add(invoice);
//            }
//
//            if (crud == 'Update') {
//                System.debug('crud! Update');
//                updateInvoices.add(invoice);
//            }
//        }
//
//        Bexio_Log__c log = new Bexio_Log__c();
//        log.Type__c = 'Creating Queueable';
//        log.Description__c = 'InvoiceTrigger' + '\n';
//        log.Description__c = crud == 'Insert' ? 'Insert operation' + '\n' : 'Update operation' + '\n';
//
//        if (createInvoices.size() > 0) {
//            Int_Invoice_PUT_Queueable toCreateInvoice = new Int_Invoice_PUT_Queueable(createInvoices, 'Insert');
//            ID jobID = System.enqueueJob(toCreateInvoice);
//            log.Description__c += jobID;
//        }
//
//        if (updateInvoices.size() > 0) {
//            Int_Invoice_PUT_Queueable toCreateInvoice = new Int_Invoice_PUT_Queueable(updateInvoices, 'Update');
//            ID jobID = System.enqueueJob(toCreateInvoice);
//            log.Description__c += jobID;
//        }
//
//        insert log;
//    }

    private static void changeDescriptionAnnexInvoice(List<Invoice_Product__c> Products) {

        Set<Id> invoices = new Set<Id>();
        List<Invoice__c> updateInvoices = new List<Invoice__c>();

        for (Invoice_Product__c product : Products) {
            if (String.isNotBlank(product.Description__c)) {
                invoices.add(product.Invoice__c);
            }
        }

        for (Invoice__c invoice : [
                SELECT DescriptionAnnex__c, updateOnBexio__c
                FROM Invoice__c
                WHERE Id IN :invoices AND DescriptionAnnex__c = FALSE
        ]) {
            invoice.DescriptionAnnex__c = true;
            invoice.updateOnBexio__c = invoice.updateOnBexio__c ? false : true;
            updateInvoices.add(invoice);
        }

        if (updateInvoices.size() > 0) {
            update updateInvoices;
        }
    }

}