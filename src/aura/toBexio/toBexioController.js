/**
 * Created by max1m on 26.03.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.createPDF");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/newPage"
                });
                urlEvent.fire();

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