({
    doInit: function (component, event, helper) {

        helper.doInit(component, event, helper);
    },

    handlePeopleChange: function (component, event, helper) {

        helper.doInit(component, event, helper);
    },
    handleChange: function (component, event, helper) {
        let lookupId = event.getParam("value")[0];
        component.set("v.myAccId", lookupId);
    },

    save: function (component, event, helper) {

        component.set('v.showSpinner', true);
        let newOppId;
        let opp = component.get("v.opportunity");
        opp.Complexity__c = component.get("v.selectedComplexity");
        opp.Amount = component.get("v.selectedAmount");
        opp.Name = component.get("v.selectedName");
        opp.StageName = component.get("v.selectedStage");
        opp.Activity_Status__c = component.get("v.selectedActivity");
        opp.Source__c = component.get("v.selectedSource");
        opp.Timeline_Quarter__c = component.get("v.selectedTimelineQuarter");
        opp.Pricebook2Id = component.get("v.myPriceBookId");
        opp.AccountId = component.get("v.myAccId");

        let action = component.get("c.saveOpportunity");
        action.setParams({
            opp: opp,
            dateClose: component.get("v.CloseDate"),
            multiPicklist: component.get("v.defaultOptions"),
            emailAddress: component.get("v.emailAddress")
        });
        action.setCallback(this, function () {
            var state = action.getState();
            if (state === 'SUCCESS') {
                console.log('SUCCESS Save');
                newOppId = action.getReturnValue();

                if (newOppId === 'Invalid Account') {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Enter the Account."
                    });
                    toastEvent.fire();

                } else {
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": newOppId
                    });
                    navEvt.fire();
                }
                component.set('v.showSpinner', false);
            } else if (state === 'ERROR') {
                component.set('v.showSpinner', false);
                let errors = response.getError();
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
    newAccount: function (component, event, helper) {

        console.log('saveAccount');
        component.set('v.showSpinner', true);

        let acc = component.get("v.account");
        acc.Name = component.get("v.selectedNameAccount");
        acc.Account_Email__c = component.get("v.emailAddressAccount");
        acc.ParentId = component.get("v.parentAccount");
        acc.Company_name__c = component.get("v.companyName");
        console.log(acc);

        let action = component.get("c.saveAccount");
        action.setParams({
            account: acc
        });
        action.setCallback(this, function () {
            console.log(action.getState());
            let state = action.getState();
            if (state === 'SUCCESS') {

                console.log(action.getReturnValue());

                helper.opportunityTab(component, action.getReturnValue());
                // console.log('dddd');
                // component.set('v.showSpinner', false);
            } else if (state === 'ERROR') {
                component.set('v.showSpinner', false);
                let errors = response.getError();
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
    }
})