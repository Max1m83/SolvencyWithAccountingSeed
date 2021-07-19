public class OpportunityController {

    @AuraEnabled
    public static String saveOpportunity(Opportunity opp, String dateClose, List<String> multiPicklist, String emailAddress) {

        String result;

        List<Contact> contact = [SELECT Id FROM Contact WHERE Email = :emailAddress];

        try {
            opp.CloseDate = dateClose == null ? Date.today() : Date.valueOf(dateClose);
            opp.OwnerId = UserInfo.getUserId();
            opp.Business_Type__c = '';
            List<Pricebook2> priceBooks = [SELECT Id, Currency__c FROM Pricebook2 WHERE Id = :opp.Pricebook2Id LIMIT 1];

            if (priceBooks.size() > 0) {
                opp.CurrencyIsoCode = priceBooks[0].Currency__c;
            }
            opp.Expected_Amount_local__c = opp.Amount;

            if (String.isBlank(opp.AccountId)) {

                System.debug(String.isBlank(opp.AccountId));

                result = 'Invalid Account';
                List<Account> acc = [SELECT Id FROM Account WHERE Name = 'NotAssignedAccount'];
                System.debug(acc);
                if (acc.size() > 0) {
                    opp.AccountId = acc.get(0).Id;
                }
            }

            if (String.isBlank(opp.Name)) {

                opp.Name = 'Not assigned Name';
            }

            for (String picklistValue : multiPicklist) {
                if (picklistValue != null) {
                    opp.Business_Type__c += picklistValue + ';';
                }
            }

            opp.Business_Type__c = opp.Business_Type__c.removeEnd(';');

            if (result == null) {
                result = 'Insert';
                System.debug(opp);
                insert opp;

                Contact con;

                if (contact.size() > 0) {
                    con = contact.get(0);
                    OpportunityContactRole conRole = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con.Id);
                    insert conRole;
//                } else {
//                    if (String.isNotBlank(opp.AccountId)) {
//                        con = new Contact(LastName = opp.Name, Email = emailAddress, AccountId = opp.AccountId);
//                        //insert con;
//                        OpportunityContactRole conRole = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con.Id, Role = 'Business User');
//                       // insert conRole;
//                    }
                }
            }

        } catch (DmlException e) {
            System.debug('Message: ' + e.getMessage());
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return result == 'Invalid Account' ? result : opp.Id;
    }

//    @AuraEnabled
//    public static Map<String, List<String>> getIdAccount(String StringEmail) {
//
//        System.debug('getIdAccount');
//        System.debug(StringEmail);
//
//        return getAccount(StringEmail);
//    }

    @AuraEnabled
    public static Map<String, List<String>> getAccount(String StringEmail) {

        System.debug(StringEmail);
        Map<String, List<String>> idPriceAndAccount = new Map<String, List<String>>();

        List<Pricebook2> PricebookList = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book CHF'];
        List<Schema.PicklistEntry> stageValue = Opportunity.fields.StageName.getDescribe().getpicklistvalues();
        List<Schema.PicklistEntry> sourceValue = Opportunity.fields.Source__c.getDescribe().getpicklistvalues();
        List<Schema.PicklistEntry> activityStatusValue = Opportunity.fields.Activity_Status__c.getDescribe().getpicklistvalues();
        List<String> priceList = new List<String> ();
        List<String> accountList = new List<String> ();
        List<String> stageValueList = new List<String>();
        List<String> sourceValueList = new List<String>();
        List<String> activityStatusValueList = new List<String>();

        if (PricebookList.size() > 0) {

            priceList.add([SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book CHF' LIMIT 1].Id);
            idPriceAndAccount.put('Price', priceList);

        } else {
            priceList.add('No');
            idPriceAndAccount.put('Price', priceList);
        }

        if (StringEmail != '') {
            List<Account> accList = [SELECT Id, Name FROM Account WHERE Account_Email__c = :StringEmail LIMIT 1];

            if (accList.size() > 0) {
                accountList.add(accList[0].Id);
                idPriceAndAccount.put('Account', accountList);

            } else {

                accountList.add('No');
                idPriceAndAccount.put('Account', accountList);
            }
        }

        for (Schema.PicklistEntry picklistStage : stageValue) {
            stageValueList.add(picklistStage.value);
        }
        if (stageValueList.size() > 0) {
            idPriceAndAccount.put('Stage', stageValueList);
        }

        for (Schema.PicklistEntry picklistSource : sourceValue) {
            sourceValueList.add(picklistSource.value);
        }
        if (sourceValueList.size() > 0) {
            idPriceAndAccount.put('Source', sourceValueList);
        }

        for (Schema.PicklistEntry picklistActivity : activityStatusValue) {
            activityStatusValueList.add(picklistActivity.value);
        }
        if (activityStatusValueList.size() > 0) {
            idPriceAndAccount.put('Activity', activityStatusValueList);
        }

        System.debug(idPriceAndAccount);

        return idPriceAndAccount;
    }

    @AuraEnabled
    public static Map<String, List<String>> saveAccount(Account account) {

        insert account;

        List<Contact> contact = [SELECT Id FROM Contact WHERE Email = :account.Account_Email__c];

        if (contact.size() > 0) {
            Contact con = contact.get(0);
            con.AccountId = account.Id;
            update con;
        } else {

            Contact con = new Contact(LastName = account.Name, Email = account.Account_Email__c, AccountId = account.Id);
            insert con;
        }

        return getAccount(String.valueOf(account.Account_Email__c));
    }
}