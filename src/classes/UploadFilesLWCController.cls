public with sharing class UploadFilesLWCController {

    private static String candidate_Id;

//    @AuraEnabled
//    public static String saveData(String fileName, String recordId) {
//        Map<String, String> candidateInfo = createCandidate(fileName);
//        return 'Success';
//    }

    @AuraEnabled
    public static List<String> getPosition() {
        List<String> positionNames = new List<String>();
        for (Position__c position : [SELECT Name FROM Position__c WHERE Active__c = TRUE LIMIT 30]) {
            positionNames.add(position.Name);
        }
        return positionNames;
    }

    @AuraEnabled
    public static Map<String, String> createCandidateFromPDF(String namePosition, String fileName, String recordId) {
        Map<String, String> returnMap = new Map<String, String>();
        returnMap.putAll(createCandidatePDF(namePosition, fileName, recordId));
        returnMap.put('Status','Success');
        return returnMap;
    }

    private static String createAttachments(String candId, String fileId, String nameCV) {

        List<ContentVersion> versions = [
                SELECT Id, VersionData, FirstPublishLocationId
                FROM ContentVersion
                WHERE ContentDocumentId = :fileId
                LIMIT 1
        ];
        if (versions.size() > 0) {

            Blob bodyData = versions.get(0).VersionData;
            Attachment attach = new Attachment();
            attach.Body = bodyData;
            attach.Name = 'CV_' + nameCV + '.pdf';
            attach.IsPrivate = false;
            attach.ParentId = candId;
            insert attach;
            return attach.Id;
        }
        return 'Error';
    }

    private static Map<String, String> createCandidatePDF(String namePosition, String fileName, String recordId) {

        String firstName = 'First';
        String lastName = 'Last';

        Map<String, String> returnMap = new Map<String, String>();
        List<Position__c> positions = [SELECT Id FROM Position__c WHERE Name = :namePosition];
        Candidate__c candidate = newCandidate(firstName, lastName, 'Unknown@Unknown.com');
        returnMap.put('Id', candidate.Id);
        returnMap.put('Name', firstName + ' ' + lastName);
        createJobApplication(positions, candidate.Id);
        String attachmentId = createAttachments(candidate.Id, recordId, firstName + ' ' + lastName);
        if (attachmentId != 'Error') {
            candidate.Id_CV__c = attachmentId;
            update candidate;
        }
        return returnMap;
    }

    private static Candidate__c newCandidate(String firstName, String lastName, String email) {
        Candidate__c candidate = new Candidate__c(First_Name__c = firstName,
                Last_Name__c = lastName,
                Email__c = email);
        insert candidate;

        return candidate;
    }


//    @AuraEnabled
//    public static String getZipFile(String recordId) {
//
//        List<ContentVersion> versions = [
//                SELECT Id, VersionData, FirstPublishLocationId
//                FROM ContentVersion
//                WHERE ContentDocumentId = :Id.valueOf(recordId)
//                LIMIT 1
//        ];
//        if (versions.size() > 0) {
//            ContentVersion version = versions.get(0);
//            Blob zipBlob = version.VersionData;
//
//            return EncodingUtil.Base64Encode(zipBlob);
//        } else return null;
//    }

//    @AuraEnabled
//    public static String saveNewFile(String body) {
//
//        String myFile = body.split(',')[1];
//        //String files = body.removeEnd('data:application/octet-stream;base64,');
//        Blob zipBlob;
//        try {
//            zipBlob = EncodingUtil.base64Decode(myFile);
//        } catch(Exception ex) {
//            System.debug(ex.getMessage());
//        }
//
//        System.debug(zipBlob);
//        Attachment attach = new Attachment();
//        attach.Body = zipBlob;
//        attach.Name = 'Ohuennie2.pdf';
//        attach.IsPrivate = false;
//        attach.ParentId = 'a0W1j000002TWnVEAW';
//        insert attach;
//        System.debug(attach.Id);
//
//        return 'Success';
//    }

    @AuraEnabled
    public static String saveFile(String fileName, String recordId) {

        Map<String, String> candidateInfo = createCandidate(fileName);

        candidate_Id = candidateInfo.get('Id');

        List<ContentVersion> versions = [
                SELECT Id, VersionData, FirstPublishLocationId
                FROM ContentVersion
                WHERE ContentDocumentId = :Id.valueOf(recordId)
                LIMIT 1
        ];

        System.debug(versions);

        if (versions.size() > 0) {
            ContentVersion version = versions.get(0);

            ContentVersion contentVersion = new ContentVersion(
                    VersionData = version.VersionData,
                    Title = fileName,
                    PathOnClient = '/' + fileName,
                    FirstPublishLocationId = candidate_Id);
            insert contentVersion;
//            System.enqueueJob(new UnzipClassQueueable(
//                    new List<String>(),
//                    (String)candidateInfo.get('Id'),
//                    (String)contentVersion.Id,
//                    (String)candidateInfo.get('Name')
//            ));

            unZipFindPDF(contentVersion.Id, candidateInfo.get('Name'), candidateInfo.get('Id'));
        }

        return candidate_Id;
    }

    private static Map<String, String> createCandidate(String nameFile) {

        Map<String, String> returnMap = new Map<String, String>();

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

        Candidate__c candidate = newCandidate(FirstName.left(1), LastName, 'Unknown@Unknown.com');

        returnMap.put('Id', candidate.Id);
        returnMap.put('Name', LastName + ' ' + FirstName);
        List<Position__c> positions = [SELECT Id FROM Position__c WHERE Position_ID__c = :fileSplit.get(1)];

        createJobApplication(positions, candidate.Id);
        return returnMap;
    }

    private static void createJobApplication(List<Position__c> positions, Id candidateId) {

        Job_Application__c jobApplication = new Job_Application__c(Candidate__c = candidateId);

        if (positions.size() > 0) {
            jobApplication.Position__c = positions.get(0).Id;
        } else {
            System.debug('Not');
        }

        insert jobApplication;
    }

    @Future
    private static void unZipFindPDF(String contentVersionId, String name, Id candidId) {

        Candidate__c candidate = [SELECT Id, Id_CV__c FROM Candidate__c WHERE Id = :candidId];

        List<contentVersion> contentVersions = [
                SELECT Id, VersionData, Title, FirstPublishLocationId
                FROM ContentVersion
                WHERE Id = :contentVersionId
        ];

        System.debug(contentVersions);

        if (ContentVersions.size() > 0 && !Test.isRunningTest()) {
            ContentVersion contentVersion = contentVersions.get(0);
            System.debug(contentVersion.VersionData);
            Blob zipBlob = contentVersion.VersionData;

            Zippex myZip = new Zippex(zipBlob);

            for (String fileName : myZip.getFileNames()) {

                if (fileName.length() > 6 && fileName.right(4) == '.pdf') {

                    if (fileName.right(6) == 'CV.pdf') {
                        Attachment attach = createAttachmentCV(myZip.getFile(fileName), fileName, contentVersion.FirstPublishLocationId, name, '.pdf');
                        candidate.Id_CV__c = attach.Id;
                    } else {
                        Blob bodyData = myZip.getFile(fileName);
                        Attachment attach = new Attachment();
                        attach.Body = bodyData;
                        attach.Name = 'Cover-letter_' + name.split(' ').get(0) + '.pdf';
                        attach.IsPrivate = false;
                        attach.ParentId = contentVersion.FirstPublishLocationId;
                        insert attach;
                        candidate.Covering_Id__c = attach.Id;
                    }
                } else if (fileName.length() > 6 && fileName.right(7) == 'CV.docx') {
                    Attachment attach = createAttachmentCV(myZip.getFile(fileName), fileName, contentVersion.FirstPublishLocationId, name, '.docx');
                    candidate.Id_CV__c = attach.Id;
                }
            }

            update candidate;
        }
    }

    public static Attachment createAttachmentCV(Blob dataBlob, String fileName, String parentId, String name, String expansion) {

        Blob bodyData = dataBlob;
        Attachment attach = new Attachment();
        attach.Body = bodyData;
        attach.Name = 'CV_' + name.split(' ').get(0) + expansion;
        attach.IsPrivate = false;
        attach.ParentId = parentId;
        insert attach;

        return attach;
    }

//    private static String createAttachments(String candId, String nameFile, String nameCV) {
//
//        List<ContentDocumentLink> docs = [SELECT Id, ContentDocumentId, ContentDocument.Title
//        FROM ContentDocumentLink
//        WHERE LinkedEntityId = :candId];
//
//        Set<Id> versionsIds = new Set<Id>();
//        for (ContentDocumentLink links : docs) {
//            if (links.ContentDocument.Title == nameFile) {
//                versionsIds.add(links.ContentDocumentId);
//            }
//        }
//
//        List<ContentVersion> versions = [
//                SELECT Id, VersionData, FirstPublishLocationId
//                FROM ContentVersion
//                WHERE ContentDocumentId = :versionsIds
//                LIMIT 1
//        ];
//        if (versions.size() > 0) {
//
//            Blob bodyData = versions.get(0).VersionData;
//            Attachment attach = new Attachment();
//            attach.Body = bodyData;
//            attach.Name = 'CV_' + nameCV + '.pdf';
//            attach.IsPrivate = false;
//            attach.ParentId = candId;
//            insert attach;
//        }
//        return 'Success';
//    }
}