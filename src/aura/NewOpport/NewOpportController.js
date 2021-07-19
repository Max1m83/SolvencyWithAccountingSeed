({
    doInit: function (component) {

        component.set('v.showSpinner', true);
        let today = new Date();
        let date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        component.set("v.CloseDate", date);
        let action = component.get('c.getAccount');
        action.setParams({
            StringEmail: ''
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("SUCCESS getIdAccount");
                let myMap = new Map();
                myMap = response.getReturnValue();
                console.log(myMap);

                if (myMap.Price !== 'No') {
                    component.set("v.myPriceBookId", myMap.Price[0]);
                }

                component.set("v.Activity", myMap.Activity);
                component.set("v.selectedActivity", 'Active');
                component.set("v.Stage", myMap.Stage);
                component.set("v.selectedStage", 'In contact');
                component.set("v.Source", myMap.Source);
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

    save: function (component, event, helper) {

        component.set('v.showSpinner', true);
        var newOppId;
        var opp = component.get("v.opportunity");
        opp.Complexity__c = component.get("v.selectedComplexity");
        opp.Amount = component.get("v.selectedAmount");
        opp.Name = component.get("v.selectedName");
        opp.StageName = component.get("v.selectedStage");
        opp.Activity_Status__c = component.get("v.selectedActivity");
        opp.Source__c = component.get("v.selectedSource");
        opp.Timeline_Quarter__c = component.get("v.selectedTimelineQuarter");
        opp.Pricebook2Id = component.get("v.myPriceBookId");
        opp.AccountId = component.get("v.myAccId");
        opp.Quarter__c = component.get("v.selectedQuarter");
        opp.Years__c = component.get("v.selectedYears");

        console.log('Save');

        var action = component.get("c.saveOpportunity");
        action.setParams({
            "opp": opp,
            dateClose: component.get("v.CloseDate"),
            multiPicklist: component.get("v.defaultOptions")
        });
        action.setCallback(this, function () {
            var state = action.getState();
            console.log(action.getState());
            if (state == 'SUCCESS') {
                console.log('SUCCESS Save');
                newOppId = action.getReturnValue();
                console.log(newOppId);
                if (newOppId === 'Invalid Account') {

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid Account entered, please check."
                    });
                    toastEvent.fire();

                } else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": newOppId
                    });
                    navEvt.fire();
                }
                component.set('v.showSpinner', false);

            } else if (state === 'ERROR') {
                console.log('ERROR GET');
                console.log(action);
                component.set('v.showSpinner', false);
                var errors = action.getError();
                console.log(action.getError());
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    } else {
                        console.log('Unknown error');
                    }
                }
            } else {
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);

    },
    cancel: function (component, event, helper) {
        //this.parent.location.href = '/lightning/r/Opportunity/' + newOppId + '/view';
        // window.location.href = '/lightning/o/Opportunity/list?filterName=Recent';

        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Opportunity"
        });
        homeEvt.fire();
    }
})