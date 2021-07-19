/**
 * Created by max1m on 28.01.21.
 */

(
    {
        getEmail: function (component, event, ReceivedEvent) {

            component.set('v.showEvent', true);
            component.set('v.idReminder', ReceivedEvent.data.payload.RemEmail_Ids__c);
            component.set('v.oldStatusJob', ReceivedEvent.data.payload.Status__c);

            let action = component.get('c.createPDF');
            action.setParams({
                idReminder: component.get('v.idReminder'),
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    let utilityAPI = component.find('utilitybar');
                    utilityAPI.openUtility();
                    let result = response.getReturnValue();
                    console.log(result);
                    component.set('v.Name', result.Name);
                    component.set('v.myVal', result.Body);
                    component.set('v.Subject', result.Subject);
                    if (result.Attachments !== '') {
                        component.set('v.showAttachment', true);
                        let attList = [];
                        attList = JSON.parse(result.Attachments);
                        let listReturn = [];
                        attList.forEach(function (att) {
                            let attachFile = {};
                            attachFile.Name = att.nameFile;
                            attachFile.Id = att.Id;
                            attachFile.file = att.file;
                            attachFile.UrlFile = att.urlFile;
                            if (attachFile.Name.endsWith('.xls')) {
                                attachFile.Icon = 'doctype:excel';
                            } else if (attachFile.Name.endsWith('.zip')) {
                                attachFile.Icon = 'doctype:zip';
                            } else if (attachFile.Name.endsWith('.pdf')) {
                                attachFile.Icon = 'doctype:pdf';
                            } else {
                                attachFile.Icon = 'doctype:attachment';
                            }
                            listReturn.push(attachFile)
                        });
                        component.set('v.AttachmentList', listReturn);
                    }
                    console.log('List', component.get('v.AttachmentList'));
                    component.set('v.AddressTO', result.TO);
                    component.set('v.AddressCC', result.CC);
                    component.set('v.AddressFrom', result.FROM);

                } else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            this.showToast('Error.', 'Error. Please check it', 'error', null);
                            component.set("v.showSpinner", false);
                        }
                    } else {
                        console.log("Unknown Error");
                    }
                }
            });
            $A.enqueueAction(action);
        },

        showToast: function (title, message, type, icon) {
            let toastEvent = $A.get('e.force:showToast');
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
    }
);