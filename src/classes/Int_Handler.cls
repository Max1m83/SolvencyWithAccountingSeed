/**
 * Created by max1m on 21.05.21.
 */

public with sharing class Int_Handler {

    public static void accountTriggerInsertAfter(List<Account> newInsertAccount) {
        createAccountOnBexioSide(newInsertAccount);
    }

    private static void createAccountOnBexioSide(List<Account> newInsertAccount) {

        Int_Account_PUT_Queueable accountPuts = new Int_Account_PUT_Queueable(newInsertAccount);
        // enqueue the job for processing
        Id jobID = System.enqueueJob(accountPuts);
    }
}