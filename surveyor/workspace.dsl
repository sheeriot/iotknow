workspace "RF Field Surveyor" "A Django (python) web application for inspecting LoRaWAN peformance" {

    !identifiers hierarchical
    !docs docs
    
    model {

        # influxdb = softwareSystem "InfluxDB" "a time-series database" influxdbtag

        surveyor = softwareSystem "RF Field Surveyor" "RF Coverage" webapptag {
            nginx = container "Nginx" "Web Server\nSSL Proxy" "Docker" nginxtag
            database = container "SQLite3" "Database" "text" databasetag
            redis = container "Redis" "Cache" "Docker" redistag
            webapp = container "Surveyor" "Django/Python" "Docker" webapptag {
                nginx -> this
                -> database
                -> redis set jobs
                -> redis get results
                # -> influxdb.source                
            }
            worker = container "Surveyor_Worker" "Django/Python" "Docker" workertag {
                -> redis get jobs
                -> redis set results
            }
        }
        
        influxdb = softwareSystem "InfluxDB" "a time-series database" influxdbtag {
            organization = group "Influx Organization" {
                source = container "Influx Bucket" "data store" "bucket" influxbuckettag {
                    measurement = component "Influx Measurement" " " "table" influxmeastag
                    surveyor.webapp -> this query
                    surveyor.worker -> this query
                }
            }
        }

        fieldtech = person "Field Technician" "Field Technician" fieldtechtag {
            -> surveyor.nginx "Web Access" "https" webaccessreltag 
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
        container influxdb "InfluxDB" "InfluxDB - Time Series Database" {
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
            element webapptag {
                // from surveyor header
                background #2f3067
                color white
                fontSize 24
                shape WebBrowser
                icon docs/icons/surveyor50b.png
            }

            element workertag {
                // from surveyor header
                background #5156b9
                color white
                fontSize 24
                # shape WebBrowser
                icon docs/icons/surveyor50b.png
            }

            element databasetag {
                background #84cef4
                color #ffffff
                fontSize 22
                shape Cylinder
                icon docs/icons/sqlite_icon.png
            }
            element redistag {
                background #ff6156
                fontSize 24
                shape Pipe
                icon docs/icons/redis_icon.png
            }
            element nginxtag {
                background #00e95e
                fontSize 24
                shape Ellipse
                icon docs/icons/nginx_icon.png
            }
            element influxdbtag {
                background #9394FF
                fontSize 24
                shape Cylinder
                icon docs/icons/influxdb_icon.png
            }
            element fieldtechtag {
                # background darkolivegreen
                # color white
                fontSize 24
                shape Robot
            }
        }
    }

}