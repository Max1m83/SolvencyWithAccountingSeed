import {LightningElement, track} from 'lwc';
import getEmailScheduler from '@salesforce/apex/SchedulerSettingsController.getScheduler';
import deleteCronSchedule from '@salesforce/apex/SchedulerSettingsController.deleteScheduler';

const columns = [
    {label: 'Candidate`s name', fieldName: 'Name'},
    {label: 'Position', fieldName: 'Position'},
    {label: 'Status', fieldName: 'Stage'},
    {label: 'Scheduled time', fieldName: 'NextDate'},

    {
        type: "button",
        fixedWidth: 110,
        typeAttributes: {
            label: 'Delete',
            name: 'Delete',
            title: 'View',
            variant: 'destructive-text',
            disabled: false,
            value: 'Delete',
            iconPosition: 'right'
        }
    },
];

export default class Scheduler extends LightningElement {

    @track error;
    @track dateSent;
    @track columns = columns;
    @track emailsScheduler;
    @track isScheduler;
    @track isLoading;
    @track isEdit;
    @track labelEditForm;
    @track selectJobId;

    connectedCallback() {
        this.isLoading = true;
        this.isEdit = false;
        getEmailScheduler()
            .then(result => {
                console.log(result);
                if (result.Status === 'Success') {
                    this.emailsScheduler = result.Body;
                    this.error = undefined;
                    this.isScheduler = true;
                    this.isLoading = false;
                } else {

                }
            })
            .catch(error => {
                this.error = error;
                this.emailsScheduler = undefined;
                this.isLoading = false;
            });
    }

    backClick() {
        this.isEdit = false;
        this.isScheduler = true;
    }

    callRowAction(event) {

        this.isLoading = true;
        const cronId = event.detail.row.cronId;
        const candNameId = event.detail.row.Name;
        const positionName = event.detail.row.Position;
        const dateTime = event.detail.row.JsDate;
        const actionName = event.detail.action.name;

        if (actionName === 'Edit') {

            this.labelEditForm = 'Scheduler to sent email to the Candidate ' + candNameId + ' (Position: ' + positionName + '):';
            this.isLoading = false;
            this.selectJobId = cronId;
            this.isEdit = true;
            this.dateSent = dateTime;
            this.isScheduler = false;

        } else if (actionName === 'Delete') {

            deleteCronSchedule({cronId})
                .then(result => {
                    console.log(result);
                    if (result.Status === 'Success') {
                        this.emailsScheduler = result.Body;
                        this.error = undefined;
                        this.isLoading = false;
                    } else {
                        this.isLoading = false;
                    }
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                });
        }
    }
}