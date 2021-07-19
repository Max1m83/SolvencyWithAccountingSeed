/**
 * Created by max1m on 15.12.20.
 */

({
    init: function (component, event, helper) {
        var action = component.get("c.getBillingOrigin");
        action.setParams({billId: component.get("v.recordId")});
        action.setCallback(this, $A.getCallback(function (response1) {
                var state = response1.getState();
                if (state === "SUCCESS") {
                    var result = response1.getReturnValue();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: result
                        });
                    })
                        .catch(function (error) {
                            console.log(error);
                        });
                }
            }
        ));
        $A.enqueueAction(action);
    }
});