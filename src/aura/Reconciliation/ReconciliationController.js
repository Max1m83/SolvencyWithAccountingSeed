/**
 * Created by max1m on 04.05.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.updateAllInvoices");

        console.log('Start');

        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {
                if (res.Status === 'Success') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Update Invoices is start."
                    });
                    toastEvent.fire();

                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": "Update Invoices is working now."
                    });
                    toastEvent.fire();
                }
                let navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewName": 'All',
                    "scope": "Invoice__c"
                });
                navEvent.fire();
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