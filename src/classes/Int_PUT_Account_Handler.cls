/**
 * Created by max1m on 13.04.21.
 */

public with sharing class Int_PUT_Account_Handler {

    public static String putRequestAccount(Account account) {

        Bexio_Account accountBexio = new Bexio_Account();

        accountBexio.contact_type_id = 1;  //value=1 for companies or 2 for persons
        accountBexio.name_1 = String.isNotBlank(account.Company_name__c) ? account.Company_name__c :  account.Name;
        accountBexio.name_2 = '';
        accountBexio.salutation_id = 2;
        accountBexio.salutation_form = null;
        accountBexio.titel_id = null;
        accountBexio.birthday = null;
        accountBexio.address = String.isNotBlank(account.BillingStreet) ? account.BillingStreet : '';
        accountBexio.postcode = String.isNotBlank(account.BillingPostalCode) ? account.BillingPostalCode : '';
        accountBexio.city = String.isNotBlank(account.BillingCity) ? account.BillingCity : '';
        accountBexio.country_id = 1; //country object
        accountBexio.mail = String.isNotBlank(account.Account_Email__c) ? account.Account_Email__c : '';
        accountBexio.mail_second = null;
        accountBexio.phone_fixed = String.isNotBlank(account.Phone) ? account.Phone : '';
        accountBexio.phone_fixed_second = '';
        accountBexio.phone_mobile = '';
        accountBexio.fax = '';
        accountBexio.url = String.isNotBlank(account.Website) ? account.Website : '';
        accountBexio.skype_name = '';
        accountBexio.remarks = '';
        accountBexio.remarks = '';
        accountBexio.language_id = null;
        accountBexio.contact_group_ids = null;
        accountBexio.contact_branch_ids = null;
        accountBexio.user_id = 1;
        accountBexio.owner_id = 1;

        return System.JSON.serialize(accountBexio);
    }

    public class Bexio_Account {
        Integer contact_type_id { get; set; }
        String name_1 { get; set; }
        String name_2 { get; set; }
        Integer salutation_id { get; set; }
        Integer salutation_form { get; set; }
        Integer titel_id { get; set; }
        String birthday { get; set; }
        String address { get; set; }
        String postcode { get; set; }
        String city { get; set; }
        Integer country_id { get; set; }
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
        String contact_group_ids { get; set; }
        String contact_branch_ids { get; set; }
        Integer user_id { get; set; }
        Integer owner_id { get; set; }
    }
}