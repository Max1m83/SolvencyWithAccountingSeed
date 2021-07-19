/**
 * Created by max1m on 07.05.21.
 */

public with sharing class Int_Invoice_Amount_Handler implements Int_DeserializerInterface {

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

        List<Invoice_Product__c> invoiceProducts = createInvoiceProducts((Bexio_Billing) System.JSON.deserialize(json, Bexio_Billing.class));
        upsert invoiceProducts;

        return invoiceProducts;
    }

    private static List<Invoice_Product__c> createInvoiceProducts(Bexio_Billing bexioBilling) {

        List<Invoice_Product__c> returnList = new List<Invoice_Product__c>();
        List<String> productNameString = new List<String>();
        Map<String, Invoice_Product__c> products = new Map<String, Invoice_Product__c>();

        List<Invoice__c> invoices = [
                SELECT Id, Discount__c, CurrencyIsoCode, getPositions__c, Bexio_Description__c, Invoice__c, withBexio__c, isFromBexio__c, Date_Synch__c,
                        Posting_Status__c, PDF_Email_Status__c, Bexio_Name__c, Total_taxes__c, Total_gross_Bexio__c, Total_net_Bexio__c, Discount_Total_Bexio__c,
                        With_Tax__c, Tax_percent__c, Invoice_Status__c, Date__c, Accounting_period_Invoice__c, Payable_by__c, Billing_Date__c, (
                        SELECT Id, Bexio_Id__c, Product__c, Position__c, Invoice__c, Product_Description__c, Discount_Bexio__c, Quantity__c, Unit_Price__c,
                                CurrencyIsoCode
                        FROM Invoice_Products__r
                        ORDER BY Position__c ASC
                )
                FROM Invoice__c
                WHERE Bexio_Id__c = :bexioBilling.id
        ];

        Invoice__c upsertInvoice;

        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Product-->' + bexioBilling.id;

        if (invoices.size() > 0) {
            upsertInvoice = invoices.get(0);
            log.Description__c += 'Exist Billing#' + invoices.get(0).Id + '\n';
        } else {
            upsertInvoice = new Invoice__c();
            upsertInvoice.Bexio_Id__c = bexioBilling.id;
            //upsertInvoice.Posting_Status__c = 'Approved';
            upsertInvoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('After create').getRecordTypeId();

            log.Description__c += 'New Billing#' + bexioBilling.id + '\n';
        }

        log.Description__c += bexioBilling + '\n';
        insert log;

        upsertInvoice = fillInvoice(upsertInvoice, bexioBilling);

        for (Bexio_Billing_Product product : bexioBilling.positions) {

            if (product.type == 'KbPositionDiscount') {
                //upsertInvoice.Discount__c = product.value;
//                if (product.is_percentual) {
//
//                    upsertInvoice.Discount_Total_Bexio__c = product.discount_total;
//
//                } else {
//
//                }
                upsertInvoice.Discount_Total_Bexio__c = product.discount_total;
            }
        }

        upsert upsertInvoice;

        if (bexioBilling != null && invoices.size() > 0) {

            Map<Id, Invoice_Product__c> deleteProducts = new Map<Id, Invoice_Product__c> (upsertInvoice.Invoice_Products__r);
            for (Bexio_Billing_Product product : bexioBilling.positions) {

                if (product.type == 'KbPositionCustom' || product.type == 'KbPositionArticle' || product.type == 'KbPositionMonitoring') {

                    try {
                        Boolean isNotExistProduct = true;
                        Invoice_Product__c invoiceProduct;

                        for (Invoice_Product__c prod : upsertInvoice.Invoice_Products__r) {
                            if (product.id == prod.Bexio_Id__c) {
                                isNotExistProduct = false;
                                deleteProducts.remove(prod.Id);
                                invoiceProduct = prod;
                            }
                        }

                        if (isNotExistProduct) {
                            invoiceProduct = new Invoice_Product__c();
                            invoiceProduct.Bexio_Id__c = product.id;
                            log.Description__c += 'Bexio_Id__c = ' + product.id + '\n';
                            invoiceProduct.Invoice__c = upsertInvoice.Id;
                            invoiceProduct.Product_Description__c = product.text;
//                            productNameString.add(product.text);
//                            products.put(product.text, invoiceProduct);
                            log.Description__c += 'Product_Description = ' + product.text + '\n';
                        }

                        productNameString.add(product.text);
                        products.put(product.text, invoiceProduct);
                        invoiceProduct.Position__c = product.pos;
                        log.Description__c += 'Position = ' + product.pos + '\n';
                        invoiceProduct.Discount_Bexio__c = product.discount_in_percent != null ? Decimal.valueOf(product.discount_in_percent) : null;
                        log.Description__c += 'Discount_Bexio = ' + invoiceProduct.Discount_Bexio__c + '\n';
                        invoiceProduct.Quantity__c = Decimal.valueOf(product.amount);
                        log.Description__c += 'Quantity = ' + product.pos + '\n';
                        invoiceProduct.Unit_Price__c = Decimal.valueOf(product.unit_price);
                        log.Description__c += 'Unit_Price__c = ' + product.unit_price + '\n';
                        invoiceProduct.CurrencyIsoCode = upsertInvoice.CurrencyIsoCode;
                        //discount = invoiceProduct.Discount_Bexio__c;
                        update log;
                        returnList.add(invoiceProduct);
                    } catch (Exception ex) {
                        update log;
                    }
                }
            }

            delete deleteProducts.values();

            List<Product2> productsExist = [SELECT Id, Name FROM Product2 WHERE Name = :productNameString];

            for (Product2 prod : productsExist) {

                Invoice_Product__c invoicePr = products.get(prod.Name);
                if (invoicePr.Product__c == null && invoicePr != null) {
                    invoicePr.Product__c = prod.Id;
                }
            }
        }
        return returnList;
    }

    private static Invoice__c fillInvoice(Invoice__c upsertInvoice, Bexio_Billing bexioBilling) {

        upsertInvoice.Bexio_Description__c = System.JSON.serialize(bexioBilling);
        upsertInvoice.Invoice__c = bexioBilling.document_nr;
        upsertInvoice.withBexio__c = true;
        upsertInvoice.isFromBexio__c = true;
        upsertInvoice.Date_Synch__c = Datetime.now();
        upsertInvoice.Bexio_Name__c = bexioBilling.document_nr;
        upsertInvoice.With_Tax__c = bexioBilling.taxs.size() > 0 ? true : false;
        upsertInvoice.Tax_percent__c = bexioBilling.taxs.size() > 0 ? bexioBilling.taxs.get(0).percentage : 0;
        upsertInvoice.Invoice_Status__c = STATUS_MAP.containsKey(bexioBilling.kb_item_status_id) ? STATUS_MAP.get(bexioBilling.kb_item_status_id) : 'Draft';
        upsertInvoice.Rounding_difference__c = bexioBilling.total_rounding_difference;
        upsertInvoice.Total_taxes__c = bexioBilling.total_taxes;
        upsertInvoice.Total_gross_Bexio__c = bexioBilling.total_gross;
        upsertInvoice.Total_net_Bexio__c = bexioBilling.total_net;

        for (Bexio_Billing_Product product : bexioBilling.positions) {

            if (product.type == 'KbPositionDiscount') {
                //upsertInvoice.Discount__c = product.value;
                upsertInvoice.Discount_Total_Bexio__c = product.discount_total;
            }
        }

        if (String.isNotBlank(bexioBilling.is_valid_from)) {
            try {

                upsertInvoice.Date__c = Date.valueOf(bexioBilling.is_valid_from);
                upsertInvoice.Accounting_period_Invoice__c = getAccountingPeriod(upsertInvoice.Date__c);

            } catch (Exception ex) {
                Bexio_Log__c log = new Bexio_Log__c();
                log.Type__c = 'Bexio Product-->' + bexioBilling.id;
                log.Description__c += 'Exception = ' + ex + '\n';
                insert log;
            }
        }

        if (String.isNotBlank(bexioBilling.is_valid_to)) {
            upsertInvoice.Payable_by__c = Date.valueOf(bexioBilling.is_valid_to);
            upsertInvoice.Billing_Date__c = Date.valueOf(bexioBilling.is_valid_to);

            if (upsertInvoice.Invoice_Status__c == 'Pending' && upsertInvoice.Billing_Date__c < Date.today()) {
                upsertInvoice.Invoice_Status__c = 'Overdue';
            }
        }

        upsertInvoice.CurrencyIsoCode = BANK_ACCOUNT_MAP_TAX.containsKey(bexioBilling.bank_account_id) ? BANK_ACCOUNT_MAP_TAX.get(bexioBilling.bank_account_id) : 'CHF';
        upsertInvoice.Update_in_Bexio__c = Datetime.valueOf(bexioBilling.updated_at.substringBefore('+').replace('T', ' '));
        upsertInvoice.Date_Synch__c = upsertInvoice.Update_in_Bexio__c;

        return upsertInvoice;
    }

    public static Id getAccountingPeriod(Date dateCreate) {

        List<Accounting_Period__c> accs = [SELECT Id, Start_Date__c, Status__c, End_Date__c FROM Accounting_Period__c];

        Id result = null;


        for (Accounting_Period__c acc : accs) {
            if (acc.Start_Date__c <= dateCreate && acc.End_Date__c >= dateCreate) {
                result = acc.Id;
            }
        }

        if (result == null) {
            result = createdAccountingPeriod(dateCreate);
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

    public class Bexio_Billing {
        String id { get; set; }
        String document_nr { get; set; }
        String title { get; set; }
        String contact_id { get; set; }
        Integer bank_account_id { get; set; }
        List<Bexio_Billing_Product> positions { get; set; }
        //String header { get; set; }
        Decimal total_rounding_difference { get; set; }
        String is_valid_from { get; set; }
        String is_valid_to { get; set; }
        Integer kb_item_status_id { get; set; }
        String updated_at { get; set; }
        List<Bexio_Taxs_Billing> taxs { get; set; }
        Decimal total_gross { get; set; }
        Decimal total_net { get; set; }
        Decimal total_taxes { get; set; }
    }

    public class Bexio_Billing_Product {
        String id { get; set; }
        Decimal discount_total { get; set; }
        String type { get; set; }
        //Boolean is_percentual { get; set; }
        String amount { get; set; }
        String text { get; set; }
        String unit_price { get; set; }
        String discount_in_percent { get; set; }
        Decimal pos { get; set; }
        Decimal value { get; set; }
    }
    public class Bexio_Taxs_Billing {
        Decimal percentage { get; set; }
        String value { get; set; }
    }
}