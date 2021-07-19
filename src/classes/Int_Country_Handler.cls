/**
 * Created by max1m on 11.03.21.
 */

public with sharing class Int_Country_Handler implements Int_DeserializerInterface {

    public static List<SObject> parse(String json) {

        List<Bexio_Country__c> countries = createCountries((List<Bexio_Country>) System.JSON.deserialize(json, List<Bexio_Country>.class));

        if (countries.size() < 201) {
            Database.upsert(countries, Bexio_Country__c.Bexio_Id__c, false);
        }

        return countries;
    }

    private static List<SObject> createCountries(List<Bexio_Country> bexioCountries) {

        List<SObject> returnObject = new List<SObject>();

        for (Bexio_Country bexioCountry : bexioCountries) {

            Bexio_Country__c newCountry = new Bexio_Country__c();
            newCountry.Bexio_Id__c = bexioCountry.id;
            newCountry.Name__c = bexioCountry.name;
            newCountry.name_short__c = bexioCountry.name_short;
            newCountry.iso_3166_alpha2__c = bexioCountry.iso_3166_alpha2;

            returnObject.add(newCountry);
        }

        return returnObject;
    }

    public class Bexio_Country {
        String id { get; set; }
        String name { get; set; }
        String name_short { get; set; }
        String iso_3166_alpha2 { get; set; }
    }
}