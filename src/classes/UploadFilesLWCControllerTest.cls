/**
 * Created by max1m on 26.02.21.
 */
@isTest
public with sharing class UploadFilesLWCControllerTest {

    @isTest(SeeAllData=true)
    private static void saveFileTest() {

        String nameFile = '20201231_823339_FullStackWebDevelope_Husain_S';

        List<ContentDocument> versions = [
                SELECT Id, ContentDocument.Title FROM ContentDocument WHERE ContentDocument.Title = :nameFile
                LIMIT 1
        ];
        Test.StartTest();
        String str= UploadFilesLWCController.saveFile(nameFile, versions.get(0).Id);
        Test.StopTest();

        System.debug(str);
    }

    @isTest
    private static void createCandidateFromPDFTest() {

        String positionId1 = Int_TestCreateObject.createPosition('Position#12','1211111132', 'true');
        Int_TestCreateObject.createContentVersion(positionId1);
        String positionId2 = Int_TestCreateObject.createPosition('Position#13','1232', 'true');
        List<ContentVersion> contents = [SELECT ContentDocumentId FROM ContentVersion];

        System.debug(contents);
        System.assertEquals(1, contents.size());
        Test.StartTest();
        Map<String, String> resultMap = UploadFilesLWCController.createCandidateFromPDF('Position#1', 'file',contents.get(0).ContentDocumentId);
        Test.StopTest();

        System.assertEquals('Success', resultMap.get('Status'));
    }

    @isTest
    private static void getPositionTest() {

        String positionId1 = Int_TestCreateObject.createPosition('Position#12','1211111132', 'true');
        String positionId2 = Int_TestCreateObject.createPosition('Position#13','1211111135', 'false');

        Test.StartTest();
        List<String> positions = UploadFilesLWCController.getPosition();
        Test.StopTest();

        System.assertEquals(1, positions.size());
        System.assertEquals('Position#12', positions.get(0));
    }

    @isTest
    private static void createAttachmentTest() {
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        String positionId = Int_TestCreateObject.createPosition('Position#12','1211111132', 'true');
        List<Attachment> attachments = new List<Attachment>();
        Test.StartTest();
        attachments.add(UploadFilesLWCController.createAttachmentCV(bodyBlob, 'files', positionId, 'attachmentName', '.pdf'));
        Test.StopTest();

        System.assertEquals(1, attachments.size());
    }
}