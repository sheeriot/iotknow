workspace {

    model {
 
        device = softwareSystem "LoRaWAN Device"
        gateway = softwareSystem "LoRaWAN Gateway" "RF Coverage"
        ran = softwareSystem "Radio Access Network"
        networkserver = softwareSystem "Network Server" "device management, de-dup"
        application = softwareSystem "Application Server" "decrypt, decode, direct"
        joinserver = softwareSystem "Join Server" "device authentication" join_server


        device -> gateway uplinks
        ran -> gateway manages
        gateway -> networkserver uplinks
        networkserver -> application uplinks
        networkserver -> joinserver "join request"
        joinserver -> networkserver "join accept" "address assigned"
        application -> networkserver downlinks
        networkserver -> gateway downlinks
        gateway -> device downlinks
    }

    views {

        systemLandscape LoRaWAN "LoRaWAN System Landscape" {
            include *
        }
        
        systemContext networkserver networkserver_view "Network Server" {
            include networkserver
            include application
            include gateway
            include device
        }
        
        styles {
            element "LoRaWAN Device" {
                background green
                color white
                fontSize 22
                shape Pipe
            }
            element gateway {
                background purple
                color #ffffff
                fontSize 22
                shape Person
            }
            element networkserver {
                background #999999
                color #ffffff
                fontSize 22
                shape Cylinder
            }
        }
    }
    configuration {
        scope landscape
    }

}