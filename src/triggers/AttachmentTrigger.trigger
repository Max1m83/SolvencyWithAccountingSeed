/**
 * Created by max1m on 17.06.21.
 */

trigger AttachmentTrigger on Attachment (before insert) {
    System.debug('FFF');
}