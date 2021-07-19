({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        component.set("v.showBeforeBilling", false);
        component.set("v.showAfterBilling", false);
        let today = new Date();
        let date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        component.set("v.InvoiceDate", date);
        let billing;

        let action = component.get("c.getInvoice");
        action.setParams({
            oppIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {

                billing = response.getReturnValue();
                component.set("v.myOpp", billing.Opportunity[0]);
                //component.set("v.myLedger", billing.Ledger[0]);

                let accounts = [];
                let i = 0;
                for (let keyBilling in billing['Accounts']) {

                    let account = {};
                    account.Id = i;
                    account.label = billing['Accounts'][keyBilling];
                    if (i === 0) {
                        component.set("v.selectedValue", billing['Accounts'][i]);
                    }
                    accounts.push(account);
                    i++;
                }

                component.set("v.allAccount", accounts);

                let reports = [];
                for (let keyBilling in billing['ReportsValue']) {

                    let report = {};
                    report.value = billing['ReportsValue'][keyBilling];
                    report.label = billing['ReportsValue'][keyBilling];
                    if (billing['ReportsValue'][keyBilling] === billing['NameReports'][0]) {
                        report.selected = true;
                        component.set("v.productName", billing['NameReports'][0]);
                    }
                    reports.push(report);
                }
                component.set("v.ReportValue", reports);

                let periods = [];
                for (let keyPeriod in billing['Period']) {

                    let period = {};
                    period.value = billing['Period'][keyPeriod];
                    period.label = billing['Period'][keyPeriod];
                    if (billing['Period'][keyPeriod] === billing['PeriodValue'][0]) {
                        period.selected = true;
                        component.set("v.period", billing['PeriodValue'][0]);
                    }
                    periods.push(period);
                }
                component.set("v.PeriodValue", periods);

                let emailGroup = [];
                let emailDefault = [];

                for (let keyBillingEmails in billing['Contacts']) {

                    let email = {};
                    email.value = billing['Contacts'][keyBillingEmails];
                    email.label = billing['Contacts'][keyBillingEmails];
                    emailGroup.push(email);
                    emailDefault.push(email.label);
                }
                component.set("v.ListOfEmailGroup", emailGroup);
                if (emailDefault.length === 1) {
                    console.log('ffff');
                    component.set("v.defaultOptions", emailDefault);
                }

                let products = [];
                let defaultproduct = [];

                for (let keyBillingEmails in billing['Product']) {

                    let product = {};
                    product.value = billing['Product'][keyBillingEmails];
                    product.label = billing['Product'][keyBillingEmails];
                    defaultproduct.push(product.label);
                    products.push(product);
                }
                component.set("v.ListOfProduct", products);
                defaultproduct.sort();
                component.set("v.selectProducts", defaultproduct.sort());
                component.set("v.showSpinner", false);
                component.set("v.showBeforeBilling", true);

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
        let products = [];
        let emailsGet = [];
        let productsGet = [];

        emails = component.get("v.defaultOptions");
        products = component.get("v.selectProducts");
        map.Account = component.get("v.selectedValue");
        map.Opportunity = component.get("v.myOpp");
        map.Ledger = component.get("v.myLedger");
        map.InvoiceDate = component.get("v.InvoiceDate");
        map.Report = component.get("v.productName");
        map.Period = component.get("v.period");

        for (let keyEmails in emails) {
            emailsGet.push(emails[keyEmails]);
        }

        for (let keyEmails in products) {
            productsGet.push(products[keyEmails]);
        }

        let action = component.get("c.SaveBilling");

        action.setParams({
            bill: map,
            contacts: emailsGet,
            products: productsGet
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var billingId;

            if (state === "SUCCESS") {

                console.log("SUCCESS Save");
                billingId = action.getReturnValue();
                console.log(billingId);

                if (billingId === 'Not Account') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Enter the Account."
                    });
                    toastEvent.fire();
                    component.set('v.showSpinner', false);

                } else if (billingId === 'Not Period') {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Enter the Accounting Period."
                    });
                    toastEvent.fire();
                    component.set('v.showSpinner', false);
                }
                else {

                    component.set("v.showSpinner", false);
                    component.set("v.showBeforeBilling", false);
                    component.set("v.showAfterBilling", true);

                    // let urlEvent = $A.get("e.force:navigateToURL");
                    // urlEvent.setParams({
                    //     "url": "/one/one.app#/alohaRedirect/apex/AcctSeed__MassAddEditBillingLine?Id=" + billingId
                    // });
                    // urlEvent.fire();
                    // component.set("v.showSpinner", false);

                    // let urlEvent = $A.get("e.force:navigateToURL");
                    // urlEvent.setParams({
                    //     "url": "/one/one.app#/alohaRedirect/apex/BillingsCreate?Id=" + billingId
                    // });
                    // urlEvent.fire();
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": billingId
                    });
                    navEvt.fire();

                    component.set("v.showSpinner", false);

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
    sorting: function (component, event, helper) {
        let product = component.get("v.selectProducts");
        product.sort();
        component.set("v.selectProducts", product);
    }
})