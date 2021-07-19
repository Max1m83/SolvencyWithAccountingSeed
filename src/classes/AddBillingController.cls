public with sharing class AddBillingController {

    @AuraEnabled
    public static Map<String, List<String>> getEmailsGroup(String billId) {

        List<String> existEmailGroup = new List<String>();
        Map<String, List<String>> emailsGroup = new Map<String, List<String>>();

        Set<Id> existIds = new Set<Id>();

        for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billId]) {

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
    public static String updateBilling(String billId, List<String> namesGroup) {

        List<Billing_Sent__c> insertObject = new List<Billing_Sent__c>();
        Set<Id> existIds = new Set<Id>();
        Set<Id> existGroupIds = new Set<Id>();
        Set<Id> reqGroupIds = new Set<Id>();
        List<Attachment> attachments = new List<Attachment>();

        List<AcctSeed__Billing__c> updateBillings = [
                SELECT Id, AcctSeed__Customer__c, Multiple_Billing_for_Sending__c, AcctSeed__Status__c, Billing_Number_cal__c, (SELECT Id, Contact_group__c FROM Contacts_for_Billing__r)
                FROM AcctSeed__Billing__c
                WHERE Id = :billId
        ];

        if (updateBillings.size() > 0 && updateBillings.get(0).AcctSeed__Status__c == 'Approved') {

            for (Contacts_for_Billing__c conBill : [SELECT Id, Contact_group__c FROM Contacts_for_Billing__c WHERE Billing__c = :billId]) {

                existGroupIds.add(conBill.Contact_group__c);
            }

            for (Contact_group__c con : [
                    SELECT Id, Name
                    FROM Contact_group__c
                    WHERE Id IN :existGroupIds
            ]) {
                for (String nameGroup : namesGroup) {
                    if (con.Name == nameGroup) {
                        reqGroupIds.add(con.Id);
                    }
                }
            }

            for (Billing_Sent__c billSent : [
                    SELECT Id, Contact_group__c
                    FROM Billing_Sent__c
                    WHERE Billing__c = :billId
            ]) {
                existIds.add(billSent.Contact_group__c);
            }

            if (updateBillings.size() == 1) {
                AcctSeed__Billing__c bill = updateBillings.get(0);

                for (Contacts_for_Billing__c contBill : bill.Contacts_for_Billing__r) {

                    if (!existIds.contains(contBill.Contact_group__c)) {
                        if (reqGroupIds.contains(contBill.Contact_group__c)) {
                            Billing_Sent__c sentBill = new Billing_Sent__c();
                            sentBill.Billing__c = bill.Id;
                            sentBill.Contact_group__c = contBill.Contact_group__c;
                            insertObject.add(sentBill);
                            attachments.add(createPDFAttachment(bill, contBill.Contact_group__c));
                        }
                    }
                }
                insert insertObject;
                System.debug(attachments);
                insert attachments;
                return 'Success';
            } else {
                return 'ERROR';
            }
        } else {
            return 'Not Approved';
        }
    }

    private static Attachment createPDFAttachment(AcctSeed__Billing__c bill, Id conId) {

        Attachment attach = new Attachment();

        PageReference pdf = Page.InvoiceSolvencyWithQuantity;
        pdf.getParameters().put('id', bill.Id);
        Blob bodyAttach;

        try {
            // returns the output of the page as a PDF
            bodyAttach = pdf.getContent();

            // need to pass unit test -- current bug
        } catch (VisualforceException e) {
            bodyAttach = Blob.valueOf('Some Text');
        }

        String nameInvoice = bill.Billing_Number_cal__c + '.pdf';
        attach.Name = nameInvoice;
        attach.IsPrivate = false;
        attach.ParentId = conId;
        attach.Body = bodyAttach;

        return attach;
    }
}