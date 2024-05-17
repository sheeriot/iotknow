+++
title = 'Create Post Trigger (Tartabit)'
date = 2024-05-07
draft = false
weight = 10
aliases = ['/tartabit-post']
[params]
    author = 'Kris Thompson'
+++

Doc Set: Tartabit Data Pipeline

* [Tartabit Data Pipes - Overview](/tartabit-overview)
* [Setup LNS Service](/tartabit-lns)
* [Create Post Trigger](/tartabit-post) &nbsp;&nbsp; **&lt;- you are here**
* [Create Decode Trigger](/tartabit-decode)
* [Create Save Trigger](/tartabit-save)
* [Setup InfluxDB Service](/tartabit-influxdb)

Purpose of this page:

* Setup Tartabit Trigger to process the HTTP Post from the Everynet LNS.

## Setup Tartabit Trigger for Post

This page provides details to complete the following tasks:

* create the Tartabit IoT-Bridge Trigger (aka trigger) to process the HTTP Posts as received from the Everynet LNS, and reply 200 (OK) to the HTTP Post
* record the DevEUI and Gateway as the "tag_set" for publishing to InfluxDB
* record all other data to be stored using the field_set object (dictionary)
* use the tags available to enrich the data recorded
* capure the LoRaWAN data payload to the **Decode** trigger for decoding
* call the **Decode** trigger with the `exec.now` function

![Tartabit Data Pipeline - Components](../diagrams/structurizr-1-tartabit_CONTAINERS.png)

## Create the Post Trigger

The Post Trigger will receive the inbound data from the Everynet LNS. Here you can see the trigger is defined to filter by HTTP Post on the service and on body.type == uplink

![Tartabit - Post Trigger](../images/tartabit-trigger-post.png)

### Post Trigger Code

This example includes processing of tags for site_name and site_room, and pluscode for location.

```javascript
// Setup for InfluxDB
// two "tags", aka primary index fields
// all other values are put into field_set

tag_set = {
    dev_eui: event.data.body.meta.device,
    gateway: event.data.body.meta.gateway,
}

field_set = {
    counter_up: event.data.body.params.counter_up,
    device_addr: event.data.body.meta.device_addr,
    duplicate: event.data.body.params.duplicate,
    frequency: event.data.body.params.radio.freq,
    bandwidth: event.data.body.params.radio.modulation.bandwidth,
    spreading_factor: event.data.body.params.radio.modulation.spreading,
    datarate: event.data.body.params.radio.datarate,
    rssi: event.data.body.params.radio.hardware.rssi,
    snr: event.data.body.params.radio.hardware.snr,
    rx_time: event.data.body.params.rx_time,
    frame_size: event.data.body.params.radio.size,
    gw_latitude: Number(event.data.body.params.radio.hardware.gps.lat.toFixed(5)),
    gw_longitude:  Number(event.data.body.params.radio.hardware.gps.lng.toFixed(5)),
}

tags = event.data.body.meta.tags

for (key in tags) {
  var tag = tags[key]
  if (tag.startsWith('loc-')) {
    pluscode = tag.substring(4)
    field_set['pluscode'] =  pluscode;
  } else if (tag.startsWith('site-')) {
    siteroom = tag.split( '-')
    site_info['site'] = 
    field_set.site_name = siteroom[1]
    field_set.site_room = siteroom[2]
  }
}

// capture first two device tags
for (key in tags) {
    if (key === '2') { break; }
    field_set['tag'+(Number(key)+1)] = tags[key]
}

decode_set = {
    payload: event.data.body.params.payload,
    port: event.data.body.params.port,
}

exec.now('usfieldtest-radiobridge-decode', {
  tag_set: tag_set,
  field_set: field_set,
  decode_set: decode_set,
})

trigger.reply({status:200})

```
