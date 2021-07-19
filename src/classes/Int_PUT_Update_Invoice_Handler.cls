/**
 * Created by max1m on 22.03.21.
 */

public with sharing class Int_PUT_Update_Invoice_Handler {

    final static Map<String, Integer> CURRENCY_MAP = new Map<String, Integer>{
            'CHF' => 1,
            'EUR' => 2,
            'USD' => 3,
            'GBP' => 4
    };

    public static String putRequestInvoice(Invoice__c invoice) {

        List<Invoice_Product__c> products = [
                SELECT Id, Unit_Price__c, Total__c, Quantity__c,Bexio_Id__c, Product__r.Name, Position__c
                FROM Invoice_Product__c
                WHERE Invoice__c = :invoice.Id
                ORDER BY Position__c ASC
        ];
        List<Account> accounts = [SELECT Bexio_Id__c,CurrencyIsoCode FROM Account WHERE Id = :invoice.Account__c];
        List<Opportunity> opportunities = [SELECT CurrencyIsoCode FROM Opportunity WHERE Id = :invoice.Opportunity__c];
        Bexio_Billing billing = new Bexio_Billing();

        if (accounts.size() > 0 && opportunities.size() > 0 && String.isNotBlank(accounts.get(0).Bexio_Id__c)) {

            //Edit Title!;
            billing.titleBexio = createTitleInvoice(invoice);
            billing.titleBexio = String.isNotBlank(billing.titleBexio) ? billing.titleBexio : 'null';
            billing.contact_id = accounts.get(0).Bexio_Id__c;
            billing.contact_sub_id = null;
            billing.user_id = findOwnerNumber(invoice);
            billing.pr_project_id = null;
            billing.language_id = 1;
            billing.logopaper_id = 1;

            //Need callout to the Bank Account
            billing.bank_account_id = 1;
            billing.currency_id = CURRENCY_MAP.get(opportunities.get(0).CurrencyIsoCode);
            billing.payment_type_id = 1;
            billing.header = '';
            billing.header = '';
            billing.mwst_type = invoice.With_Tax__c ? 0 : 1;

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
        }

        return System.JSON.serialize(billing).replaceAll('titleBexio', 'title');
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

    private static Set<String> getIds(List<Bexio_Billing> bexioBilling, String nameField) {
        Set<String> returnIds = new Set<String>();

        for (Bexio_Billing bexioObject : bexioBilling) {
            if (nameField == 'Account') {
                returnIds.add(bexioObject.contact_id);
            }
            if (nameField == 'Invoice') {
                returnIds.add(bexioObject.id);
            }
        }
        return returnIds;
    }

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
        String header { get; set; }
        Integer mwst_type { get; set; }
        String mwst_is_net { get; set; }
        String show_position_taxes { get; set; }
        String is_valid_from { get; set; }
        String is_valid_to { get; set; }
        String reference { get; set; }
        String api_reference { get; set; }
    }

}