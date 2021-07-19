/**
 * Created by max1m on 14.06.21.
 */

({
    doInit: function (component) {

        component.set("v.showSpinner", true);
        let action = component.get("c.getDate");
        action.setParams({
            oppId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let res = response.getReturnValue();
                if (res.Status === 'Success') {
                    component.set("v.userId", res.UserId);
                    //component.set("v.opportunityName", res.Opportunity);
                    component.set("v.opportunityName", res.IdOpp);
                    this.defaultData(component);
                    component.set("v.billable", true);
                } else {
                    console.log("Error message: " + 'Not Opportunity');
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    cancel: function() {
        this.closedActionPanel();
    },
    defaultData: function(component) {

        let today = new Date();
        let monthDay = today.getMonth() + 1;
        let yearsDay = today.getFullYear();

        if (monthDay === 12) {
            monthDay = 1;
            yearsDay++;
        }

        let date = yearsDay + '-' + monthDay + '-' + today.getDate();
        component.set("v.recordDate", date);
        //component.set("v.kindOfWork", '');
    },
    save:function (component) {

        component.set("v.showSpinner", true);
       let opportunity = {};
        opportunity.userId = component.get("v.userId");
        opportunity.opportunityName = component.get("v.opportunityName");
        opportunity.Date_of_work__c = component.get("v.recordDate");
        opportunity.Number_of_hours__c = component.get("v.numbersHours");
        opportunity.Description__c = component.get("v.description");
        opportunity.Billable__c = component.get("v.billable");
        opportunity.Kind_of_work__c = component.get("v.kindOfWork");
        opportunity.Id = component.get("v.recordId");
        console.log(opportunity);

        let action = component.get("c.saveDate");
        action.setParams({
            opportunity: opportunity
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let res = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                this.closedActionPanel();
                this.showToast('Success!', 'The Record Time added to the Opportunity.', 'success', null);
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    changeValue: function (component){
        if(component.get("v.billable")) {
            component.set("v.billable", false);
        } else {
            component.set("v.billable", true);
        }
    },
    closedActionPanel: function() {
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
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