/**
 * Created by max1m on 19.01.21.
 */

({
    MAX_FILE_SIZE: 4500000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 950000, /* Use a multiple of 4 */

    save: function (component) {
        let fileInput = component.find("file").getElement();
        let file = fileInput.files[0];

        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                'Selected file size: ' + file.size);
            return;
        }

        let fr = new FileReader();

        let self = this;
        fr.onload = function () {
            let fileContents = fr.result;
            let base64Mark = 'base64,';
            let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            self.upload(component, file, fileContents);
        };

        fr.readAsDataURL(file);
    },
    upload: function (component, file, fileContents) {
        console.log('Upload');
        let fromPos = 0;
        let toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);

        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
    },
    uploadChunk: function (component, file, fileContents, fromPos, toPos, attachId) {
        console.log('uploadChunk');
        let action = component.get("c.saveTheChunk");
        let chunk = fileContents.substring(fromPos, toPos);

        console.log('action');
        console.log(attachId);

        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: attachId
        });

        let self = this;
        action.setCallback(this, function (a) {

            console.log('uploadChunk: Callback');
            console.log(action.getReturnValue());
            console.log(a.getReturnValue());
            attachId = a.getReturnValue();
            console.log(attachId);

            fromPos = toPos;
            console.log('#####');
            console.log(toPos);
            console.log(fromPos);
            console.log(fileContents.length);
            console.log(self.CHUNK_SIZE);
            console.log(this.CHUNK_SIZE);
            toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
            console.log(toPos);

            console.log('uploadChunk: done');
            component.set("v.label", '');
            self.showToast('Upload Complete', 'You file has successfully uploaded, please upload another now.', 'success', null);

            let navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": attachId
            });
            navEvt.fire();



            // if (fromPos < toPos) {
            //     console.log(fromPos);
            //     console.log(toPos);
            //     self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
            // } else {
            //     console.log('uploadChunk: done');
            //     component.set("v.label", '');
            //     self.showToast('Upload Complete', 'You file has successfully uploaded, please upload another now.', 'success', null);
            //
            //     let navEvt = $A.get("e.force:navigateToSObject");
            //     navEvt.setParams({
            //         "recordId": attachId
            //     });
            //     navEvt.fire();
            // }
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },
    showToast: function (title, message, type, icon) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '2000',
            key: icon,
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }


})