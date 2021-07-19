/**
 * Created by max1m on 8.06.21.
 */

trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        createParentId(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug('Before');
        System.debug(Trigger.new);
    }

    private static void createParentId(List<EmailMessage> emails) {

        Set<Id> ids = new Set<Id>();

        for (EmailMessage mass : emails) {
            ids.add(mass.RelatedToId);
            System.debug(mass);
        }
        System.debug(ids);
    }
}