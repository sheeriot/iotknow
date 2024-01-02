workspace {

    model {
        # operator = person "field_tech"
        # surveyor = softwareSystem "surveyor"
        device = softwareSystem "LoRaWAN Device"
        gateway = softwareSystem "LoRaWAN Gateway" "RF Coverage"
        ran = softwareSystem "Radio Access Network"
        networkserver = softwareSystem "Network Server" "device management, de-dup"
        application = softwareSystem "Application Server" "decrypt, decode, direct"
        joinserver = softwareSystem "Join Server" "device authentication" join_server
        storage = softwareSystem "InfluxDB" "device data" storage
        surveyor = softwareSystem "RF Field Surveyor" "Django Web App" surveyor
        operator = person Operator "review macro performance" operator
        fieldtech = person "Field Technician" "review micro performance" field_tech

        device -> gateway "Uplinks"
        ran -> gateway "manages"
        gateway -> networkserver "uplinks"
        networkserver -> application "uplinks"
        networkserver -> joinserver "join request"
        joinserver -> networkserver "join accept"
        application -> networkserver "downlinks"
        application -> storage "write"
        networkserver -> gateway "downlinks"
        gateway -> device "downlinks"
        surveyor -> storage "read"
        operator -> surveyor "view"
        fieldtech -> surveyor "view"
    }

    views {

        systemlandscape everything "All Systems" {
            include *
        }
        styles {
            element operator {
                background #08427b
                color #ffffff
                fontSize 22
                shape Person
            }
            element field_tech {
                background purple
                color #ffffff
                fontSize 22
                shape Person
            }
            element storage {
                background #999999
                color #ffffff
                fontSize 22
                shape Cylinder
            }
            element surveyor {
                background green
                color #ffffff
                fontSize 36
                shape WebBrowser
            }
        }
    }
    configuration {
        scope landscape
    }

}