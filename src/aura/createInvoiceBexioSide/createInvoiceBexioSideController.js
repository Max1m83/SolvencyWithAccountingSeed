({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);

        let action = component.get("c.previewInvoiceBexio");
        action.setParams({
            invoiceIds: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {

                let res = response.getReturnValue();

                if (res.Status === 'Not Invoices') {

                    this.showToast('Error.', 'The invoice was not found, check the data.', 'error', null);

                } else {
                    let invoiceId = res.BexioId;
                    let urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "https://office.bexio.com/index.php/kb_invoice/show/id/" + invoiceId
                    });
                    urlEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.showSpinner", false);
                    $A.get('e.force:refreshView').fire();
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