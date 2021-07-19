/**
 * Created by max1m on 25.11.20.
 */

({ doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        let action = component.get("c.getOpportunity");

        console.log(component.get("v.recordId"));
        action.setParams({
            billId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let res = response.getReturnValue();
                console.log("SUCCESS");
                console.log(res);

                console.log(res.next_date__c);
                let dateNext = new Date(res.next_date__c);
                console.log(dateNext);
                //сomponent.set('v.NextDate', dateNext);
                component.set('v.Repeat', res.repeat_in_x_months__c);
                component.set('v.RecurringBilling', res.Recurring_billing_generation__c);
                component.set('v.showButton', false);
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