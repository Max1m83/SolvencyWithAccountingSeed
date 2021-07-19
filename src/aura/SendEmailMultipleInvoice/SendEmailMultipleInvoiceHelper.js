({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.GetEmailMultipleBilling");

        action.setParams({
            groupIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            console.log('ffff');
            let state = response.getState();
            console.log('state');

            if (state === "SUCCESS") {
                let res = response.getReturnValue();
                console.log(res);
                if (res.Status === 'Success') {
                    console.log(res.Status);
                    let emailNameTemplate = res.Template;
                    if (emailNameTemplate === 'Not') {
                        this.showToast('Error!', 'The email template name was not filled in the Opportunity or an invalid name was entered.', 'error', null);
                    } else if (emailNameTemplate === 'More') {
                        this.showToast('Error!', 'There are many templates with the specified email template name.', 'error', null);
                    } else {
                        component.set('v.myVal', res.Body);
                        component.set('v.Subject', res.Subject);
                        component.set('v.AddressFrom', res.FROM);
                        component.set('v.AddressTO', res.TO);
                        component.set('v.AddressCC', res.CC);

                        if (res.Attachments !== '') {

                            console.log(res.Attachments);

                            component.set('v.showAttachment', true);
                            let attList = [];
                            attList = JSON.parse(res.Attachments);
                            let listReturn = [];
                            attList.forEach(function (att) {
                                let attachFile = {};
                                attachFile.Name = att.nameFile;
                                attachFile.UrlFile = att.urlFile;
                                console.log(attachFile);

                                if (attachFile.Name.endsWith('.xls')) {
                                    attachFile.Icon = 'doctype:excel';
                                } else if (attachFile.Name.endsWith('.zip')) {
                                    attachFile.Icon = 'doctype:zip';
                                } else if (attachFile.Name.endsWith('.pdf')) {
                                    attachFile.Icon = 'doctype:pdf';
                                } else {
                                    attachFile.Icon = 'doctype:attachment';
                                }
                                listReturn.push(attachFile);
                                console.log(listReturn);
                            });
                            console.log('F');
                            component.set('v.AttachmentList', listReturn);
                            console.log('F1');
                        }
                        console.log('ddd');
                        component.set("v.showSpinner", false);
                    }
                } else if (res.Status === 'No Customer') {
                    this.showToast('The email was not sent.', 'The Customer is not selected.', 'error', null);
                } else if (res.Status === 'No Billing') {
                    this.showToast('The email was not sent.', 'The Contact group haven`t billings for sending.', 'error', null);
                } else if (res.Status === 'Error') {
                    this.showToast('Error!', 'Error.', 'error', null);
                }
                component.set("v.showSpinner", false);

            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    save: function (component, event, helper) {

        component.set("v.showSpinner", true);

        let listReturn = component.get("v.AttachmentList");
        let returnList = [];
        listReturn.forEach(function (att) {
            returnList.push(att.UrlFile);
        });

        let action = component.get("c.SendEmailWithMultipleBilling");
        action.setParams({
            groupIds: component.get("v.recordId"),
            Body: component.get("v.myVal"),
            Subject: component.get("v.Subject"),
            urls: returnList
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === "SUCCESS") {

                let res = response.getReturnValue();

                if (res === 'No Template') {
                    this.showToast('The email was not sent.', 'The email template is not selected correctly, please check it.', 'error', null);
                } else if (res === 'Not Billing to be Sent') {
                    this.showToast('The email was not sent.', 'Not attached invoices to the sending.', 'error', null);
                } else if (res === 'Error') {
                    this.showToast('The email was not sent.', 'The email failed to send.', 'error', null);
                } else if (res === 'No Account') {
                    this.showToast('Error.', 'Do not have an Account', 'error', null);
                } else if (res === 'Success') {
                    this.showToast('Success!', 'The email was sent.', 'success', null);

                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId")
                    });
                    navEvt.fire();

                } else {
                    this.showToast('The email was not sent.', 'Error. Please check it', 'error', null);
                }

                component.set("v.showSpinner", false);

            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    cancel: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();

        component.set("v.showSpinner", false);
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