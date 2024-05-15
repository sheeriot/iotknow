+++
title = 'Setup Tartabit Service and Everynet LNS Source'
date = 2024-05-10
draft = false
+++

DocSet:

* [Overview](../00_overview)
* [Setup LNS Service](../01_lns) &nbsp;&nbsp; **&lt;- you are here**
* [Create Post Trigger](../02_post)
* [Create Decode Trigger](../03_decode)
* [Create Save Trigger](../04_save)
* [Setup InfluxDB Service](../05_influxdb)

Purpose of this page:

* Setup Everynet LNS and Tartabit for HTTP Post

## Setup Tartabit Service and Everynet LNS Source

This page provides details to complete the following tasks:

* create the HTTP Post Service definition on the Tartabit IoT-Bridge
* create a Filter on the Everynet LNS to define forwarded traffic
* create a connection on the LNS to forward to Tartabit based on the Filter

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Configure the Tartabit Service for the LNS

The LNS will use an HTTP to a webhook address to forward LoRaWAN traffic to the Tartabit Iot-Bridge for processing.

Here is an example of a configured service for a LoRaWAN Network Server using HTTP Post.

![Tartabit Data Pipeline - LNS Service](../images/tartabit-service-lns.png)

The Webhook secret needs to be unique (avoid duplicating existing services unless you modify the webhook).

## Create a Filter with a Device Tag

With a webhook created in the Tartabit service definition, you are ready to setup the LoRaWAN Network Server (LNS) for traffic forwarding to Tartabit. In our example we are using the Everynet LNS.

On the Everynet LoRaWAN Network Server (LNS), the best way to create a filter for forwarding traffic, is with a distinct shared tag assigned to each device.

In this application we are only processing uplinks. The options allow us to see all received frames, RF signal/noise performance, and leverage the device tags.

![Everynet LNS - Filter by Tag](../images/everynet-lns-filter.png)

Tip: If your device is online, be sure (only) your targetted traffic is showing in the Live stream as shown above.

Keep the Filter ID to use in the HTTP Connection definition.

## Create an HTTP Connection with Filter ID

Use the Filter ID, and the URL for the Tartabit IoT-Bridge, to forward the uplink traffic for processing.

![Everynet LNS - HTTP Connection](../images/everynet-lns-connection.png)

Be sure the Service comes ONLINE. Refresh the Status as needed.
