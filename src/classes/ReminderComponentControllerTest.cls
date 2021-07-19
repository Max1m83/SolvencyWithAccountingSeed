/**
 * Created by max1m on 10.06.21.
 */
@isTest
public with sharing class ReminderComponentControllerTest {

    @isTest static void getEmailTest() {
        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        Int_TestCreateObject.createAttachment('TestAttachment', remainderId);
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');
        Int_TestCreateObject.createContentVersion(remainderId);
        Int_TestCreateObject.createContentVersion(invoiceId);

        Test.StartTest();
        Map<String, String> resultMap = ReminderComponentController.getEmail(remainderId);
        Test.StopTest();

        System.assertEquals('Success', resultMap.get('TemplateEmailStatus'));
    }

    @isTest static void createPDFTest() {
        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        Int_TestCreateObject.createAttachment('TestAttachment', remainderId);
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');

        Test.StartTest();
        Map<String,String> result = ReminderComponentController.createPDF(remainderId);
        System.debug(result);

        Test.StopTest();

        System.assertEquals('Success', result.get('Status'));
    }

    @isTest static void sendEmailTest() {

        List<Map<String, String>> attach = new List<Map<String, String>>();

        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 2', invoiceId, settingId);
        Int_TestCreateObject.createAttachment('TestAttachment', remainderId);
        Int_TestCreateObject.createAttachment('TestAttachment', invoiceId);
        Int_TestCreateObject.createContentVersion(remainderId);
        Int_TestCreateObject.createContentVersion(invoiceId);
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');

        for (Attachment att : [SELECT Name FROM Attachment WHERE ParentId =: invoiceId]) {

            Map<String, String> attMap = new Map<String, String>();
            attMap.put('Id', att.Id);
            attMap.put('nameFile', att.Name);
            attMap.put('file', 'Attachments');
            attMap.put('urlFile', '/servlet/servlet.FileDownload?file=' + att.Id + '&operationContext=S1');
            attach.add(attMap);
        }

        Test.StartTest();
        String result = ReminderComponentController.sendEmail(remainderId, 'Body', 'Subject', 'ccc@test.com', 'to@test.com', attach);
        Test.StopTest();

        System.assertEquals('Success', result);
    }

    @isTest static void cancelEmailTest() {

        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        Int_TestCreateObject.createAttachment('TestAttachment', remainderId);
        Int_TestCreateObject.contactBilling(conId, invoiceId, 'CC');

        Test.StartTest();
        String result = ReminderComponentController.cancelEmail(remainderId, 'Overdue');
        Test.StopTest();

        System.assertEquals('Success', result);
    }

    @isTest static void updateEmailTest() {
        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        List<Reminder_email__c> reminder = [SELECT Reminder_Stage__c FROM Reminder_email__c WHERE Id =:remainderId];

        System.assertEquals( 1, reminder.size());
        reminder.get(0).Reminder_Stage__c = 'Stage 2';

        Test.StartTest();
        update reminder;
        Test.StopTest();
        System.assertEquals( 1, reminder.size());
    }

    @isTest static void updateCancelEmailTest() {
        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        List<Reminder_email__c> reminder = [SELECT isCancel__c FROM Reminder_email__c WHERE Id =:remainderId];

        System.assertEquals( 1, reminder.size());
        reminder.get(0).Reminder_Stage__c = 'Stage 2';
        reminder.get(0).isCancel__c = true;

        Test.StartTest();
        update reminder;
        Test.StopTest();
        System.assertEquals( 1, reminder.size());
    }

    @isTest static void updateStage3EmailTest() {
        String conId = Int_TestCreateObject.createContact();
        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        String settingId = Int_TestCreateObject.createSettingsReminderEmail(10, 10, 20, 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)', 'Stage 1 (Reminder email)');
        String remainderId = Int_TestCreateObject.createReminderEmail('Reminder Name', oppAcc.get('Account'), 'Stage 1', invoiceId, settingId);
        List<Reminder_email__c> reminder = [SELECT Reminder_Stage__c FROM Reminder_email__c WHERE Id =:remainderId];

        System.assertEquals( 1, reminder.size());
        reminder.get(0).Reminder_Stage__c = 'Stage 3';

        Test.StartTest();
        update reminder;
        Test.StopTest();
        System.assertEquals( 1, reminder.size());
    }

    @isTest static void updateReminderEmailObjectsTest() {

        Map<String, String> oppAcc = Int_TestCreateObject.oppAccountCreate();
        String invoiceId = Int_TestCreateObject.createInvoices('1', oppAcc.get('Opportunity'), oppAcc.get('Account'));
        List<Invoice__c> invoices = [SELECT Invoice_Status__c FROM Invoice__c WHERE Id =:invoiceId];
        System.assertEquals( 1, invoices.size());
        invoices.get(0).Invoice_Status__c = 'Overdue';

        Test.StartTest();
        update invoices;
        Test.StopTest();

        System.assertEquals( 1, invoices.size());
    }
}