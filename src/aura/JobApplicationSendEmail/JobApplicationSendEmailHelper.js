/**
 * Created by max1m on 28.01.21.
 */

(
    {
        getSettingEmail: function (component, event, ReceivedEvent) {
            console.log('Status', ReceivedEvent.data.payload.About__c);
            if (ReceivedEvent.data.payload.About__c === 'Email') {
                console.log('Email');
                this.getEmail(component, event, ReceivedEvent);
            } else {
                this.showToast('Error.', 'You can\'t change the Stage. You can only change the stage on the Job Application with Approval status.', 'error', null);
                $A.get("e.force:refreshView").fire();
            }
        },
        getEmail: function (component, event, ReceivedEvent) {

            component.set('v.showSpinner', true);
            component.set('v.showEvent', false);
            component.set('v.isSend', false);
            component.set('v.showAttachment', false);
            component.set('v.statusJob', ReceivedEvent.data.payload.Status__c);
            component.set('v.oldStatusJob', ReceivedEvent.data.payload.Old_Status__c);
            component.set('v.jobAppIds', ReceivedEvent.data.payload.jobId__c);
            this.defaultDate(component);

            let action = component.get('c.GetEmail');
            action.setParams({
                status: component.get('v.statusJob'),
                oldStatus: component.get('v.oldStatusJob'),
                jobAppIds: component.get('v.jobAppIds'),
            });
            action.setCallback(this, function (response) {

                let state = response.getState();
                console.log('Callout', state);

                if (state === 'SUCCESS') {
                    let res = response.getReturnValue();
                    console.log(res);
                    if (res.Status === 'SUCCESS') {
                        console.log('SUCCESS');
                        let utilityAPI = component.find('utilitybar');
                        utilityAPI.openUtility();

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

                        } else {

                            console.log('No Attachment');
                        }
                        component.set('v.AddressCC', res.CC);
                        component.set('v.Status', res.Job);
                        component.set('v.Name', res.CandidateName);
                        component.set('v.myVal', res.Body);
                        component.set('v.Subject', res.Subject);
                        component.set('v.AddressFrom', res.FROM);
                        component.set('v.AddressTO', res.TO);
                        component.set("v.showEvent", true);
                    } else {
                        this.showToast('Error.', response.Status, 'error', null);
                    }

                    component.set('v.showSpinner', false);

                } else if (state === 'ERROR') {
                    this.showToast('Error.', 'Error. Please check it', 'error', null);
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error message: ' + errors[0].message);
                        }
                    } else {
                        console.log('Unknown Error');
                    }
                } else {
                    this.showToast('Error.', 'Error. Please check it', 'error', null);
                }

                component.set('v.showEvent', true);
                component.set('v.showSpinner', false);

            });
            $A.enqueueAction(action);
        },
        defaultDate: function (component) {

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

        schedulerCreate: function (component, event, ReceivedEvent) {

            component.set('v.showSpinner', true);

            console.log(component.get('v.DateStart'));
            console.log('schedulerCreate');

            let action = component.get('c.scheduler');

            action.setParams({
                jobAppIds: component.get('v.jobAppIds'),
                status: component.get('v.statusJob'),
                Body: component.get('v.myVal'),
                Subject: component.get('v.Subject'),
                nameCandidate: component.get('v.Name'),
                startDay: component.get('v.DateStart'),
                endDay: component.get('v.DateEnd'),
                cc: component.get('v.AddressCC')
            });
            action.setCallback(this, function (response) {
                let state = response.getState();

                if (state === 'SUCCESS') {

                    let res = response.getReturnValue();

                    if (res === 'Success') {
                        this.showToast('Success!', 'The sending of Email is Scheduled.', 'success', null);
                    } else {
                        this.showToast('Error.', 'Error. Please check it', 'error', null);
                    }
                    let utilityAPI = component.find('utilitybar');
                    utilityAPI.minimizeUtility();
                }

                component.set('v.showSpinner', false);
            });
            $A.enqueueAction(action);
        },

        send: function (component, event, ReceivedEvent) {

            component.set('v.showSpinner', true);
            component.set('v.isSend', false);
            component.set('v.showEvent', false);
            component.set('v.showAttachment', false);
            this.showToast('Success!', 'Email is sending.', 'success', null);
            let action = component.get('c.SendEmail');
            action.setParams({
                jobAppIds: component.get('v.jobAppIds'),
                status: component.get('v.statusJob'),
                Body: component.get('v.myVal'),
                Subject: component.get('v.Subject'),
                oldStatus: component.get('v.oldStatusJob'),
                ccEmails: component.get('v.AddressCC')
            });
            action.setCallback(this, function (response) {

                let state = response.getState();

                if (state === 'SUCCESS') {
                    let res = response.getReturnValue();

                    if (res === 'SUCCESS') {
                        this.showToast('Success!', 'Go to Send emails tab', 'success', null);
                        let utilityAPI = component.find('utilitybar');
                        utilityAPI.minimizeUtility();
                    } else {
                        this.showToast('Error.', response.Status, 'error', null);
                    }

                    component.set('v.showSpinner', false);

                } else if (state === 'ERROR') {
                    this.showToast('Error.', 'Error. Please check it', 'error', null);
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error message: ' + errors[0].message);
                        }
                    } else {
                        console.log('Unknown Error');
                    }
                } else {
                    this.showToast('Error.', 'Error. Please check it', 'error', null);
                }
                component.set('v.showSpinner', false);
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