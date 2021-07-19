/**
 * Created by max1m on 05.05.21.
 */

({
    getStatus: function (component, event, ReceivedEvent) {

       //component.set('v.Status', ReceivedEvent.data.payload.Status__c);

       component.set('v.showEvent', false);

        let action = component.get('c.GetStatus');
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === 'SUCCESS') {
                let res = response.getReturnValue();
                component.set('v.showEvent', true);
                console.log('dddd');

                console.log(res);
                console.log('Invoice');
                console.log(res.Invoice);

                component.set('v.Status', 'Success');

                let result = [];

                res.Invoice.forEach(function(item){
                    console.log(item);
                    let invoice = {};
                    invoice.Name = item.Number;
                    invoice.Opp = item.Opp;
                    invoice.Prod = item.Prod;
                    invoice.Synch = item.Synch;
                    result.push(invoice)
                });
                component.set('v.columns', result);


                let utilityAPI = component.find('utilitybar');
                utilityAPI.openUtility();

                console.log(res);
                component.set('v.Status', res.Status);
                console.log('####');
                if (res.Status === 'Success') {
                    let toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        title: 'Success!',
                        message: 'Syncing completed successfully',
                        duration: '2000',
                        key: 'success',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                } else if(res.Status === 'Not Product') {
                    let toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        title: 'Success!',
                        message: 'Synchronization was completed successfully, but there are invoices in which you need to manually assign the Title or Opportunity or Account or Invoice Product.',
                        duration: '2000',
                        key: 'success',
                        type: 'warning',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                } else if (res.Status === 'Error') {
                    let toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        title: 'Error!',
                        message: 'The error occurred while syncing.',
                        duration: '2000',
                        key: 'success',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            } else if (state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    }
                } else {
                    console.log('Unknown Error');
                }
            } else {
            }

            component.set('v.showEvent', true);

        });
        $A.enqueueAction(action);
    }
});