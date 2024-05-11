+++
title = 'Create Save Trigger (Tartabit)'
date = 2024-05-10
draft = false
+++

# Create Save Trigger (Tartabit)

DocSet:

* [Overview](../00_overview)
* [Setup LNS Service](../01_lns)
* [Create Post Trigger](../02_post)
* [Create Decode Trigger](../03_decode)
* [Create Save Trigger](../04_save) &nbsp;&nbsp; **&lt;- you are here**
* [Setup InfluxDB Service](../05_influxdb)

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

```
var tag_set = event.data.data.tag_set;
var field_set = event.data.data.field_set;

influxdb.publish('usfieldtest-radiobridge-influxdb', 'rb1',tag_set, field_set);
```

Be sure to set the correct InfluxDB **Measurement Name** for your application. In the example above `'rb1'` is used as the measurement name. The measurement acts as an table within the bucket.
