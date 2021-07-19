/**
 * Created by max1m on 22.06.21.
 */

({
    doInit : function(component, event, helper){
        let pageReference = component.get("v.pageReference");
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            let recordId=pageReference.state.c__recordId;
            component.set("v.recordId",recordId);
            //Do whatever we want to do with record id
            component.set("v.showSpinner", true);

            let action = component.get("c.previewInvoice");
            action.setParams({
                invoiceId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                let state = response.getState();

                console.log(state);

                if (state === "SUCCESS") {

                    let res = response.getReturnValue();
                    if (res.Status === 'ERROR') {

                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error.',
                            message: 'ERROR.',
                            duration: '2000',
                            key: null,
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();

                    } else {
                        console.log('else');
                        console.log(res);
                        let invoiceId = res.urlInvoice;
                        //window.open(invoiceId, '_blank');
                        window.open(invoiceId, '_self');
                        component.set("v.showSpinner", false);
                        $A.get("e.force:closeQuickAction").fire();
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
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);
        }
    }
});