+++
title = 'Setup InfluxDB Service (Tartabit)'
date = 2024-05-12
draft = false
weight = 8
aliases = ['/tartabit-influxdb']
[params]
    author = 'Kris Thompson'
+++

Doc Set: Tartabit Data Pipeline

* [Tartabit Data Pipes - Overview](/tartabit-overview)
* [Setup LNS Service](/tartabit-lns)
* [Create Post Trigger](/tartabit-post)
* [Create Decode Trigger](/tartabit-decode)
* [Create Save Trigger](/tartabit-save)
* [Setup InfluxDB Service](/tartabit-influxdb) &nbsp;&nbsp; **&lt;- you are here**

Purpose of this page:

* Setup the Tartabit IoT-Bridge **service** to publish the device record to InfluxDB.

## Setup Tartabit Trigger for Decoding Device Payload

This page provides details to complete the following tasks:

* create a bucket at InfluxDB to store the time-series data records
* create a write-only **token** for the new bucket
* define the Tartabit IoT-Bridge **InfluxDB** service to store the device data record

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Create the InfluxDB Bucket and Write-only Token

Create a new **bucket** at InfluxDB to store the device data records.

![InfluxDB - Create Bucket](../images/influxdb-bucket.png)

Create a new write-only **token** to publish the data from Tartabit.

![InfluxDB - Create Token](../images/influxdb-token.png)

## Define the InfluxDB Service

The Tartabit IoT-Bridge Service, **InfluxDB**,  will store the device data record from the **Save** trigger.

![Tartabit - InfluxDB Service](../images/tartabit-service-influxdb.png)
