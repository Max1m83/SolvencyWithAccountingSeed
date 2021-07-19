/**
 * Created by max1m on 04.03.21.
 */

public with sharing class Int_Account_Handler implements Int_DeserializerInterface {

    public static List<SObject> parse(String json) {

        List<Account> contacts = createAccount((List<Bexio_Account>) System.JSON.deserialize(json, List<Bexio_Account>.class));
        Database.upsert(contacts, Account.Bexio_Id__c, false);

        return contacts;
    }

    private static List<Account> createAccount(List<Bexio_Account> bexioAccounts) {

        List<Account> newAccounts = new List<Account>();
        Map<String, Bexio_Country__c> countries = getCountries();
        Map<String, Object> existAccount = getExistAccount(bexioAccounts);

        for (Bexio_Account contact : bexioAccounts) {

            if (existAccount.containsKey(contact.id)) {
                // Exist Account. Update?

                System.debug('Exist');
            } else {
                System.debug('New');
                Account account = new Account();
                account.Bexio_Id__c = contact.id;
                account.Name = contact.name_1;
                account.Name_2__c = String.isNotBlank(contact.name_2) ? contact.name_2 : '';
                account.Phone = String.isNotBlank(contact.phone_fixed) ? contact.phone_fixed : '';
                account.Account_Email__c = String.isNotBlank(contact.mail) ? contact.mail : '';
                account.Second_Email__c = String.isNotBlank(contact.mail_second) ? contact.mail_second : '';
                account.Update_in_Bexio__c = Datetime.valueOf(contact.updated_at.substringBefore('+').replace('T', ' '));
                account.Website = String.isNotBlank(contact.url) ? contact.url : '';
                account.isBexio__c = true;
                account.Fax = String.isNotBlank(contact.fax) ? contact.fax : '';
                account.BillingCountry = String.isNotBlank(contact.country_id) ?
                        (countries.containsKey(contact.country_id) ? countries.get(contact.country_id).Name__c : '') : '';
                account.BillingCity = String.isNotBlank(contact.city) ? contact.city : '';
                account.BillingPostalCode = String.isNotBlank(contact.postcode) ? contact.postcode : '';
                account.CurrencyIsoCode = String.isNotBlank(contact.country_id) ? countries.get(contact.country_id).CurrencyIsoCode : 'CHF';
                account.Remark__c = String.isNotBlank(contact.remarks) ? contact.remarks : '';
                newAccounts.add(account);
            }
        }

        return newAccounts;
    }

    private static Map<String, Bexio_Country__c> getCountries() {

        Map<String, Bexio_Country__c> returnCountries = new Map<String, Bexio_Country__c>();
        for (Bexio_Country__c country : [SELECT Bexio_Id__c, Name__c, CurrencyIsoCode FROM Bexio_Country__c]) {
            returnCountries.put(country.Bexio_Id__c, country);
        }
        return returnCountries;
    }

    private static Map<String, Object> getExistAccount(List<Bexio_Account> bexioAccounts) {

        Set<String> bexioAccountId = new Set<String>();

        for (Bexio_Account contact : bexioAccounts) {
            bexioAccountId.add(contact.id);
        }

        return Int_Utils.getSObjectMap([SELECT Id, Bexio_Id__c FROM Account WHERE Bexio_Id__c IN :bexioAccountId], 'Bexio_Id__c');
    }

    public class Bexio_Account {
        String id { get; set; }
        String nr { get; set; }
        String contact_type_id { get; set; }
        String name_1 { get; set; }
        String name_2 { get; set; }
        String salutation_id { get; set; }
        String salutation_form { get; set; }
        String title_id { get; set; }
        String birthday { get; set; }
        String address { get; set; }
        String postcode { get; set; }
        String city { get; set; }
        String country_id { get; set; }
        String mail { get; set; }
        String mail_second { get; set; }
        String phone_fixed { get; set; }
        String phone_fixed_second { get; set; }
        String phone_mobile { get; set; }
        String fax { get; set; }
        String url { get; set; }
        String skype_name { get; set; }
        String remarks { get; set; }
        String language_id { get; set; }
        String is_lead { get; set; }
        String contact_group_ids { get; set; }
        String contact_branch_ids { get; set; }
        String user_id { get; set; }
        String owner_id { get; set; }
        String profile_image { get; set; }
        String updated_at { get; set; }
    }
}