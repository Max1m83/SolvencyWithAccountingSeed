/**
 * Created by max1m on 16.03.21.
 */

public with sharing class Int_PUT_Invoice_Handler {

    final static Map<String, Integer> CURRENCY_MAP = new Map<String, Integer>{
            'CHF' => 1,
            'EUR' => 2,
            'USD' => 3,
            'GBP' => 4
    };

    final static Map<String, Integer> BANK_ACCOUNT_MAP_TAX = new Map<String, Integer>{
            'CHF' => 7,
            'EUR' => 5,
            'USD' => 10,
            'GBP' => 8
    };

    public static String putRequestInvoice(Invoice__c bill) {

        Bexio_Billing billing = new Bexio_Billing();

        List<Invoice__c> invoices = [
                SELECT Account__c, Opportunity__c, Invoice_Title__c, Accounting_period__c, isTax__c, Discount__c,
                        OwnerId, With_Tax__c, Date__c, Billing_Date__c, CurrencyIsoCode, (
                        SELECT Id, Unit_Price__c, Total__c, Quantity__c,Bexio_Id__c, Product__r.Name, Position__c, Discount__c, Discount_Bexio__c, Description__c
                        FROM Invoice_Products__r
                        ORDER BY Position__c ASC
                )
                FROM Invoice__c
                WHERE Id = :bill.Id
        ];

        if (invoices.size() > 0) {

            Invoice__c invoice = invoices.get(0);

            List<Account> accounts = [
                    SELECT Bexio_Id__c,CurrencyIsoCode
                    FROM Account
                    WHERE Id = :invoice.Account__c
            ];

            List<Opportunity> opportunities = [
                    SELECT CurrencyIsoCode
                    FROM Opportunity
                    WHERE Id = :invoice.Opportunity__c
            ];

            if (accounts.size() > 0 && opportunities.size() > 0 && String.isNotBlank(accounts.get(0).Bexio_Id__c)) {

                //Edit Title!;
                billing.titleBexio = createTitleInvoice(invoice);
                billing.titleBexio = String.isNotBlank(billing.titleBexio) ? billing.titleBexio : 'null';
                billing.contact_id = accounts.get(0).Bexio_Id__c;
                billing.contact_sub_id = null;
                billing.user_id = findOwnerNumber(invoice);
                billing.pr_project_id = null;
                billing.language_id = 4;

                //Need callout to the Bank Account
                billing.bank_account_id = BANK_ACCOUNT_MAP_TAX.get(opportunities.get(0).CurrencyIsoCode);
                //billing.bank_account_id = 1; 

                billing.currency_id = CURRENCY_MAP.get(opportunities.get(0).CurrencyIsoCode);
                billing.payment_type_id = 1;
                billing.header = '';
                billing.header = '';
                billing.mwst_type = invoice.isTax__c ? 0 : 2;

                //Check ithis value affects the total if the field mwst_type has been set to 0.
                //false = Taxes are included in the total
                //true = Taxes will be added to the total
                billing.mwst_is_net = 'true';

                billing.show_position_taxes = 'false';

                //billing.is_valid_from = (Datetime.now()).format('YY-MM-dd');
                billing.is_valid_from = ((Datetime) invoice.Date__c).format('YY-MM-dd');
                billing.is_valid_to = ((Datetime) invoice.Billing_Date__c).format('YY-MM-dd');
                billing.reference = null;
                billing.api_reference = null;

                List<Bexio_Position> bexioProduct = new List<Bexio_Position>();
                Integer step = 1;

                List<Map<String, Object>> positions = new List<Map<String, Object>>();

                for (Invoice_Product__c product : invoice.Invoice_Products__r) {

                    Map<String, Object> pos = new Map<String, Object>();
                    pos.put('amount', String.valueOf(product.Quantity__c));
                    pos.put('unit_id', null);
                    pos.put('account_id', null);
                    pos.put('tax_id', 16);
                    pos.put('text', String.valueOf(product.Product__r.Name));
                    pos.put('unit_price', String.valueOf(product.Unit_Price__c));
                    pos.put('discount_in_percent', product.Discount_Bexio__c > 0 ? String.valueOf(product.Discount_Bexio__c) : '0.00');
                    pos.put('type', 'KbPositionCustom');
                    positions.add(pos);

                    if (String.isNotBlank(product.Description__c)) {
                        Map<String, Object> posDescription = new Map<String, Object>();
                        posDescription.put('text', product.Description__c);
                        posDescription.put('show_pos_nr', false);
                        posDescription.put('type', 'KbPositionText');
                        //posDescription.put('parent_id', null);
                        positions.add(posDescription);
                    }


//                    Bexio_Position position = new Bexio_Position();
//                    position.amount = String.valueOf(product.Quantity__c);
//                    position.unit_id = null;
//                    position.account_id = null;
//                    position.tax_id = 16;
//                    position.text = String.valueOf(product.Product__r.Name);
//                    //position.unit_price = String.valueOf(product.Unit_Price__c);
//                    position.unit_price = '0.00';
//                    position.discount_in_percent = String.valueOf(product.Discount_Bexio__c);
//                    position.type = 'KbPositionCustom';
//                    bexioProduct.add(position);
//                    step++;
                }

                if (invoice.Discount__c > 0) {
                    Map<String, Object> pos = new Map<String, Object>();

                    pos.put('text', 'Discount');
                    pos.put('is_percentual', true);
                    pos.put('value', String.valueOf(invoice.Discount__c));
                    pos.put('type', 'KbPositionDiscount');
                    positions.add(pos);

//                    Bexio_Position position = new Bexio_Position();
//                    position.text = 'Discount';
//                    position.discount_in_percent = String.valueOf(invoice.Discount__c);
//                    position.type = 'KbPositionDiscount';
//                    bexioProduct.add(position);
                }

                //billing.positions = bexioProduct;
                billing.positions = positions;
            }
        }

        return System.JSON.serialize(billing).replaceAll('titleBexio', 'title');
    }

    public static String invoiceUpdateSearch(String dateSearch) {

        List<Bexio_Billing_Search> invoices = new List<Bexio_Billing_Search>();

        Bexio_Billing_Search invoice = new Bexio_Billing_Search();
        invoice.field = 'updated_at';
        invoice.value = dateSearch;
        invoice.criteria = '>=';
        invoices.add(invoice);

        return System.JSON.serialize(invoices);
    }

    private static String createTitleInvoice(Invoice__c invoice) {

        return (String.isNotBlank(invoice.Invoice_Title__c) ? invoice.Invoice_Title__c + ' ' : '')
                + (String.isNotBlank(invoice.Accounting_period__c) ? '(' + invoice.Accounting_period__c + ')' : '');

    }

    private static Integer findOwnerNumber(Invoice__c invoice) {

        Integer resultId;

        List<Bexio_Owners__c> owners = [SELECT Bexio_Id__c, User__c FROM Bexio_Owners__c WHERE User__c = :invoice.OwnerId];

        if (owners.size() > 0) {
            resultId = Integer.valueOf(owners.get(0).Bexio_Id__c);
        } else {
            resultId = 1;
        }

        return resultId;
    }

//    private static Set<String> getIds(List<Bexio_Billing> bexioBilling, String nameField) {
//        Set<String> returnIds = new Set<String>();
//
//        for (Bexio_Billing bexioObject : bexioBilling) {
//            if (nameField == 'Account') {
//                returnIds.add(bexioObject.contact_id);
//            }
//            if (nameField == 'Invoice') {
//                returnIds.add(bexioObject.id);
//            }
//        }
//        return returnIds;
//    }

    public class Bexio_Billing {
        String id { get; set; }
        String titleBexio { get; set; }
        String contact_id { get; set; }
        String contact_sub_id { get; set; }
        Integer user_id { get; set; }
        String pr_project_id { get; set; }
        Integer logopaper_id { get; set; }
        Integer language_id { get; set; }
        Integer bank_account_id { get; set; }
        Integer currency_id { get; set; }
        Integer payment_type_id { get; set; }
        List<Map<String, Object>> positions { get; set; }
        String header { get; set; }
        Integer mwst_type { get; set; }
        String mwst_is_net { get; set; }
        String show_position_taxes { get; set; }
        String is_valid_from { get; set; }
        String is_valid_to { get; set; }
        String reference { get; set; }
        String api_reference { get; set; }
    }

    public class Bexio_Position_Discount {

    }

    public class Bexio_Position {
        String amount { get; set; }
        Integer unit_id { get; set; }
        String account_id { get; set; }
        Integer tax_id { get; set; }
        String text { get; set; }
        String unit_price { get; set; }
        String discount_in_percent { get; set; }
        String type { get; set; }
        //String is_percentual { get; set; }
    }

    public class Bexio_Billing_Search {
        String field { get; set; }
        String value { get; set; }
        String criteria { get; set; }
    }
}