/**
 * Created by max1m on 27.07.20.
 */

({
    doInit: function (component, event, helper) {

        helper.doInit(component, event, helper);
    },
    handleClickContracts: function (component) {

        console.log(component.get("v.Standard"));

        var URL_Standart = component.get("v.Standard");

        //window.location.href = component.get("v.Egnyte");
        if (URL_Standart !== '') {
            window.open(URL_Standart, "_blank");
        } else {
            alert("You don't have the URL address. Please add URL to the field \"URL to Standard Contracts\" ");
        }

    },

    handleClickClient: function (component) {

        console.log(component.get("v.Client"));

        var URL_Client = component.get("v.Client")

        if (URL_Client !== '') {
            window.open(URL_Client, "_blank");
        } else {
            alert("You don't have the URL address. Please add URL to the field \"URL to Client Contracts\" ");
        }

    }
});