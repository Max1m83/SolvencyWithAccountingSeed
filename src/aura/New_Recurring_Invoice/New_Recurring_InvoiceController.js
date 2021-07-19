/**
 * Created by max1m on 26.11.20.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let billing;
        let today = new Date();
        let monthDay = today.getMonth() + 1;
        let yearsDay = today.getFullYear();

        if (monthDay === 12) {
            monthDay = 1;
            yearsDay++;
        }

        let date = yearsDay + '-' + monthDay + '-' + today.getDate();
        component.set("v.InvoiceDate", date);
        component.set("v.createInvoice", true);

        let action = component.get("c.getRecurringInvoice");
        action.setParams({
            invoiceId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                billing = response.getReturnValue();

                let accounts = [];
                let i = 0;
                for (let keyBilling in billing['Accounts']) {

                    let account = {};
                    account.Id = i;
                    account.label = billing['Accounts'][keyBilling];
                    if (i === 0) {
                        component.set("v.selectedAccount", billing['Accounts'][i]);
                    }
                    accounts.push(account);
                    i++;
                }

                component.set("v.allAccount", accounts);
                component.set("v.selectFrequency", billing['Frequency'][0]);

                let statusList = [];
                let j = 0;
                for (let keyBilling in billing['Status']) {

                    let status = {};
                    status.Id = j;
                    status.label = billing['Status'][keyBilling];
                    if (j === 0) {
                        component.set("v.selectStatus", billing['Status'][j]);
                    }
                    statusList.push(status);
                    j++;
                }

                component.set("v.ListStatus", statusList);

                let emailGroup = [];

                for (let keyBillingEmails in billing['Contacts']) {

                    let email = {};
                    email.value = billing['Contacts'][keyBillingEmails];
                    email.label = billing['Contacts'][keyBillingEmails];
                    emailGroup.push(email);
                }
                component.set("v.ListOfEmailGroup", emailGroup);
                component.set("v.selectName", billing['Name'][0]);
                component.set("v.showSpinner", false);

            } else if (state === "ERROR") {
                var errors = response.getError();
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

        component.set('v.showSpinner', true);

        let map = {};
        let emails = [];
        let emailsGet = [];

        emails = component.get("v.defaultListOfEmailGroup");
        map.Account = component.get("v.selectedAccount");
        map.Billing = component.get("v.recordId");
        map.InvoiceDate = component.get("v.InvoiceDate");
        map.Status = component.get("v.selectStatus");
        map.Frequency = component.get("v.selectFrequency");
        map.Name = component.get("v.selectName");
        map.CreateInvoice = component.get("v.createInvoice");

        for (let keyEmails in emails) {
            emailsGet.push(emails[keyEmails]);
        }

        let action = component.get("c.SaveBilling");

        action.setParams({
            bill: map,
            contacts: emailsGet
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            let billingId;

            if (state === "SUCCESS") {

                console.log("SUCCESS Save");

                billingId = action.getReturnValue();
                console.log(action.getReturnValue());

                if (billingId === 'Not Account') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Enter the Account."
                    });
                    toastEvent.fire();
                    component.set('v.showSpinner', false);

                } else {

                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": billingId
                    });
                    navEvt.fire();
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
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
        console.log(component.get("v.InvoiceDate"));

    }
});