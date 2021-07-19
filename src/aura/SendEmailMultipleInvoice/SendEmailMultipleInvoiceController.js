({
    doInit: function (component, event, helper) {

        helper.doInit(component, event, helper);
        console.log('doInt');
    },
    save: function (component, event, helper) {

        helper.save(component, event, helper);
    },
    cancel: function (component, event, helper) {

        helper.cancel(component, event, helper);
    }
});