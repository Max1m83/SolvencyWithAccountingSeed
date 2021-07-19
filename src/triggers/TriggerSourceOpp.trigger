trigger TriggerSourceOpp on Opportunity (before insert, after insert, before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {

        Map<Id, Opportunity> newOppMaps = Trigger.newMap;
        Map<Id, Opportunity> oldOppMaps = Trigger.oldMap;
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> priceBooks = new Map<Id, String>();
        List<Account> updateAccounts = new List<Account>();
        List<Opportunity> synAmountOpp = new List<Opportunity>();

        changeRecordType(newOppMaps, oldOppMaps);

        for (Pricebook2 price : [SELECT Id, Currency__c FROM Pricebook2 ]) {
            priceBooks.put(price.Id, price.Currency__c);
        }

        for (Opportunity opp : newOppMaps.values()) {

            if (priceBooks.containsKey(opp.Pricebook2Id)) {
                opp.CurrencyIsoCode = priceBooks.get(opp.Pricebook2Id);
            }

            Boolean isChangeAccountType = false;
            Boolean isChangeOnboarding = false;

            if (opp.Amount__c != oldOppMaps.get(opp.Id).Amount__c) {

                opp.Amount = opp.Amount__c;
            }

            if (opp.Amount != oldOppMaps.get(opp.Id).Amount) {

                opp.Amount__c = opp.Amount;
            }

            if (opp.StageName != oldOppMaps.get(opp.Id).StageName) {
                if (opp.StageName == 'In contact') {
                    opp.Date_In_contact__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();

                } else if (opp.StageName == 'Negotiation') {
                    opp.Date_Negotiation__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();

                } else if (opp.StageName == 'Hand-shake agreement') {
                    opp.Date_hand_shake__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();
                    isChangeAccountType = true;

                } else if (opp.StageName == 'Won') {
                    opp.Date_stage_of_Won__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();
                    isChangeAccountType = true;

                }  else if (opp.StageName == 'Closed Won') {
                    opp.Date_Closed_Won__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();
                    isChangeAccountType = true;

                } else if (opp.StageName == 'Closed Lost') {
                    opp.Date_stage_of_Closed_Lost__c = Date.today();
                    opp.Last_date_change_of_stage__c = Date.today();
                }
            }

            if (opp.Amount != oldOppMaps.get(opp.Id).Amount) {
                synAmountOpp.add(opp);
            } else if (opp.Amount__c != oldOppMaps.get(opp.Id).Amount__c) {
                opp.Amount = null;
                synAmountOpp.add(opp);
            }
            if (isChangeAccountType) {
                accIds.add(opp.AccountId);
                if (opp.Operations_Mode__c != 'onboarding' && opp.Operations_Mode__c != 'bau') {
                    opp.Operations_Mode__c = 'onboarding';
                }
            }
        }

        for (Account acc : [
                SELECT Id, Account_Type__c
                FROM Account
                WHERE Id IN :accIds
        ]) {

            acc.Account_Type__c = 'Client';
            updateAccounts.add(acc);
        }

        update updateAccounts;

        if (synAmountOpp.size() > 0) {
            synAmountfields(synAmountOpp);
        }
    }

    // For migration on Production logics for field Source__c
    if (Trigger.isBefore && Trigger.isInsert) {

        Set<Id> accIds = new Set<Id>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Opportunity> synAmountOpp = new List<Opportunity>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Set<Id> accStageIds = new Set<Id>();
        List<Account> updateAccounts = new List<Account>();

        for (Opportunity opp : Trigger.new) {

            Boolean isChangeAccountType = false;

            if (opp.StageName == 'In contact') {
                opp.Date_In_contact__c = Date.today();
                opp.Last_date_change_of_stage__c = Date.today();
            } else if (opp.StageName == 'Negotiation') {
                opp.Date_Negotiation__c = Date.today();
                opp.Last_date_change_of_stage__c = Date.today();

            } else if (opp.StageName == 'Hand-shake agreement') {
                opp.Date_hand_shake__c = Date.today();
                opp.Last_date_change_of_stage__c = Date.today();
                isChangeAccountType = true;

            } else if (opp.StageName == 'Closed Won') {
                opp.Date_Closed_Won__c = Date.today();
                opp.Last_date_change_of_stage__c = Date.today();
                isChangeAccountType = true;

            } else if (opp.StageName == 'Closed Lost') {
                opp.Date_stage_of_Closed_Lost__c = Date.today();
                opp.Last_date_change_of_stage__c = Date.today();
            }

            if (opp.Amount == null) {
                opp.Amount = 5000;
            }

            if (opp.Source__c == 'None' || opp.Source__c == null) {
                accIds.add(opp.AccountId);
                opps.add(opp);
            }
            if (isChangeAccountType) {
                accStageIds.add(opp.AccountId);
            }
        }

        for (Account acc : [
                SELECT Id, Account_Type__c
                FROM Account
                WHERE Id IN :accStageIds
        ]) {

            acc.Account_Type__c = 'Client';
            updateAccounts.add(acc);
        }

        update updateAccounts;

        for (Account acc : [
                SELECT Id, (
                        SELECT Id, StageName
                        FROM Opportunities
                        WHERE StageName = 'Hand-shake agreement' OR StageName = 'Closed Won'
                )
                FROM Account
                WHERE Id = :accIds
        ]) {

            accounts.put(acc.Id, acc);
        }

        for (Opportunity newOpp : opps) {
            if (accounts.containsKey(newOpp.AccountId) && accounts.get(newOpp.AccountId).Opportunities.size() > 0) {
                newOpp.Source__c = 'Upselling';
            } else {
                newOpp.Source__c = 'New Business - client referral';
            }
        }
        synAmountfields(Trigger.new);
        List<Opportunity> opp = Handler.timeLineEdit(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {

        List <Business__c> bisinesses = new List <Business__c>();

        for (Opportunity opp : Trigger.new) {

            Business__c biss = new Business__c();
            biss.Opportunity__c = opp.Id;
            biss.Account__c = opp.AccountId;
            biss.CurrencyIsoCode = opp.CurrencyIsoCode;
            bisinesses.add(biss);
        }

        insert bisinesses;
    }

    //This method for Synchronize filed AmountChange__c with Amount
    private static void synAmountfields(List <Opportunity> synAmountOpp) {

        for (Opportunity opp : synAmountOpp) {
            if (opp.Amount != null) {
                opp.Amount__c = opp.Amount;
            } else {
                opp.Amount = opp.Amount__c;
            }
        }
    }

    private static void changeRecordType(Map<Id, Opportunity> newOpp, Map<Id, Opportunity> oldOpp) {

        for (Opportunity opp : newOpp.values()) {

            if (oldOpp.get(opp.Id).StageName == 'Closed' && newOpp.get(opp.Id).StageName != oldOpp.get(opp.Id).StageName) {

                opp.RecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            }
        }
    }
}