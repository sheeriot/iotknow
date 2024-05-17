+++
title = 'Tartabit IoT-Bridge Setup Overview'
date = 2024-05-01
draft = false
weight =20
aliases = ['/tartabit-overview']
[params]
    author = 'Kris Thompson'
+++

Doc Set: Tartabit Data Pipeline

* [Tartabit Data Pipes - Overview](/tartabit-overview) &nbsp;&nbsp; **&lt;- you are here**
* [Setup LNS Service](/tartabit-lns)
* [Create Post Trigger](/tartabit-post)
* [Create Decode Trigger](/tartabit-decode)
* [Create Save Trigger](/tartabit-save)
* [Setup InfluxDB Service](/tartabit-influxdb)


Purpose of this Document Set:

* Tartabit IoT-Bridge as Data Processing Pipeline for Everynet LoRaWAN Network Service (LNS).

## Tartabit Data Pipleline Overview

The following diagram provides an overview of the software systems that make up the data pipeline from data source (LoRaWAN Network Server, aka LNS) to the storage container (InfluxDB).

![Tartabit Data Pipeline - In Context](../diagrams/structurizr-1-TartabitLandscape.png).

This document set provides the details to deploy a data pipeline using Everynet LNS, Tartabit IoT-Bridge, and InfluxDB.

### Tartabit Data Pipeline Setup Tasks

To enable the Tartabit Data Pipeline for your application, you need to complete the following configuration tasks on the Tartabit IoT-Bridge.

1. Setup Source Service - LoRaWAN Network Server (webhook)
1. Create Trigger to process HTTP Post
1. Create Trigger for processing Device Payload
1. Create Trigger for saving the Data Record
1. Setup Destination Service - InfluxDB

This diagram provides an overview of the Tartabit IoT-Bridge components that will be setup in this document set.

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Setup a Naming Convention

Using a standardized naming convention is critical to providing clarity and simplicity during system management.

Example: redteam-mousetrap-\<functions\>

* all services and triggers will prefix- with an adminstrative group, e.g. redteam-
* all services and triggers should use an application name to follow the prefix, e.g. mousetrap
* all services and triggers should use a -suffix to name the function provided; i.e. lns, post, decode, save, influx

In this docset, we will be developing the Data Pipeline: **usfieldtest-radiobridge**.

Goto: [Setup LNS](../01_lns)
