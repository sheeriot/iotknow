+++
title = 'LoRaWAN Paths - Overview'
date = 2024-06-24
draft = false
weight = 1
aliases = ['/lorapaths']

featured_image = '/lorapaths/diagrams/structurizr-1-LoRaWANPaths.png'

[params]
    author = 'Kris Thompson'
+++

Purpose of this Document:

* Reference documentation and support for LoRaWAN traffic using Everynet LoRaWAN Services.

## LoRaWAN Paths - Overview

This is the reference diagram for "Path of the Packet". LoRaWAN devices need RF Coverage and a LoRaWAN Network Server (LNS) to forward traffic to application services. There are multiple ways to achieve this.

![LoRaPaths](/lorapaths/diagrams/structurizr-1-LoRaWANPaths.png)

## Baseline

Everynet RF Coverage with Everynet LNS

## Add Helium RF Coverage

Helium is crypto-token based LoRaWAN gateways and has seen broad public adoption. Helium can greatly expand coverage (successful device uplinks/downlinks) to the Everynet LoRaWAN Network Server.

## Use Everynet RF Coverage with ChirpStack LNS

Use the Everynet RAN-Bridge, use Everynet RF Coverage to connect your devices to a private LNS (LoRaWAN Network Server) such as ChirpStack LNS.

## Use the Everynet RF Coverage with Amazon IoT Core for LoRaWAN

Using AICL (Amazon IoT Core for LoRaWAN), select the Public Network to connect your devices with Everynet RF Coverage.
