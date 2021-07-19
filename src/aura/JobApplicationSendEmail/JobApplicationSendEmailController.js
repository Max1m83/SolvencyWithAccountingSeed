/**
 * Created by max1m on 28.01.21.
 */

({
    doInit: function (component, event, helper) {

        component.set('v.isSend', false);
        component.set('v.scheduler', false);
        console.log('doInit');

        // Invokes the subscribe method on the empApi component
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = component.find('channel').get('v.value');
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            helper.getSettingEmail(component, event, eventReceived)
        }))
            .then(subscription => {
                // Subscription response received.
                // We haven't received an event yet.
                console.log('Subscription request sent to: ', subscription.channel);
                // Save subscription to unsubscribe later
                component.set('v.subscription', subscription);
            });
    },
    send: function (component, event, helper) {
        helper.send(component, event, helper);
        component.set('v.isSend', false);
        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },

    cancel: function (component, event, helper) {
        component.set('v.showEvent', false);
        component.set('v.showAttachment', false);
        component.set('v.isSend', false);
        component.set('v.scheduler', false);
        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    },

    back: function (component, event, helper) {
        component.set('v.isSend', false);
        component.set('v.showEvent', true);
    },

    next: function (component, event, helper) {
        component.set('v.showSpinner', false);
        component.set('v.showEvent', false);
        component.set('v.isSend', true);
    },

    schedulerCreate: function (component, event, helper) {
        helper.schedulerCreate(component, event, helper);
    }
});