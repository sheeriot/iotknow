workspace "RF Field Surveyor" "A Django (python) web application for inspecting LoRaWAN peformance" {

    !identifiers hierarchical
    !docs docs
    
    model {

        influxdb = softwareSystem "InfluxDB" "a time-series database" influxdbtag

        surveyor = softwareSystem "RF Field Surveyor" "RF Coverage" surveyortag {
            webapp = container "webapp" "webapp" "Django" webapptag
            worker = container "worker" "worker" "Django" workertag
            redis = container "Redis" "redis" "Memory Cache" redistag
            database = container "database" "database" "sqlite3" databasetag
        }
        
        # device.antenna -> gateway.antenna uplinks RF uplink
        # device.mcu -> networkserver.dedup "LoRaWAN\nMAC" uplink/downlink logical
        # device.mcu -> applicationserver reports uplink logical
        # gateway -> networkserver uplinks pkt-fwd uplink
        # networkserver -> applicationserver uplinks http uplink
        # applicationserver -> networkserver downlink http downlink
        # networkserver -> gateway downlink pkt-fwd downlink
        # gateway.antenna -> device.antenna downlinks RF downlink
        # applicationserver -> device.mcu control downlink logical
    }

    views {
    
        container surveyor RFFieldSurveyor "RF Field Surveyor" {
            include *
        }

        styles {
            relationship uplink {
                color green
                dashed false
                thickness 4
            }
            relationship downlink {
                color red
                dashed false
                thickness 4
            }
            relationship logical {  
                color blue
                dashed true
                thickness 4
            }
            element devtag {
                background green
                color white
                fontSize 36
                shape Hexagon
            }
            element gwtag {
                background #DDA0DD
                color #ffffff
                fontSize 22
                shape Pipe
                # icon docs/images/tower.png
            }
            element nstag {
                background darkorchid
                color #ffffff
                fontSize 22
                shape Cylinder
            }
            element astag {
                background darkolivegreen
                color white
                fontSize 24
                shape RoundedBox
            }
            element sensorstag {
                background green
                color white
                fontSize 22
                shape Hexagon
                # icon docs/images/therm100.jpg
            }
            element antennatag {
                background #DA70D6
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element radiotag {
                background violet
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element modemtag {
                background  #E0B0FF
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element cputag {
                background LightGreen
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element powertag {
                background IndianRed
                color white
                shape Component
                # icon docs/images/antenna.png
            }
            element gpstag {
                background SkyBlue
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element pktfwdtag {
                background #DF73FF
                color white
                shape Component
                # icon docs/images/antenna.png
            }
            element backhaultag {
                background #4E2A84
                color white
                shape Component
                # icon docs/images/antenna.png
            }
        }
    }

}