/**
 * Created by max1m on 26.01.21.
 */

import {api, LightningElement, track} from 'lwc';
//import jszip from '@salesforce/resourceUrl/JSZip_Fun';
//import jsZipmin from '@salesforce/resourceUrl/JSZip2';
//import JsZipMin from '@salesforce/resourceUrl/JsZipMin';
//import {loadScript} from "lightning/platformResourceLoader";
import {NavigationMixin} from 'lightning/navigation';
import saveFile from '@salesforce/apex/UploadFilesLWCController.saveFile';
//import saveNewFile from '@salesforce/apex/UploadFilesLWCController.saveNewFile';
//import getZipFile from '@salesforce/apex/UploadFilesLWCController.getZipFile';
import positions from '@salesforce/apex/UploadFilesLWCController.getPosition';
import createCandidate from '@salesforce/apex/UploadFilesLWCController.createCandidateFromPDF';

export default class FileUploadExample extends NavigationMixin(LightningElement) {

    @api recordId;
    @api recordIdPDF;
    @track fileData;
    @track fileDataPDF;
    @track candidateId;
    @track fileId;
    @track fileIdPDF;
    @track isFileName;
    @track isFilePDFName;
    @track isLoading;
    @api testFiles;
    @track valuePositions;
    @api selectPosition;
    @api resultPositions;

    get acceptedFormats() {
        return ['.zip'];
    }

    get acceptedFormatsPDF() {
        return ['.pdf'];
    }

