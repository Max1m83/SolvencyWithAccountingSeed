/**
 * Created by max1m on 07.08.20.
 */

global with sharing class AccountsUpdaterScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new AccountAnalyticsBatch(6));
    }
}