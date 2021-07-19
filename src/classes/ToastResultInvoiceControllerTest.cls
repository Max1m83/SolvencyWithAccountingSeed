/**
 * Created by max1m on 19.05.21.
 */
@isTest
public with sharing class ToastResultInvoiceControllerTest {

    @isTest
    private static void GetStatusTestPositive() {

        String batchId = Int_TestCreateObject.createBatchId('0011j000013QCv8AAG', '01t3X00000FIOFAQA5', Datetime.now().addMinutes(-3), Datetime.now());
        Int_TestCreateObject.createInvoices(new List<String>{'1','2'});

        Test.StartTest();
        Map<String, Object> mapString = ToastResultInvoiceController.GetStatus();
        Test.StopTest();

        System.assertEquals('Success', mapString.get('Status'));
    }

    @isTest
    private static void GetStatusTestNegative() {

        Test.StartTest();
        Map<String, Object> mapString = ToastResultInvoiceController.GetStatus();
        Test.StopTest();

        System.assertEquals('Error', mapString.get('Status'));
    }

    @isTest
    private static void GetStatusTestWithoutProductPositive() {

        String batchId = Int_TestCreateObject.createBatchId('0011j000013QCv8AAG', '01t3X00000FIOFAQA5', Datetime.now().addMinutes(-3), Datetime.now());
        Map<String, String> accOppMap = Int_TestCreateObject.oppAccountCreate();
        Id invoiceId = Int_TestCreateObject.createInvoices('1', accOppMap.get('Opportunity'), accOppMap.get('Account'));
        Int_TestCreateObject.createInvoicesItemsWithoutProduct('1',new List<String>{'Product'});
        Int_TestCreateObject.createInvoicesWithoutDateSynch('2',Datetime.now().addMinutes(-120));

        Test.StartTest();
        System.debug('!');
        Map<String, Object> mapString = ToastResultInvoiceController.GetStatus();
        Test.StopTest();

        System.debug(mapString);

        System.assertEquals('Success', mapString.get('Status'));
    }
}