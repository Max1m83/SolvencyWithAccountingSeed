/**
 * Created by max1m on 08.10.20.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        component.set("v.idBilling", component.get("v.recordId"));
        let action = component.get("c.getEmailsGroup");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {

                let billing = response.getReturnValue();
                console.log(billing);
                console.log(state);

                let emailGroup = [];
                let emailDefault = [];

                for (let keyBillingEmails in billing['Group']) {

                    let email = {};
                    email.value = billing['Group'][keyBillingEmails];
                    email.label = billing['Group'][keyBillingEmails];
                    emailGroup.push(email);
                    emailDefault.push(email.label);
                }
                component.set("v.ListOfEmailGroup", emailGroup);
                if (emailDefault.length === 1) {
                    component.set("v.defaultOptions", emailDefault);
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
    add: function (component, event, helper) {

        component.set("v.showSpinner", true);
        component.set("v.idBilling", component.get("v.recordId"));

        let emails = [];
        let emailsGet = [];

        emails = component.get("v.defaultOptions");

        for (let keyEmails in emails) {
            emailsGet.push(emails[keyEmails]);
        }

        let action = component.get("c.updateBilling");
        action.setParams({
            invoiceIds: component.get("v.recordId"),
            namesGroup: emailsGet
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let res = response.getReturnValue();
                if (res === 'Success') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "This invoice was added."
                    });
                    toastEvent.fire();

                } else if (res === 'Not Approved') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "This invoice has not yet been verified and therefore cannot be sent."
                    });
                    toastEvent.fire();
                }
                else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Check all input data."
                    });
                    toastEvent.fire();
                }

                let navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.idBilling")
                });
                navEvt.fire();

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
    }
});