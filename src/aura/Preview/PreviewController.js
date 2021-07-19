/**
 * Created by max1m on 16.04.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);

        let action = component.get("c.previewInvoice");
        action.setParams({
            invoiceId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();

            console.log(state);

            if (state === "SUCCESS") {

                let res = response.getReturnValue();
                if (res.Status === 'ERROR') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error.',
                        message: 'ERROR.',
                        duration: '2000',
                        key: null,
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();

                } else {
                    let invoiceId = res.urlInvoice;

                    window.open(invoiceId, '_blank');
                    component.set("v.showSpinner", false);
                    $A.get("e.force:closeQuickAction").fire();
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
                component.set("v.showSpinner", false);
            }
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