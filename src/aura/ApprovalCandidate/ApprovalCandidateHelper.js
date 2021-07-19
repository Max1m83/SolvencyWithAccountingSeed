/**
 * Created by max1m on 23.06.21.
 */

({
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
    },
    goToObject: function (idObject){

        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idObject
        });
        navEvt.fire();
    }
});