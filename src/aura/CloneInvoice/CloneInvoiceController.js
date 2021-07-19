/**
 * Created by max1m on 14.04.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.cloneInvoice");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {

                let result = response.getReturnValue();

                if (result === 'Not Invoice') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error.',
                        message: 'Error.',
                        duration: '2000',
                        key: null,
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();

                } else if (result === 'not Period') {

                    console.log('not Period');
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error.',
                        message: 'The According period is not found, please, create the According period and try again.',
                        duration: '2000',
                        key: null,
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();

                    $A.get("e.force:closeQuickAction").fire();
                } else {

                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
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
    }
});