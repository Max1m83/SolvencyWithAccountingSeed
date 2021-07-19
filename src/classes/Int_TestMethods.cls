@isTest
private with sharing class Int_TestMethods {

//    @isTest static void GetPayment() {
//        //Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('payment', 'Get'));
//
//    }

    @isTest static void GetInvoices() {
        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('invoice', 'Get', 'Success'));
        Test.startTest();
        List<Invoice__c> invoices = Int_RequestHelper.getInvoices(0, 200);
        Test.stopTest();
        System.debug(invoices);
    }

//    @isTest static void GetInvoiceProducts() {
//        Test.setMock(HttpCalloutMock.class, new Int_CalloutMock('invoice Product', 'Get', 'Success'));
//        Test.startTest();
//        List<Invoice__c> invoices = Int_RequestHelper.getInvoices(0, 200);
//        Test.stopTest();
//        System.debug(invoices);
//    }

    @isTest static void TestPayment() {

        String json = '{"id":1,"document_nr":"RE-00001","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","contact_id":2,"contact_sub_id":null,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":1,"currency_id":3,"payment_type_id":4,"header":"","footer":"","total_gross":"1000.000000","total_net":"1000.000000","total_taxes":"0.0000","total_received_payments":"1000.000000","total_credit_vouchers":"0.000000","total_remaining_payments":"0.0000","total":"1000.000000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"show_position_taxes":false,"is_valid_from":"2021-02-24","is_valid_to":"2021-03-25","contact_address":"","kb_item_status_id":9,"reference":null,"api_reference":null,"viewed_by_client_at":null,"updated_at":"2021-02-24 15:57:29","esr_id":1,"qr_invoice_id":1,"template_slug":"60365b8a81a24a1026294494","taxs":[],"positions":[{"id":1,"type":"KbPositionCustom","amount":"4.000000","unit_id":null,"account_id":101,"unit_name":null,"tax_id":16,"tax_value":"7.70","text":"","unit_price":"250.000000","discount_in_percent":null,"position_total":"1000.000000","pos":"1","internal_pos":1,"parent_id":null,"is_optional":false}],"network_link":""}';

        List<SObject> returnObject = Int_Invoice_Items_Handler.parse(json);

        List<Accounting_Period__c> periods = [SELECT Id FROM Accounting_Period__c WHERE Name = '2021-03'];

        List<Invoice__c> updateInvoices = new List<Invoice__c>();

        date myDateStart = date.newInstance(2021, 03, 01);
        date myDateFinish = date.newInstance(2021, 03, 31);

        for (Invoice__c invoice : [SELECT Id, Date__c, Accounting_period_Invoice__c FROM Invoice__c
        WHERE Accounting_period_Invoice__c = null
        AND Date__c > :myDateStart AND Date__c < :myDateFinish]) {
            if (periods.size() > 0) {
                invoice.Accounting_period_Invoice__c = periods.get(0).Id;
            } else {
                System.debug('NO');
            }
            updateInvoices.add(invoice);

        }

        System.debug('updateInvoices+--->' + updateInvoices.size());

        update updateInvoices;
    }
}