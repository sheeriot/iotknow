+++
title = 'Create Save Trigger (Tartabit)'
date = 2024-05-07
draft = false
weight = 6
aliases = ['/tartabit-save']
[params]
    author = 'Kris Thompson'
+++

Doc Set: Tartabit Data Pipeline

* [Tartabit Data Pipes - Overview](/tartabit-overview)
* [Setup LNS Service](/tartabit-lns)
* [Create Post Trigger](/tartabit-post)
* [Create Decode Trigger](/tartabit-decode)
* [Create Save Trigger](/tartabit-save) &nbsp;&nbsp; **&lt;- you are here**
* [Setup InfluxDB Service](/tartabit-influxdb)

Purpose of this page:

* Setup the Tartabit IoT-Bridge **trigger** to save the device record to InfluxDB.

## Setup Tartabit Trigger for Saving the Device Record

This page provides details to complete the following tasks:

* create the Tartabit IoT-Bridge **Save** trigger to publish the data record to InfluxDB

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Create the Save Trigger

The **Save** trigger will call the InfluxDB service to store the device data record.

![Tartabit - Save Trigger](../images/tartabit-trigger-save.png)

## Save Trigger Code

This section provides the code used for the Radio Bridge sensors used in this example.

```javascript
var tag_set = event.data.data.tag_set;
var field_set = event.data.data.field_set;

influxdb.publish('usfieldtest-radiobridge-influxdb', 'rb1',tag_set, field_set);
```

Be sure to set the correct InfluxDB **Measurement Name** for your application. In the example above `'rb1'` is used as the measurement name. The measurement acts as an table within the bucket.
