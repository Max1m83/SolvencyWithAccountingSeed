public with sharing class Int_Invoice_Handler implements Int_DeserializerInterface {

    public static List<Accounting_Period__c> accountings = new List<Accounting_Period__c>();

    static final Map<Integer, String> STATUS_MAP = new Map<Integer, String>{
            7 => 'Draft',
            8 => 'Pending',
            9 => 'Paid'
    };

    final static Map<Integer, String> BANK_ACCOUNT_MAP_TAX = new Map<Integer, String>{
            7 => 'CHF',
            5 => 'EUR',
            10 => 'USD',
            8 => 'GBP'
    };

    public static List<SObject> parse(String json) {

        List<Invoice__c> invoices = createInvoices((Bexio_Billing) System.JSON.deserialize(json, Bexio_Billing.class));
        upsert invoices;
        //Database.upsert(invoices, Invoice__c.Bexio_Id__c, false);

        return invoices;
    }

    private static List<Invoice__c> createInvoices(Bexio_Billing bexioBilling) {

        List<Invoice__c> returnObject = new List<Invoice__c>();

        try {

            List<Account> accounts = [SELECT Id, Bexio_Id__c, CurrencyIsoCode FROM Account WHERE Bexio_Id__c IN :getIds(bexioBilling, 'Account')];
            List<Invoice__c> existInvoices = [
                    SELECT Id, Bexio_Id__c, Bexio_Description__c, Bexio_Number_Invoice__c, Invoice__c, withBexio__c, Discount__c, Total_taxes__c,
                            isFromBexio__c, Date_Synch__c, Posting_Status__c, Bexio_Name__c, getPositions__c, With_Tax__c, Tax_percent__c, Total_gross_Bexio__c,
                            Date__c, Accounting_period_Invoice__c, Invoice_Status__c, Payable_by__c, Billing_Date__c, Account__c, Total_net_Bexio__c,
                            CurrencyIsoCode, Update_in_Bexio__c, Invoice_Title__c
                    FROM Invoice__c
                    WHERE Bexio_Id__c IN :getIds(bexioBilling, 'Invoice')
            ];
            Map<String, SObject> mapAccount = new Map<String, SObject>();
            Map<String, SObject> mapInvoice = new Map<String, SObject>();

            if (accounts.size() > 0) {
                mapAccount = Int_Utils.getSObjectMap(accounts, 'Bexio_Id__c');
            }
            if (existInvoices.size() > 0) {
                mapInvoice = Int_Utils.getSObjectMap(existInvoices, 'Bexio_Id__c');
            }

            Invoice__c invoice;

            if (mapInvoice.containsKey(bexioBilling.id)) {
                invoice = (Invoice__c) mapInvoice.get(bexioBilling.id);
            } else {
                invoice = new Invoice__c();
                invoice.Bexio_Id__c = bexioBilling.id;
            }

            invoice.Bexio_Description__c = System.JSON.serialize(bexioBilling);
            invoice.Bexio_Number_Invoice__c = bexioBilling.document_nr;
            invoice.Invoice__c = bexioBilling.document_nr;
            invoice.withBexio__c = true;
            invoice.isFromBexio__c = true;
            invoice.Date_Synch__c = Datetime.now();
            invoice.Posting_Status__c = 'Approved';
            invoice.Bexio_Name__c = bexioBilling.document_nr;
            invoice.getPositions__c = false;
            invoice.With_Tax__c = bexioBilling.taxs.size() > 0 ? true : false;
            invoice.Tax_percent__c = bexioBilling.taxs.size() > 0 ? bexioBilling.taxs.get(0).percentage : 0;
            invoice.Invoice_Status__c = STATUS_MAP.containsKey(bexioBilling.kb_item_status_id) ? STATUS_MAP.get(bexioBilling.kb_item_status_id) : 'Draft';
            invoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('After create').getRecordTypeId();
            invoice.Total_taxes__c = bexioBilling.total_taxes;
            invoice.Total_gross_Bexio__c = bexioBilling.total_gross;
            invoice.Total_net_Bexio__c = bexioBilling.total_net;

            for (Bexio_Position product : bexioBilling.positions) {
                if (product.type == 'KbPositionDiscount') {
                    //invoice.Discount__c = product.value;
                    invoice.Discount_Total_Bexio__c = product.discount_total;
                }
            }

            if (String.isNotBlank(bexioBilling.is_valid_from)) {
                try {
                    invoice.Date__c = Date.valueOf(bexioBilling.is_valid_from);
                    invoice.Accounting_period_Invoice__c = getAccountingPeriod(invoice.Date__c);
                } catch (Exception ex) {

                }
            }

            if (String.isNotBlank(bexioBilling.is_valid_to)) {
                invoice.Payable_by__c = Date.valueOf(bexioBilling.is_valid_to);
                invoice.Billing_Date__c = Date.valueOf(bexioBilling.is_valid_to);
                if (invoice.Invoice_Status__c == 'Pending' && invoice.Billing_Date__c < Date.today()) {
                    invoice.Invoice_Status__c = 'Overdue';
                }
            }

            Map<String, String> titles = invoiceTitle(bexioBilling.title);

            if (titles.size() > 0) {
                String title = Int_Utils.getPicklistValue('Invoice', 'Title', titles.get('Title'));
                if (String.isNotBlank(title)) {
                    invoice.Invoice_Title__c = title;
                }
            } else {

            }

            if (mapAccount.containsKey(bexioBilling.contact_id)) {

                Account acc = (Account) mapAccount.get(bexioBilling.contact_id);
                invoice.Account__c = acc.Id;
                invoice.CurrencyIsoCode = BANK_ACCOUNT_MAP_TAX.containsKey(bexioBilling.bank_account_id) ? BANK_ACCOUNT_MAP_TAX.get(bexioBilling.bank_account_id) : acc.CurrencyIsoCode;
                //invoice.CurrencyIsoCode = acc.CurrencyIsoCode;
            }
            invoice.Update_in_Bexio__c = Datetime.valueOf(bexioBilling.updated_at.substringBefore('+').replace('T', ' '));

            returnObject.add(invoice);

        } catch (Exception ex) {

            System.debug('Exeption');
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
        }

        return returnObject;
    }

    public static Id getAccountingPeriod(Date dateCreate) {

        Id result = null;

        if (accountings.size() == 0) {
            accountings = [SELECT Id, Start_Date__c, Status__c, End_Date__c FROM Accounting_Period__c];
        }

        for (Accounting_Period__c acc : accountings) {
            if (acc.Start_Date__c <= dateCreate && acc.End_Date__c >= dateCreate) {
                result = acc.Id;
            }
        }

        if (result == null) {
            result = createdAccountingPeriod(dateCreate);
            accountings = [SELECT Id, Start_Date__c, Status__c, End_Date__c FROM Accounting_Period__c];
        }

        return result;
    }

    public static Id createdAccountingPeriod(Date dateCreate) {

        Accounting_Period__c period = new Accounting_Period__c();
        period.Name = ((Datetime) dateCreate).format('yyyy-MM');
        period.Status__c = 'Open';
        period.Start_Date__c = dateCreate.toStartOfMonth();
        period.End_Date__c = dateCreate.addMonths(1).toStartOfMonth().addDays(-1);
        insert period;

        return period.id;
    }

    private static Map<String, String> invoiceTitle(String titleValue) {
        Map<String, String> returnValues = new Map<String, String>();
        List<String> titles = titleValue.split(' ');
        if (titles.size() > 3) {
            returnValues.put('Number', titles.get(titles.size() - 1));
            String years = titles.get(titles.size() - 2);
            returnValues.put('Years', years);
            returnValues.put('Title', titleValue.substring(0, titleValue.lastIndexOf(years) - 1));
        }
        return returnValues;
    }

    private static Set<String> getIds(Bexio_Billing bexioBilling, String nameField) {
        Set<String> returnIds = new Set<String>();

        if (bexioBilling != null) {
            if (nameField == 'Account') {
                returnIds.add(bexioBilling.contact_id);
            }
            if (nameField == 'Invoice') {
                returnIds.add(bexioBilling.id);
            }
        }
        return returnIds;
    }

    public class Bexio_Billing {
        public String id { get; set; }
        String document_nr { get; set; }
        String title { get; set; }
        String contact_id { get; set; }
//        String contact_sub_id { get; set; }
//        Integer user_id { get; set; }
//        String project_id { get; set; }
//        String pr_project_id { get; set; }
//        Integer logopaper_id { get; set; }
//        Integer language_id { get; set; }
        Integer bank_account_id { get; set; }
//        Integer currency_id { get; set; }
//        Integer payment_type_id { get; set; }
        List<Bexio_Position> positions { get; set; }
        String header { get; set; }
//        String footer { get; set; }
        Decimal total_gross { get; set; }
        Decimal total_net { get; set; }
        Decimal total_taxes { get; set; }
//        String total_received_payments { get; set; }
//        String total_credit_vouchers { get; set; }
//        String total_remaining_payments { get; set; }
//        String total { get; set; }
//        String total_rounding_difference { get; set; }
//        Integer mwst_type { get; set; }
//        String mwst_is_net { get; set; }
//        String show_position_taxes { get; set; }
        String is_valid_from { get; set; }
        String is_valid_to { get; set; }
//        String contact_address { get; set; }
        Integer kb_item_status_id { get; set; }
//        String reference { get; set; }
//        String api_reference { get; set; }
//        String viewed_by_client_at { get; set; }
        String updated_at { get; set; }
//        String esr_id { get; set; }
//        String qr_invoice_id { get; set; }
//        String template_slug { get; set; }
        List<Bexio_Taxs_Billing> taxs { get; set; }
//        String network_link { get; set; }
    }

    public class Bexio_Taxs_Billing {
        Decimal percentage { get; set; }
        String value { get; set; }
    }

    public class Bexio_Position {
        String amount { get; set; }
//        Integer unit_id { get; set; }
//        String account_id { get; set; }
//        Integer tax_id { get; set; }
        String text { get; set; }
        Decimal value { get; set; }
//        String unit_price { get; set; }
        Decimal discount_total { get; set; }
        String type { get; set; }
    }
}