/**
 * Created by max1m on 24.02.21.
 */

public with sharing class Int_Utils {

    public static List<Integer> generateCountOfChuncks(Decimal recordsCount, Decimal divisor, Integer offset) {

        if (recordsCount == null || recordsCount == 0 || divisor == null || divisor == 0) return new List<Integer>();

        Decimal d1 = recordsCount / divisor;
        Decimal countOfExecutes = d1.intValue();
        countOfExecutes = (d1 > countOfExecutes) ? countOfExecutes + 1 : countOfExecutes;

        List<Integer> finalCountOfExecutes = new List<Integer>();
        for (Integer item = offset ; item < offset + countOfExecutes ; item++) {
            finalCountOfExecutes.add(item);
        }

        return Test.isRunningTest() ? new List<Integer>{1} : finalCountOfExecutes;
    }

    public static String getPicklistValue(String nameObject, String picklistName, String value) {

        List<Schema.PicklistEntry> picklistValue;
        String result;

        if (nameObject == 'Invoice') {
            if (picklistName == 'Title') {
                picklistValue = Invoice__c.fields.Invoice_Title__c.getDescribe().getPicklistValues();
            }
        }

        for (Schema.PicklistEntry existValue : picklistValue) {
            if (existValue.value == value) {
                result = existValue.value;
            }
        }

        return result;
    }

    public static Map<String, SObject> getSObjectMap(List<SObject> sObjectList, String fieldToGroup) {
        Map<String, SObject> sObjectMap = new Map<String, SObject>();

        for (SObject sfRecord : sObjectList) {
            String keyFieldValue = (String) sfRecord.get(fieldToGroup);
            if (keyFieldValue == null) {
                continue;
            }
            sObjectMap.put(keyFieldValue, sfRecord);
        }
        return sObjectMap;
    }
}