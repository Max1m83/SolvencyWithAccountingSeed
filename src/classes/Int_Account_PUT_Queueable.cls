/**
 * Created by max1m on 13.04.21.
 */

public with sharing class Int_Account_PUT_Queueable implements Queueable, Database.AllowsCallouts {

    private Map<Id, Account> accountMap;
    private Set<Id> accountId;

    public Int_Account_PUT_Queueable(List<Account> accounts) {

        this.accountId = (new Map<Id, Account>(accounts)).keySet();
    }

    public void execute(QueueableContext context) {

        this.accountMap = new Map<Id, Account>([
                SELECT Name, Company_name__c, BillingStreet, BillingPostalCode, BillingCity, Account_Email__c, Phone, Website, Bexio_Id__c, isBexio__c
                FROM Account
                WHERE Id IN :accountId
        ]);

        if (this.accountMap.size() > 0) {

            Boolean isFirst = true;

            for (Id accountId : this.accountMap.keySet()) {

                if (isFirst) {
                    isFirst = false;
                    Account acc = this.accountMap.get(accountId);

                    String result = Int_Helper_Reserved.putAccount(acc);

                    if(result != null) {
                        Bexio_Account updateAccount = (Bexio_Account) System.JSON.deserialize(result.replaceAll('id', 'Bexio_id'), Bexio_Account.class);

                        acc.Bexio_Id__c = updateAccount.Bexio_id;
                        acc.isBexio__c = true;
                        update acc;
                        this.accountMap.remove(accountId);
                    }
                }
            }
        }

        if (this.accountMap.size() > 0 && !Test.isRunningTest() ) {
            Id jobID = System.enqueueJob(new Int_Account_PUT_Queueable(this.accountMap.values()));
        }
    }

    public class Bexio_Account {
        String Bexio_id { get; set; }
    }
}