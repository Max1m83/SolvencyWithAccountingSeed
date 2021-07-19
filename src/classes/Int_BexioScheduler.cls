/**
 * Created by max1m on 23.03.21.
 */

public with sharing class Int_BexioScheduler implements Schedulable {

    public static String CRON_EXP;

    public void execute(SchedulableContext ctx) {
        Int_BatchController.controlBatch();
    }
}