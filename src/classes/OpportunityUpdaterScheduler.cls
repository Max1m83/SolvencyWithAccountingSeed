/**
 * Created by max1m on 13.08.20.
 */


global with sharing class OpportunityUpdaterScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new OpportunityUpdateBatch());
    }
}