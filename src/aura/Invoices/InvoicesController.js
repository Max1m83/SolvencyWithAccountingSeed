/**
 * Created by max1m on 19.08.20.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);

        let action = component.get("c.getInvoiceOngoing");
        action.setParams({
            oppIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {

                component.set("v.ongoingBusiness", 'https://solvencyanalytics--sandboxopp.lightning.force.com/lightning/r/Ongoing_Business__c/a1Y1j000000ggGUEAY/view');
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
    }
});