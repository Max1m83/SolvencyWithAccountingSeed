/**
 * Created by max1m on 31.05.21.
 */

public with sharing class SendReminder {

    private final Id emailId;

    public SendReminder(ApexPages.StandardController stdController) {

        emailId = stdController.getId();

        System.debug(emailId);
    }

    public void executeMethod() {
        System.debug('executeMethod');
    }
}