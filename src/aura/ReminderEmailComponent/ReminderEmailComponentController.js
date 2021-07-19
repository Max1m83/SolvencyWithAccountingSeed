({
    doInit: function (component, event, helper) {

        console.log('doInt');

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

            if (window.location.href.includes('Reminder_email__c')) {
                helper.getEmail(component, event, eventReceived)
            }
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

        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();

        console.log('Send');

        console.log(component.get('v.AttachmentList'));

        let action = component.get('c.sendEmail');
        action.setParams({
            idReminder: component.get('v.idReminder'),
            Body: component.get('v.myVal'),
            Subject: component.get('v.Subject'),
            toAddress: component.get('v.AddressTO'),
            ccAddress: component.get('v.AddressCC'),
            attach: component.get('v.AttachmentList')
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log('SUCCESS SEND');
                let result = response.getReturnValue();
                if (result === 'Success') {
                    helper.showToast('Success!', 'Email sent.', 'success', null);
                } else {
                    helper.showToast('Error.', 'Error. Please check it', 'error', null);
                }
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('Cancel Send');
                helper.showToast('Error.', 'Error. Please check it', 'error', null);
            }
        });
        $A.enqueueAction(action);
    },

    cancel: function (component, event, helper) {
        component.set('v.showEvent', false);
        component.set('v.showAttachment', false);
        let utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();

        let action = component.get('c.cancelEmail');
        action.setParams({
            idReminder: component.get('v.idReminder'),
            status: component.get('v.oldStatusJob')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log('SUCCESS');
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('Cancel');

            }
        });
        $A.enqueueAction(action);
    }
});