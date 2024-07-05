workspace "LoRaWAN Data Paths" "Reference Diagrams" {

    !identifiers hierarchical
    !docs ..

        #  container <name> [description] [technology] [tags] 

    model {
        # user = person "User"
        everynetcoverage = softwareSystem "Everynet RF Coverage" "everynetcoverage" everynetcoveragetag

        everynetran = softwareSystem "Everynet RAN" "Radio Access Network" everynetrantag {
            this -> everynetcoverage
        }

        everynetlns = softwareSystem "Everynet LoRaWAN Network Server" "Everynet LNS" everynetlnstag {
            this -> everynetcoverage downlinks
            everynetcoverage -> this uplinks
            join = container "Join" "Join" "Service" joinservicetag
        }

        helium = softwareSystem "Helium RF Coverage" "Helium" heliumtag {
            this -> everynetlns uplinks
            everynetlns -> this downlinks
        }

        aicl = softwareSystem "AWS IoT Core for LoRaWAN" "AICL" aicltag {
            this -> everynetcoverage downlinks
            everynetcoverage -> this uplinks
            join = container "Join" "Join" "Service" joinservicetag
        }

        chirpstack = softwareSystem "ChirpStack" "ChirpStack LNS" chirpstacktag {
            this -> everynetcoverage downlinks
            everynetcoverage -> this uplinks
            join = container "Join" "Join" "Service" joinservicetag
        }

        datapipes = softwareSystem "Data Pipelines" "Data Collect, Decode, Store" datapipestag {
            aicl -> this uplinks
            everynetlns -> this uplinks
            chirpstack -> this uplinks
        }
    }
        # {
            # service_lns = container "From LNS" "Uplinks" "Service" servicelnstag {
            #     applicationserver -> this "Uplinks"
            # }

            # post = container Post "HTTP-Post" "Trigger" triggerposttag {
            #     service_lns -> this "Process"
            # }
            # decode = container Decode "Decode Payload" "Trigger" triggerdecodetag {
            #     post -> this "Route"
            # }
            # save = container Save "Save Record" "Trigger" triggersavetag {
            #     decode -> this "Record"
            # }
            # service_influxdb = container "To InfluxDB" "InfluxDB" "Service" serviceinfluxdbtag {
            #     save -> this "Save"
            # }
        # }

        # influxdb = softwareSystem "InfluxData TSDB" "Time-series Database" influxdbtag {
        #     tartabit.service_influxdb -> this "Save"
        # }
        # grafana = softwareSystem "Grafana" "Data Dashboard" grafanatag {
        #     this -> influxdb "Visualize"
        # }
        # survyeor = softwareSystem "Surveyor" "Custom Application" surveyortag {
        #     this -> influxdb "Query"
        # }
        # user -> softwareSystem "Uses"

    views {

        systemLandscape LoRaWANPaths "LoRaWAN Paths - Device to Storage" {
            include *
        }

        styles {
            element everynetcoveragetag {
                background Lavender
                stroke #000000
                shape RoundedBox
                icon icons/tower_icon.png
            }
            element everynetrantag {
                background Plum
                shape Ellipse
                width 375
                height 250
                icon icons/lever_icon.png
            }
            element everynetlnstag {
                background Violet
                shape RoundedBox
                icon icons/everynetlogo_icon.png
            }
            element heliumtag {
                background PaleGreen
                shape RoundedBox
                icon icons/heliumnetwork_icon.png
            }
            element aicltag {
                background Orange
                shape RoundedBox
                icon icons/awsiotcore_icon.png
            }
            element chirpstacktag {
                background PeachPuff
                shape RoundedBox
                icon icons/chirpstack_icon.png
            }
            element datapipestag {
                background Cyan
                stroke #000000
                shape Pipe
                icon icons/shuttlebus_icon.png
            }

        }

    }

    configuration {
        # scope softwaresystem
    }

}