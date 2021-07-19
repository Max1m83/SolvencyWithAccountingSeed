public with sharing class Int_Payment_Handler implements Int_DeserializerInterface {

    public static List<SObject> parse(String json) {

        List<Payment__c> payments = createPayments((List<BexioPayment>) System.JSON.deserialize(json.replaceAll('currency', 'currencyPay'), List<BexioPayment>.class));

        if (payments.size() > 0) {

        }

        Database.upsert(payments, Payment__c.Bexio_Id__c, false);

        return payments;
    }

    private static List<Payment__c> createPayments(List<BexioPayment> bexioPayments) {

        List<Payment__c> returnObject = new List<Payment__c>();
        Map<String, Account> existAccount = getAccounts(bexioPayments);

        for (BexioPayment bexioObject : bexioPayments) {

            Payment__c payment = new Payment__c();
            payment.Bexio_Id__c = bexioObject.Id;
            payment.Amount__c = bexioObject.payment.instructed_amount.amount;
            payment.CurrencyIsoCode = picklistValuesCurrency(bexioObject.payment.instructed_amount.currencyPay);
            payment.Created_at__c = Datetime.valueOf(bexioObject.created_at.substringBefore('+').replace('T', ' '));
            payment.Status__c = picklistValuesStatus(bexioObject.status);
            if (bexioObject.payment != null &&
                    bexioObject.payment.recipient != null &&
                    bexioObject.payment.recipient.name != null &&
                    existAccount.size() > 0 &&
                    existAccount.containsKey(bexioObject.payment.recipient.name)) {
                System.debug('Account--->' + existAccount.get(bexioObject.payment.recipient.name));
                payment.Account__c = existAccount.get(bexioObject.payment.recipient.name).Id;
            }

            returnObject.add(payment);
        }

        return returnObject;
    }

    private static String picklistValuesCurrency(String value) {
        if (value != 'CHF' && value != 'EUR' && value != 'USD' && value != 'GBP') {

            System.debug('Currency!!! ----> ' + value);
            return 'CHF';
        } else {
            return value;
        }
    }

    private static Map<String, SObject> getInvoices(List<BexioPayment> bexioPayments) {

        List<String> bexioIdInvoices = new List<String> ();

        for (BexioPayment bexioObject : bexioPayments) {
            if (bexioObject.payment != null) {
                if (bexioObject.payment.bill_id != null) {
                    bexioIdInvoices.add(bexioObject.payment.bill_id);
                }
            }
        }

        return Int_Utils.getSObjectMap([SELECT Id, In_Bexio__c FROM Invoice__c WHERE In_Bexio__c IN :bexioIdInvoices], 'In_Bexio__c');
    }

    private static Map<String, Account> getAccounts(List<BexioPayment> bexioPayments) {

        Map<String, Account> existAccounts = new Map<String, Account>();
        Set<String> bexioNameAccounts = new Set<String>();

        for (BexioPayment bexioObject : bexioPayments) {
            if (bexioObject.payment != null &&
                    bexioObject.payment.recipient != null &&
                    bexioObject.payment.recipient.name != null) {
                bexioNameAccounts.add(bexioObject.payment.recipient.name);
            }
        }

        for (Account acc : [
                SELECT Id, Name, BillingAddress
                FROM Account
                WHERE Name IN :bexioNameAccounts
        ]) {
            existAccounts.put(acc.Name, acc);
        }

        return existAccounts;
    }


    private static String picklistValuesStatus(String value) {

        List<Schema.PicklistEntry> statusValue = Payment__c.fields.Status__c.getDescribe().getPickListValues();
        Boolean isExist = false;

        for (Schema.PicklistEntry st : statusValue) {
            if (st.value == value) {
                isExist = true;
            }
        }

        if (isExist) {
            return value;
        } else {
            System.debug(value);
            return 'Cancelled';
        }
    }

    public class BexioPayment {
        String Id { get; set; }
        String uuid { get; set; }
        String type { get; set; }
        BexioBankAccount bank_account { get; set; }
        BexioPaymentDescription payment { get; set; }
        String instruction_id { get; set; }
        String status { get; set; }
        String created_at { get; set; }
    }

    public class BexioBankAccount {
        String Id { get; set; }
        String iban { get; set; }
    }

    public class BexioPaymentDescription {
        BexioPaymentAmount instructed_amount { get; set; }
        BexioPaymentRecipient recipient { get; set; }
        String execution_date { get; set; }
        Boolean is_editing_restricted { get; set; }
        String bill_id { get; set; }
        String account_number { get; set; }
        String isr_reference_nr { get; set; }
    }

    public class BexioPaymentAmount {
        String currencyPay { get; set; }
        Decimal amount { get; set; }
    }

    public class BexioPaymentRecipient {
        String name { get; set; }
        String street { get; set; }
        String house_number { get; set; }
        String zip { get; set; }
        String city { get; set; }
        String country_code { get; set; }
    }
}