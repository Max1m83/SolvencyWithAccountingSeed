({
    doInit: function (component) {

        component.set('v.showSpinner', true);
        let today = new Date();
        let date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        component.set("v.CloseDate", date);
        component.set("v.selectedName", component.get("v.subject"));
        component.set("v.defaultOptions", 'Regulatory Reporting');
        component.set("v.emailAddress", component.get("v.people.from.email"));
        // component.set("v.emailAddressAccount", component.get("v.people.from.email"));
        // component.set("v.selectedNameAccount", component.get("v.subject"));
        console.log('################');
        console.log(component.get("v.people.from.email"));

        let action = component.get('c.getAccount');
        action.setParams({
            StringEmail: component.get("v.people.from.email")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('Response');
                console.log(response.getReturnValue());
                // this.opportunityTab(component, response.getReturnValue());
                console.log("SUCCESS getIdAccount");
                var myMap = new Map();
                myMap = response.getReturnValue();

                if (myMap.Price[0] !== 'No') {
                    component.set("v.myPriceBookId", myMap.Price[0]);
                }
                if (myMap.Account[0] !== 'No') {
                    component.set("v.myAccId", myMap.Account[0]);
                } else if (myMap.Account[0] === 'No') {
                    console.log('No Account');
                    component.set("v.myAccId", '');
                    component.set("v.showAccount", true);
                    component.set("v.showOpportunity", false);
                } else {
                    component.set("v.myAccId", '');
                }

                component.set("v.Activity", myMap.Activity);
                //component.set("v.myAccId", myMap.Account[0]);
                component.set("v.selectedActivity", 'Active');
                component.set("v.Stage", myMap.Stage);
                component.set("v.selectedStage", 'In contact');
                component.set("v.SourceValue", myMap.Source);
                component.set("v.selectedSource", 'None');
                component.set('v.showSpinner', false);

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
    },

    // opportunityTab: function (component, opportunity) {
    //
    //     var myMap = new Map();
    //     myMap = opportunity;
    //
    //     if (myMap.Price[0] !== 'No') {
    //         component.set("v.myPriceBookId", myMap.Price[0]);
    //     }
    //     if (myMap.Account[0] !== 'No') {
    //         component.set("v.myAccId", myMap.Account[0]);
    //     } else if (myMap.Account[0] === 'No') {
    //         console.log('No Account');
    //         component.set("v.myAccId", '');
    //     } else {
    //         component.set("v.myAccId", '');
    //     }
    //
    //     component.set("v.Activity", myMap.Activity);
    //     //component.set("v.myAccId", myMap.Account[0]);
    //     component.set("v.selectedActivity", 'Active');
    //     component.set("v.Stage", myMap.Stage);
    //     component.set("v.selectedStage", 'In contact');
    //     component.set("v.SourceValue", myMap.Source);
    //     component.set("v.selectedSource", 'None');
    //     component.set('v.showSpinner', false);
    // }
});