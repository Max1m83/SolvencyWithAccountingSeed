/**
 * Created by max1m on 6.07.21.
 */

public with sharing class UnzipClassQueueable implements Queueable {

    private List<String> namesFile;
    private String candidId;
    private String contentVersionId;
    private String name;

    public UnzipClassQueueable(List<String> namesFile, String candidId, String contentVersionId, String name) {

        this.namesFile = namesFile;
        this.candidId = candidId;
        this.contentVersionId = contentVersionId;
        this.name = name;
    }

    public void execute(QueueableContext context) {
        Candidate__c candidate = [SELECT Id, Id_CV__c FROM Candidate__c WHERE Id = :candidId];

        List<contentVersion> contentVersions = [
                SELECT Id, VersionData, Title, FirstPublishLocationId
                FROM ContentVersion
                WHERE Id = :contentVersionId
        ];

        if (ContentVersions.size() > 0 && !Test.isRunningTest()) {
            ContentVersion contentVersion = contentVersions.get(0);
            Blob zipBlob = contentVersion.VersionData;
            Zippex myZip = new Zippex(zipBlob);
            Integer i = 0;

            for (String fileName : myZip.getFileNames()) {
                System.debug('i->' + i);
                i++;
                if (!namesFile.contains(fileName)) {
                    System.debug('Add');
                    namesFile.add(fileName);
                    if (fileName.length() > 6 && fileName.right(4) == '.pdf') {
                        if (fileName.right(6) == 'CV.pdf') {
                            Attachment attach = UploadFilesLWCController.createAttachmentCV(myZip, fileName, contentVersion, name, '.pdf');
                            candidate.Id_CV__c = attach.Id;
                            update candidate;
                            break;
                        } else {
                            Blob bodyData = myZip.getFile(fileName);
                            Attachment attach = new Attachment();
                            attach.Body = bodyData;
                            attach.Name = 'Cover-letter _' + name.split(' ').get(0) + '.pdf ';
                            attach.IsPrivate = false;
                            attach.ParentId = contentVersion.FirstPublishLocationId;
                            insert attach;
                            candidate.Covering_Id__c = attach.Id;
                            update candidate;
                            break;
                        }
                    } else if (fileName.length() > 6 && fileName.right(7) == 'CV.docx') {
                        Attachment attach = UploadFilesLWCController.createAttachmentCV(myZip, fileName, contentVersion, name, '.docx');
                        candidate.Id_CV__c = attach.Id;
                        update candidate;
                        break;
                    }
                }

            }
            if (i > namesFile.size()) {
                ID jobID = System.enqueueJob(new UnzipClassQueueable(namesFile, candidId, contentVersionId, name));
            }
        }
    }
}