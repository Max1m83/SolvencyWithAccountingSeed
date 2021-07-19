/**
 * Created by max1m on 18.01.21.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.setLostReasonOpportunity");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let getMap = response.getReturnValue();
                console.log("getMap");
                console.log(getMap);
                let reasons = [];
                let i = 0;
                for (let keyBilling in getMap) {

                    let reason = {};
                    reason.Id = i;
                    reason.label = getMap[keyBilling];
                    if (i === 0) {
                        component.set("v.selectedValue", getMap[i]);
                        console.log(getMap[i]);
                        console.log('dddd');
                        console.log(component.get("v.selectedValue"));
                    }
                    reasons.push(reason);
                    i++;
                }
                component.set("v.allReason", reasons);
                component.set("v.showSpinner", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast('Error message: ' + errors[0].message, 'Opportunity is Lost.', 'error', null);
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
    save: function (component, event, helper) {
        console.log('save');
        component.set("v.showSpinner", true);

        let action = component.get("c.closedOpportunity");

        action.setParams({
            OppId: component.get("v.recordId"),
            reason: component.get("v.selectedValue")
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            let result;

            if (state === "SUCCESS") {
                console.log("SUCCESS Save");
                result = action.getReturnValue();
                if (result === 'SUCCESS') {
                    helper.showToast('Opportunity`s stage is changed.', 'Opportunity is Lost.', 'success', null);
                    component.set("v.showSpinner", false);
                    helper.goToObject(component.get("v.recordId"));
                    document.location.reload();
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast('Error message: ' + errors[0].message, 'Opportunity is Lost.', 'error', null);
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
    cancel: function (component, event, helper) {
        helper.goToObject(component.get("v.recordId"));
    }
});