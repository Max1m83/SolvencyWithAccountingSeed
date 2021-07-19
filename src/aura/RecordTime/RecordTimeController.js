/**
 * Created by max1m on 14.06.21.
 */

({
    doInit: function (component, event, helper) {
        helper.doInit(component);
    },
    cancel: function (component, event, helper) {
        helper.cancel();
    },
    save: function (component, event, helper) {
        helper.save(component);
    },
    changeValue: function (component, event, helper) {
        helper.changeValue(component);
    }
});