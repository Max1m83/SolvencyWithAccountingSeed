/**
 * Created by max1m on 25.11.20.
 */

({
    doInit: function (component, event, helper) {

        helper.doInit(component, event, helper);

    },
    handleChange: function (component, event, helper) {

        component.set('v.showButton', true);

        if (component.get('v.RecurringBilling')) {
            component.set('v.RecurringBilling', false);
        } else {
            component.set('v.RecurringBilling', true);
        }
    },
    save: function (component, event, helper) {

    }
});