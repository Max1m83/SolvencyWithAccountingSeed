public with sharing class Int_Invoice_Items_Handler implements Int_DeserializerInterface {

    private static String jsonClass;
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

        jsonClass = json;
        List<Invoice_Product__c> invoiceProducts = createInvoiceProducts((Bexio_Billing) System.JSON.deserialize(json, Bexio_Billing.class));
        upsert invoiceProducts;
//        Database.upsert(invoiceProducts, Invoice_Product__c.Bexio_Id__c, false);

        return invoiceProducts;
    }

    private static List<Invoice_Product__c> createInvoiceProducts(Bexio_Billing bexioBilling) {

        List<String> productNameString = new List<String>();
        Map<String, Invoice_Product__c> products = new Map<String, Invoice_Product__c>();

        List<Invoice__c> invoices = [
                SELECT Id, Rounding_difference__c, Invoice_Status__c, CurrencyIsoCode, getPositions__c, RecordTypeId, Discount__c, Total_taxes__c,
                        Total_gross_Bexio__c, Total_net_Bexio__c, Payable_by__c, Billing_Date__c,
                (SELECT Id, Product__c, Bexio_Id__c, Position__c, Invoice__c, Product_Description__c, Discount_Bexio__c,
                        Quantity__c, Unit_Price__c, CurrencyIsoCode FROM Invoice_Products__r ORDER BY Position__c ASC)
                FROM Invoice__c
                WHERE Bexio_Id__c = :bexioBilling.id
        ];

        List<Invoice_Product__c> returnList = new List<Invoice_Product__c>();
        Bexio_Log__c log = new Bexio_Log__c();
        log.Type__c = 'Bexio Product-->' + bexioBilling.id;
        log.Description__c += bexioBilling + '\n';
        insert log;

        if (bexioBilling != null && invoices.size() > 0) {

            Invoice__c invoice = invoices.get(0);

            Decimal discount = 0;
            Integer count = 0;
            Map<Id, Invoice_Product__c> deleteProducts = new Map<Id, Invoice_Product__c> (invoice.Invoice_Products__r);

            invoice.CurrencyIsoCode = BANK_ACCOUNT_MAP_TAX.containsKey(bexioBilling.bank_account_id) ? BANK_ACCOUNT_MAP_TAX.get(bexioBilling.bank_account_id) : 'CHF';

            for (Bexio_Billing_Product product : bexioBilling.positions) {

                if (product.type == 'KbPositionCustom' || product.type == 'KbPositionArticle' || product.type == 'KbPositionMonitoring') {

                    try {
                        Boolean isNotExistProduct = true;
                        Invoice_Product__c invoiceProduct;

                        for (Invoice_Product__c prod : invoice.Invoice_Products__r) {
                            if (product.id == prod.Bexio_Id__c) {
                                isNotExistProduct = false;
                                invoiceProduct = prod;
                                products.put(product.text, invoiceProduct);
                                productNameString.add(product.text);
                            }
                        }

                        if (isNotExistProduct) {
                            invoiceProduct = new Invoice_Product__c();
                            invoiceProduct.Bexio_Id__c = product.id;
                            log.Description__c += 'Bexio_Id__c = ' + product.id + '\n';
                            invoiceProduct.Invoice__c = invoice.Id;
                            invoiceProduct.Product_Description__c = product.text;
                            productNameString.add(product.text);
                            products.put(product.text, invoiceProduct);
                            log.Description__c += 'Product_Description = ' + product.text + '\n';
                        }

                        invoiceProduct.Position__c = product.pos;
                        invoiceProduct.Date_Synch__c = Datetime.now();
                        invoiceProduct.Response__c = product.toString();
                        log.Description__c += 'Position = ' + product.pos + '\n';
                        invoiceProduct.Discount_Bexio__c = product.discount_in_percent != null ? Decimal.valueOf(product.discount_in_percent) : null;
                        log.Description__c += 'Discount_Bexio = ' + invoiceProduct.Discount_Bexio__c + '\n';
                        invoiceProduct.Quantity__c = Decimal.valueOf(product.amount);
                        log.Description__c += 'Quantity = ' + product.pos + '\n';
                        invoiceProduct.Unit_Price__c = Decimal.valueOf(product.unit_price);
                        log.Description__c += 'Unit_Price__c = ' + product.unit_price + '\n';
                        invoiceProduct.CurrencyIsoCode = invoice.CurrencyIsoCode;
                        discount += invoiceProduct.Discount_Bexio__c != null ? invoiceProduct.Discount_Bexio__c : 0;
                        count++;
                        update log;
                        returnList.add(invoiceProduct);
                    } catch (Exception ex) {

                        System.debug(ex.getMessage());
                        System.debug(ex.getLineNumber());
                        System.debug('Exeption');
                        log.Description__c += 'ERROR getMessage = ' + ex.getMessage() + '\n';
                        log.Description__c += 'ERROR getLineNumber = ' + ex.getLineNumber() + '\n';
                        update log;
                    }
                } else if (product.type == 'KbPositionDiscount') {
                    //invoice.Discount__c = product.value;
                    invoice.Discount_Total_Bexio__c = product.discount_total;
                }
            }

            for (Invoice_Product__c prod: returnList) {
                deleteProducts.remove(prod.Id);
            }
            delete deleteProducts.values();

            invoice.getPositions__c = true;
            invoice.Bexio_Log__c = log.Id;
            invoice.Invoice_Status__c = STATUS_MAP.containsKey(bexioBilling.kb_item_status_id) ? STATUS_MAP.get(bexioBilling.kb_item_status_id) : 'Draft';
            invoice.Bexio_Description__c = jsonClass;
            invoice.Date_Synch__c = Datetime.now();
            invoice.RecordTypeId = Invoice__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('After create').getRecordTypeId();
            invoice.Rounding_difference__c = bexioBilling.total_rounding_difference;
            invoice.Total_taxes__c = bexioBilling.total_taxes;
            invoice.Total_gross_Bexio__c = bexioBilling.total_gross;
            invoice.Total_net_Bexio__c = bexioBilling.total_net;

            List<Product2> productsExist = [SELECT Id, Name FROM Product2 WHERE Name = :productNameString];

            for (Product2 prod : productsExist) {

                if (products.containsKey((prod.Name))) {
                    Invoice_Product__c invoicePr = products.get(prod.Name);
                    if (invoicePr.Product__c == null && invoicePr != null) {
                        invoicePr.Product__c = prod.Id;
                    }
                }
            }

            if (String.isNotBlank(bexioBilling.is_valid_to)) {
                invoice.Payable_by__c = Date.valueOf(bexioBilling.is_valid_to);
                invoice.Billing_Date__c = Date.valueOf(bexioBilling.is_valid_to);

                if (invoice.Invoice_Status__c == 'Pending' && invoice.Billing_Date__c < Date.today()) {
                    invoice.Invoice_Status__c = 'Overdue';
                }
            }


            update invoice;
        }
        return returnList;
    }

    public class Bexio_Billing {
        String id { get; set; }
        Decimal total_rounding_difference { get; set; }
        List<Bexio_Billing_Product> positions { get; set; }
        Integer bank_account_id { get; set; }
        Integer kb_item_status_id { get; set; }
        Decimal total_gross { get; set; }
        Decimal total_net { get; set; }
        Decimal total_taxes { get; set; }
        String is_valid_to { get; set; }
    }

    public class Bexio_Billing_Product {
        String id { get; set; }
        String type { get; set; }
        String amount { get; set; }
        Decimal discount_total { get; set; }

//        String account_id { get; set; }
//        String unit_name { get; set; }
//        String tax_id { get; set; }
//        String tax_value { get; set; }
        String text { get; set; }
        String unit_price { get; set; }
        String discount_in_percent { get; set; }
        Decimal value { get; set; }
        Decimal pos { get; set; }
//        String internal_pos { get; set; }
//        String parent_id { get; set; }
//        String is_optional { get; set; }
    }
}