    handleClickPDF() {

        this.isLoading = true;

        createCandidate({
            namePosition: this.selectPosition,
            fileName: this.fileDataPDF,
            recordId: this.fileIdPDF
        })

            .then(result => {
                this.candidateId = result.Id;
                this.navigateToViewRecordPage();
                this.isLoading = false;
                this.isLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
        this.isFilePDFName = false;
    }

    connectedCallback() {

        positions({
        })
            .then(result => {
                let listPositions = [];

                result.forEach((element) => {
                    let position = {};
                    position.label = element;
                    position.value = element;
                    listPositions.push(position);
                });
                this.valuePositions = listPositions;

                this.valuePositions();
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleUploadFinishedPDF(event) {

        const uploadedFiles = event.detail.files;
        this.fileDataPDF = uploadedFiles[0].name;
        this.fileIdPDF = uploadedFiles[0].documentId;
        this.isFilePDFName = true;
    }

    handleUploadFinishedZIP(event) {
        const uploadedFiles = event.detail.files;
        let blobZip;
        this.fileData = uploadedFiles[0].name;
        this.fileId = uploadedFiles[0].documentId;
        // getZipFile({
        //     recordId: this.fileId,
        // })
        //     .then(result => {
        //         blobZip = result;
        //         loadScript(this, JsZipMin + '/cdnjs/jszip.min.js')
        //             .then(async (data) => {
        //                 var zip = new JSZip();
        //                 console.log('zip32sd1');
        //                 console.log(zip);
        //                 //
        //                 try {
        //                     let filesArray = await zip.loadAsync(blobZip, {base64: true, dir: false});
        //                     //let fileBlob = await filesArray.file('Hello.txt').async("blob");
        //                     //let fileBlob = await filesArray.file('20210604_823352_ReportingAnalystMark_Tome_A_CV.docx').async("blob");
        //                     //let fileBlob = await filesArray.file('20210705_1022820_JuniorDeveloper_Nguyen_T_CV.pdf').async("blob");
        //                     let fileBlob = await filesArray.file('20210702_823345_QuantitativeResearch_Akhmetov_B_CV.pdf').async("blob");
        //                     let fileBlobExist;
        //                     let reader = new FileReader();
        //                     reader.onloadend = () => {
        //                         var base64data = reader.result;
        //                         console.log('ff',base64data);
        //                         console.log('FFF');
        //                         saveNewFile({
        //                                 body: base64data,
        //                             }).then(result => {
        //                                 console.log(result)
        //                             })
        //                     }
        //
        //                     reader.readAsDataURL(fileBlob);
        //
        //                     // saveNewFile({
        //                     //     body: fileBlobExist,
        //                     // }).then(result => {
        //                     //     console.log(result)
        //                     // })
        //                 } catch (e) {
        //                     console.log('custom err')
        //                     console.log(e.message);
        //                 }
        //             });
        //     })
        //     .catch(error => {
        //         console.error(error);
        //         this.isLoading = false;
        //     });

        console.log('handleUploadFinished');


        this.isFileName = true;
        console.log('FFF');
        // let reader = new FileReader();
        // console.log('DDd');
        // reader.onload=()=>{
        //     let base64 = reader.result;
        //     this.file = {
        //         'filename':fileData,
        //         'base64':base64,
        //         'recordId':this.recordId
        //     }
        //     console.log('#');
        //     console.log(this.fileData);
        // }
        // reader.readAsDataURL(uploadedFiles);
        // console.log("jsZip? ", jszip);
        // loadScript(this, jszip ).then(() => {
        //
        //     console.log("Script loaded...");
        // });
        // debugger;
        // console.log('b4inst');
        // var zipFile = new jszip();
        // console.log('afterinst')
        // debugger;
        //var zipFile = new JSZip();


        //let zipFile = new JSZip();;
        //let zipFile = new JSZip();
        //console.log('1',zipFile);

        // JSZip.loadAsync(uploadedFiles)
        //     .then(function(zip) {
        //         // you now have every files contained in the loaded zip
        //         console.log('@');
        //         zip.file("hello.txt").async("string"); // a promise of "Hello World\n"
        //     });


    }

    // unZip() {
    //     let blobZip;
    //     getZipFile({
    //         recordId: this.fileId,
    //     })
    //         .then(result => {
    //             blobZip = result;
    //             loadScript(this, JsZipMin + '/cdnjs/jszip.min.js')
    //                 .then(async (data) => {
    //                     var zip = new JSZip();
    //                     console.log('zip32sd1');
    //                     console.log(zip);
    //                     //
    //                     try {
    //                         let filesArray = await zip.loadAsync(blobZip, {base64: true, dir: false});
    //                         //let fileBlob = await filesArray.file('Hello.txt').async("blob");
    //                         //let fileBlob = await filesArray.file('20210604_823352_ReportingAnalystMark_Tome_A_CV.docx').async("blob");
    //                         //let fileBlob = await filesArray.file('20210705_1022820_JuniorDeveloper_Nguyen_T_CV.pdf').async("blob");
    //                         let fileBlob = await filesArray.file('20210702_823345_QuantitativeResearch_Akhmetov_B_CV.pdf').async("blob");
    //                         let fileBlobExist;
    //                         let reader = new FileReader();
    //                         reader.onloadend = () => {
    //                             var base64data = reader.result;
    //                             console.log('ff',base64data);
    //                             console.log('FFF');
    //                             saveNewFile({
    //                                 body: base64data,
    //                             }).then(result => {
    //                                 console.log(result)
    //                             })
    //                         }
    //
    //                         reader.readAsDataURL(fileBlob);
    //
    //                         // saveNewFile({
    //                         //     body: fileBlobExist,
    //                         // }).then(result => {
    //                         //     console.log(result)
    //                         // })
    //                     } catch (e) {
    //                         console.log('custom err')
    //                         console.log(e.message);
    //                     }
    //                 });
    //         })
    //         .catch(error => {
    //             console.error(error);
    //             this.isLoading = false;
    //         });
    //
    //     console.log('handleUploadFinished');
    // }

    handleChange(event) {
        this.selectPosition = event.target.value;
    }

    handleClick() {

        this.isLoading = true;

        saveFile({
            fileName: this.fileData,
            recordId: this.fileId
        })

            .then(result => {
                this.candidateId = result;
                this.navigateToViewRecordPage();
                this.isLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
        this.isFileName = false;
    }

    navigateToViewRecordPage() {
        console.log('Navigate');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.candidateId,
                "objectApiName": "Candidate__c",
                "actionName": "view"
            },
        });
    }
}