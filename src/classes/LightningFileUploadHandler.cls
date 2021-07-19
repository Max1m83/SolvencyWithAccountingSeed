/**
 * Created by max1m on 19.01.21.
 */

public with sharing class LightningFileUploadHandler {

    @AuraEnabled
    public static Map<String, Id> saveTheFile(String fileName, String base64Data, String contentType) {

        System.debug('save');

        Map<String, Id> returnMap = new Map<String, Id>();

        Id parentId = createCandidate(fileName);
        returnMap.put('Candidate', parentId);

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion contentVersion = new ContentVersion(
                VersionData = EncodingUtil.base64Decode(base64Data),
                Title = fileName,
                PathOnClient = '/' + fileName,
                FirstPublishLocationId = parentId);
        insert contentVersion;

        unZipFindPDF(contentVersion);

        returnMap.put('contentVersion', contentVersion.Id);

        return returnMap;
        //return parentId;
    }

    @AuraEnabled
    public static Id saveTheChunk(String fileName, String base64Data, String contentType, String fileId) {

        Map<String, Id> returnMap = new Map<String, Id>();
        System.debug(fileId);
        if (fileId == '') {
            returnMap = saveTheFile(fileName, base64Data, contentType);
            fileId = returnMap.get('contentVersion');
        } else {
            appendToFile(fileId, base64Data);
        }
        //return Id.valueOf(fileId);
        return Id.valueOf(returnMap.get('Candidate'));
    }

    private static void appendToFile(Id fileId, String base64Data) {

        System.debug('ffff');

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        System.debug('ddd');
        System.debug(fileId);
        ContentVersion contentVersion = [
                SELECT Id, VersionData, FileType
                FROM ContentVersion
                WHERE Id = :fileId
        ];
        System.debug(contentVersion);
        String existingBody = EncodingUtil.base64Encode(contentVersion.VersionData);
        contentVersion.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        update contentVersion;
        unZipFindPDF(contentVersion);
    }

    private static String createCandidate(String nameFile) {

        String DateFile = nameFile.left(4);

        List<String> fileSplit = nameFile.split('_');

        String LastName;
        String FirstName;

        if (fileSplit.size() > 2) {
            LastName = fileSplit.get(fileSplit.size() - 2);
            FirstName = fileSplit.get(fileSplit.size() - 1);
        } else {
            LastName = 'Unknown';
            FirstName = 'Un';
        }

        Candidate__c candidate = new Candidate__c(First_Name__c = FirstName.left(1),
                Last_Name__c = LastName,
                Email__c = 'Unknown@Unknown.com');

        insert candidate;

        createJobApplication(fileSplit.get(1), candidate.Id);
        return candidate.Id;
    }

    private static void createJobApplication(String positionId, Id candidateId) {

        List<Position__c> positions = [SELECT Id FROM Position__c WHERE Position_ID__c = :positionId];
        Job_Application__c jobApplication = new Job_Application__c(Candidate__c = candidateId);

        if (positions.size() > 0) {
            jobApplication.Position__c = positions.get(0).Id;
        } else {
            System.debug('Not');
        }

        insert jobApplication;
    }

    private static void unZipFindPDF(ContentVersion contentVersion) {

        System.debug('unZipFindPDF');
        System.debug(contentVersion);

        Attachment sampleAttachment = [SELECT Name, Body FROM Attachment WHERE ParentId = :contentVersion.Id];


        System.debug(sampleAttachment);


        Zippex sampleZip = new Zippex();


        //Blob WOCFbody = contentVersion.VersionData;
//        Zippex myZip = new Zippex(WOCFbody);
//
//        for (String fileName : myZip.getFileNames()) {
//
//            System.debug(fileName);
//
//            if (fileName.length() > 4 && fileName.right(4) == '.pgf') {
//                System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!');
//                System.debug(fileName);
//
//            }
//
//        }


//        System.debug(contentVersion);
//
//
//        for (ContentDocumentLink CDLink : [
//                SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title
//                FROM ContentDocumentLink
//                WHERE LinkedEntityId = :billIds
//        ]) {
//
//            ContentDocumentIds.add(CDLink.ContentDocumentId);
//
//        }
//
//        for (ContentVersion cversion : [
//                SELECT title,
//                        PathOnClient, FileType,
//                        VersionData
//                FROM ContentVersion
//                WHERE ContentDocumentId IN :ContentDocumentIds
//        ]) {
//            blob WOCFbody = cversion.VersionData;
//
//            Messaging.Emailfileattachment attachFile = new Messaging.Emailfileattachment();
//            attachFile.setContentType('application/vnd.ms-excel');
//            attachFile.setFileName(cversion.title);
//            attachFile.setInline(false);
//            attachFile.Body = WOCFbody;
//
//            attachments.add(attachFile);
//        }


    }

}