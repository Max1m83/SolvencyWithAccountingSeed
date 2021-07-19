/**
 * Created by max1m on 05.03.21.
 */

import {LightningElement, track, api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import checkToken from '@salesforce/apex/Int_inSettingsController.checkIsValidAccessToken';
import getData from '@salesforce/apex/Int_inSettingsController.getSetting';
import sync from '@salesforce/apex/Int_inSettingsController.syncNow';
import schedulerUpdate from '@salesforce/apex/Int_inSettingsController.schedulerUpdate';

export default class InSettings extends LightningElement {

    @track isLoading;
    @track isValid = false;
    @track isTwoTabVis = false;
    @track token;
    @api isChecked = false;
    @api selectFrequency;
    @api selectHourlyFrequency;
    @api dateSent;
    statusScheduler;

    get optionsHourly() {
        return [
            {label: 'N/A', value: 'not'},
            {label: 'Every 5 minutes', value: '5'},
            {label: 'Every 10 minutes', value: '10'},
            {label: 'Every 15 minutes', value: '15'},
            {label: 'Every 1 hour', value: '60'},
            {label: 'Every 12 hours', value: '720'},
            {label: 'Every Day', value: '1440'},
        ];
    }

    connectedCallback() {
        this.isLoading = true;
        getData()
            .then(result => {
                console.log(result);
                let isChange = false;
                if (result.Status === 'success') {

                    this.token = result.token;
                    if (result.authorized === 'Success') {
                        isChange = true;
                    }
                    this.lastSyncTime(result.lastTime);
                    this.nextSyncTime(result.nextTime);
                    this.selectFrequency = result.frequency;

                    this.error = undefined;
                    this.isLoading = false;
                } else {
                    this.isLoading = false;
                }
                this.isValid = isChange;
                this.isChecked = true;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    lastSyncTime(dateString) {

        let elementDate = this.template.querySelector('[data-id="inputDate"]');
        let elementTime = this.template.querySelector('[data-id="inputTime"]');
        let dateLast = dateString.split(' ');

        if (dateLast.length > 1) {

            if (elementTime) {
                elementTime.value = ' ' + dateLast[0];
            }
            if (elementDate) {
                elementDate.value = ' ' + dateLast[1];
            }
        }
    }

    nextSyncTime(dateString) {

        let elementDate = this.template.querySelector('[data-id="inputNextDate"]');
        let elementTime = this.template.querySelector('[data-id="inputNextTime"]');
        let dateLast = dateString.split(' ');

        if (dateLast.length > 1) {

            if (elementTime) {
                elementTime.value = ' ' + dateLast[0];
            }
            if (elementDate) {
                elementDate.value = ' ' + dateLast[1];
            }
        }
    }

    checkValid(event) {

        this.isLoading = true;
        console.log('checkValid');
        let accessToken = event.target.value;
        checkToken({token: accessToken})
            .then(result => {
                let isChange = false;
                console.log('result', result);
                if (result === 'Success') {
                    isChange = true;
                    this.isLoading = false;

                } else {

                    this.isLoading = false;
                }
                this.isValid = isChange;
                this.isChecked = true;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    Synchronize() {
        this.isLoading = true;
        let resultSynch;
        sync()
            .then(result => {
                console.log('Result', result);
                resultSynch = result;
                this.isLoading = false;
                if (resultSynch === 'Success') {
                    this.showToast('Success!', 'success', 'The Batch is running!');
                } else if (resultSynch === 'Not Activated') {
                    this.showToast('Error!', 'error', 'Please activate indexBatch!');
                } else {
                    this.showToast('Error!', 'error', 'Error in transactions!');
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });

        console.log('Error', resultSynch);
    }

    Scheduler() {
        this.isLoading = true;
        let resultCallout;

        schedulerUpdate({hourlyFrequency: this.selectHourlyFrequency})

            .then(result => {
                if (result === 'Not Activated') {
                    this.showToast('Error!', 'error', 'Please activate indexBatch!');
                    this.isLoading = false;
                } else {
                    this.showToast('Success!', 'success', 'The batch is scheduled to job!');
                    resultCallout = result;
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
        this.nextSyncTime(resultCallout);
        this.isLoading = false;
    }

    handleChange(event) {
        this.selectHourlyFrequency = event.target.value;
    }

    handleChangeFrequency(event) {
        this.selectFrequency = event.target.value;
    }

    timeScheduler(event) {
        this.dateSent = event.target.value;
    }

    showToast(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title || 'Info',
            message: message,
            variant: variant || 'info'
        }));
    }
}