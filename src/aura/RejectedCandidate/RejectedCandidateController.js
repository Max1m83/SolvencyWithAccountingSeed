/**
 * Created by max1m on 23.06.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.rejected");
        action.setParams({
            idJobApplication: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let status = response.getReturnValue();
                console.log(status);
                if (status === 'Success') {
                    helper.showToast('Success!', 'Candidate is Rejected', 'success', null);
                } else if (status === 'Approved') {
                    helper.showToast('Warning!', 'The candidate has already been approved earlier', 'info', null);
                } else if (status === 'Rejected') {
                    helper.showToast('Warning!', 'The candidate cannot be Rejected because it was previously Approve', 'info', null);
                } else {
                    helper.showToast('Error ', 'Candidate is Lost.', 'error', null);
                }
                helper.goToObject(component.get("v.recordId"));
                component.set("v.showSpinner", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast('Error message: ' + errors[0].message, 'Candidate is Lost.', 'error', null);
                        component.set("v.showSpinner", false);
                        helper.goToObject(component.get("v.recordId"));
                    }
                } else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
});