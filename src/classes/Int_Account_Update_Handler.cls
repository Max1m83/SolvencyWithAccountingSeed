/**
 * Created by max1m on 14.04.21.
 */

public with sharing class Int_Account_Update_Handler implements Int_DeserializerInterface {

    public static List<SObject> parse(String json) {

        List<SObject> updateAccount = new List<SObject>();

        

        return updateAccount;
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
        String is_lead { get; set; }
        String contact_group_ids { get; set; }
        String contact_branch_ids { get; set; }
        Integer user_id { get; set; }
        Integer owner_id { get; set; }
        String profile_image { get; set; }
        String updated_at { get; set; }
    }

}