/**
 * Created by max1m on 31.08.20.
 */

({
    doInit: function (component) {

        component.set('v.showSpinner', true);
        var action = component.get('c.getURL');
        action.setParams({opportunityId: component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Success");

                var myMap = new Map();
                myMap = response.getReturnValue();
                console.log(myMap);

                component.set("v.Standard", myMap.Standard);
                component.set("v.Client", myMap.Client);

                if (myMap.Record === 'Sales') {
                    component.set("v.showContacts", true);
                } else {
                    component.set("v.showContacts", false);
                }


                component.set('v.showSpinner', false);
            } else if (state === "ERROR") {
                console.log("Error");
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    }
});