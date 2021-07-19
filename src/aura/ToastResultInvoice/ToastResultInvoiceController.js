/**
 * Created by max1m on 05.05.21.
 */

({
    doInit: function (component, event, helper) {

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
            helper.getStatus(component, event, eventReceived)
        }))
            .then(subscription => {
                // Subscription response received.
                // We haven't received an event yet.
                console.log('Subscription request sent to: ', subscription.channel);
                // Save subscription to unsubscribe later
                component.set('v.subscription', subscription);
            });
    },
    closed: function (component, event, helper) {
        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();
    }
})
;