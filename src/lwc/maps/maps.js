/**
 * Created by max1m on 11.03.21.
 */

import {LightningElement} from 'lwc';


export default class Maps extends LightningElement {

    mapMarkers = [{
        location: {
            City: 'Zürich',
            Country: 'Switzerland',
            PostalCode: '8002',
            State: 'Zürich',
            Street: 'Beethovenstraße, 49'
        },
        value: 'location001',
        title: 'The Landmark Building',
        description: 'The Landmark is considered to be one of the city&#39;s most architecturally distinct and historic properties', //escape the apostrophe in the string using &#39;
        icon: 'standard:account'
    }];
}