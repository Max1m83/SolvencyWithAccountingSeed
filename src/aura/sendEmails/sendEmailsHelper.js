({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.isSend', false);

        this.getDefaultDate(component);
        let action = component.get("c.createPDF");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {

                let res = response.getReturnValue();
                console.log(res);
                this.createPDF(component);
                component.set('v.isShowSendEmails', true);

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

    createPDF: function (component) {
        let action = component.get("c.GetEmail");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {

                let res = response.getReturnValue();
                console.log('!!!!!!!!!!!!!!!!!res++++++++++++++');
                console.log(res);
                // let emailNameTemplate = res.Template;
                let emailNameTemplate = res.EmailTemplateName;
                console.log('!!!!!!!!!!!!!!!!!res++++++++++++++');
                if (emailNameTemplate === 'Not') {
                    this.showToast('Error.', 'The email template name was not filled in the Opportunity or an invalid name was entered.', 'error', null);
                } else if (emailNameTemplate === 'More') {
                    this.showToast('Error.', 'There are many templates with the specified email template name.', 'error', null);
                }
                console.log(res.Emails_TO);

                let emailsTO = res.Emails_TO;
                let emailsTOList = emailsTO.split(';');
                let emailsTOListCorrect = emailsTOList.map(function (el) {
                    return el.trim();
                });
                let emailsTOString = [...new Set(emailsTOListCorrect)].join('; ').trimEnd();
                console.log(emailsTOString);

                let emailsCC = res.Emails_CC;
                let emailsCCList = emailsCC.split(';');
                let emailsCCListCorrect = emailsCCList.map(function (el) {
                    return el.trim();
                });
                let emailsCCString = [...new Set(emailsCCListCorrect)].join(';').trimEnd();

                component.set('v.myVal', res.Body);
                component.set('v.Subject', res.Subject);
                component.set('v.AddressFrom', res.FROM);
                component.set('v.AddressTO', res.TO);
                component.set('v.AddressCC', res.CC);
                component.set('v.accountName', res.AccountName);
                component.set('v.accountEmail', res.AccountEmail);
                component.set('v.emailTemplateName', res.EmailTemplateName);
                component.set('v.emailsCC', emailsCCString);
                component.set('v.emailsTO', emailsTOString);
                component.set('v.nameInvoice', res.NameInvoice);

                component.set("v.showSpinner", false);

                if (res.Attachments !== '') {
                    component.set('v.showAttachment', true);

                    let attList = [];
                    attList = JSON.parse(res.Attachments);
                    let listReturn = [];
                    attList.forEach(function (att) {
                        let attachFile = {};
                        attachFile.Name = att.nameFile;
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

        let action = component.get("c.SendEmail");
        action.setParams({
            invoiceIds: component.get("v.recordId"),
            Body: component.get("v.myVal"),
            Subject: component.get("v.Subject")
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === "SUCCESS") {

                console.log('Success');

                let res = response.getReturnValue();

                if (res === 'Not Approved') {

                    this.showToast('Error.', 'This invoice has not yet been verified and therefore cannot be sent.', 'error', null);

                } else {

                    this.showToast('Success!', 'The email was sent.', 'success', null);

                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId")
                    });
                    navEvt.fire();
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
        let action = component.get("c.cancelSendEmail");
        action.setParams({
            invoiceIds: component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === "SUCCESS") {

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

        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();

        component.set("v.showSpinner", false);
    },

    next: function (component, event, helper) {
        component.set('v.showSpinner', false);
        component.set('v.isShowSendEmails', false);
        component.set('v.isSend', true);
    },

    back: function (component, event, helper) {
        component.set('v.isSend', false);
        component.set('v.isShowSendEmails', true);
    },

    getDefaultDate: function (component) {
        //Friday
        let startDay = new Date();
        if (startDay.getDay() < 5) {
            startDay.setDate(startDay.getDate() + 5 - startDay.getDay());
        } else if (startDay.getDay() > 6) {
            startDay.setDate(startDay.getDate() + 6);
        }
        //Sunday
        let endDay = new Date();
        endDay.setDate(endDay.getDate() + 7 - endDay.getDay());

        let month;
        let dateString;
        let monthEnd;
        let dateStringEnd;

        let monthStart = startDay.getMonth() + 1;
        let monthFinish = endDay.getMonth() + 1;

        if (monthStart < 10) {
            month = '0' + monthStart;
        } else {
            month = monthStart;
        }

        if (startDay.getDate() < 10) {
            dateString = '0' + startDay.getDate();
        } else {
            dateString = startDay.getDate();
        }

        if (monthFinish < 10) {
            monthEnd = '0' + monthFinish;
        } else {
            monthEnd = monthFinish;
        }

        if (endDay.getDate() < 10) {
            dateStringEnd = '0' + endDay.getDate();
        } else {
            dateStringEnd = endDay.getDate();
        }

        let startDayString = startDay.getFullYear() + '-' + month + '-' + dateString + 'T17:00:00.789Z';
        let endDayString = endDay.getFullYear() + '-' + monthEnd + '-' + dateStringEnd + 'T17:00:00.789Z';
        component.set('v.DateStart', startDayString);
        component.set('v.DateEnd', endDayString);
    },

    schedulerInvoicesCreate: function (component, event, helper) {
        console.log(component.get('v.myVal'));
        console.log(component.get('v.Subject'));
        console.log(component.get('v.DateStart'));
        console.log(component.get('v.emailsCC'));
        console.log(component.get('v.emailsTO'));
        console.log('schedulerCreate');
        // component.set('v.showSpinner', false);

        let action = component.get('c.schedulerInvoices');
        action.setParams({
            body: component.get('v.myVal'),
            subject: component.get('v.Subject'),
            startDay: component.get('v.DateStart'),
            endDay: component.get('v.DateEnd'),
            accountEmail: component.get('v.accountEmail'),
            emailTemplateName: component.get('v.emailTemplateName'),
            invoiceId: component.get('v.recordId'),
            emailsCC: component.get('v.emailsCC'),
            emailsTO: component.get('v.emailsTO'),
            nameInvoice: component.get('v.nameInvoice')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let res = response.getReturnValue();
                if (res === 'Success') {
                    this.showToast('Success!', 'Sending an email is scheduled.', 'success', null);

                } else {
                    this.showToast('Error.', 'Response is failed', 'error', null);
                }
                // let utilityAPI = component.find('utilitybar');
                // utilityAPI.minimizeUtility();
                let navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId")
                });
                navEvt.fire();
                component.set('v.isSend', false);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
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
});