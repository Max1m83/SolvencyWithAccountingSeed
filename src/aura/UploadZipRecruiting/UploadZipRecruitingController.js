/**
 * Created by max1m on 18.01.21.
 */


({
    save: function (component, event, helper) {
        helper.save(component);
    },
    waiting: function (component, event, helper) {
        component.set("v.uploading", true);
    },
    doneWaiting: function (component, event, helper) {
        component.set("v.uploading", false);
    },
    handleFilesChange: function (component, event, helper) {
        let fileInput = component.find("file").getElement();
        let file = fileInput.files[0];
        component.set("v.label", file.name);
    }
})