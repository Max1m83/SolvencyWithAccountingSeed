/**
 * Created by max1m on 19.02.21.
 */

import {LightningElement, track} from 'lwc';
import getEmailLogs from '@salesforce/apex/StatusEmailController.getEmailLogs';

const columns = [
    {label: 'Candidate`s name', fieldName: 'Name'},
    {label: 'Position', fieldName: 'Position'},
    {label: 'Status', fieldName: 'Stage'},
    {label: 'Email Status', fieldName: 'Status'},
    {label: 'Sending time', fieldName: 'Time'},
];

export default class statusEmail extends LightningElement {

    @track queryTerm;
    @track columns = columns;
    @track isLoading;
    @track data;
    @track dateSort;
    @track emailsLogs;
    @track allEmailsLogs;
    @track errorEmailsLogs;
    @track searchStringName;
    @track isError = false;

    connectedCallback() {
        this.isLoading = true;
        getEmailLogs()
            .then(result => {
                if (result.Status === 'Success') {
                    if (result.Status === 'Success') {
                        this.emailsLogs = result.Emails;
                        this.allEmailsLogs = result.Emails;
                        this.errorEmailsLogs = result.EmailsError;
                    }
                    this.data = result.Body;
                    this.error = undefined;
                    this.isLoading = false;
                } else {

                }
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
        }
        if (this.queryTerm != null) {
            this.sortAll();

        }
    }

    sortByStatus(evt) {
        this.isLoading = true;
        if (this.isError) {
            this.isError = false;
            this.emailsLogs = this.allEmailsLogs;
        } else {
            this.isError = true;
            this.emailsLogs = this.errorEmailsLogs;
        }
        this.sortAll();
        this.isLoading = false;
    }

    sortByDate(evt) {
        this.dateSort = evt.target.value;
        this.sortAll();
    }

    sortAll() {
        let listEmails;

        if (this.isError) {
            listEmails = this.errorEmailsLogs;
        } else {
            listEmails = this.allEmailsLogs;
        }

        let newListEmailsName = [];
        let sortTime = this.dateSort;

        if (this.queryTerm != null) {

            listEmails.forEach((element) => {
                if (element.Name.toLowerCase() === this.queryTerm.toLowerCase()) {
                    newListEmailsName.push(element);
                }

            });
            if (this.queryTerm) {
                listEmails = newListEmailsName;
            }
        }

        let newListEmails = [];

        if (sortTime != null) {
            listEmails.forEach((element) => {

                if (element.TimeSort === sortTime) {

                    if (this.queryTerm) {

                        if (element.Name.toLowerCase() === this.queryTerm.toLowerCase()) {
                            newListEmails.push(element);
                        }

                    } else {
                        console.log('sortTime Else');
                        newListEmails.push(element);
                    }
                }
            });
        } else {
            newListEmails = listEmails;
        }

        this.emailsLogs = newListEmails;
    }

}