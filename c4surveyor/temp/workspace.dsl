workspace {

    model {
        # operator = person "field_tech"
        # surveyor = softwareSystem "surveyor"
        device = softwareSystem "LoRaWAN Device" "with sensors" device
        gateway = softwareSystem "LoRaWAN Gateway" "RF Coverage" gateway
        ran = softwareSystem "Radio Access Network"
        networkserver = softwareSystem "Network Server" " " {
            !docs docs
            ns = container NS "device management, de-dup" LoRaWAN ns
            joinserver = container joinserver "device authentication" LoRaWAN joinserver
        }
        appserver = softwareSystem "Application Server" "decrypt, decode, direct" appserver

        influxdb = softwareSystem "InfluxDB" "time-series database" influxdb
        surveyor = softwareSystem "RF Field Surveyor" "Django Web App" surveyor {
            nginx = container nginx "web server" web nginx
            surveyordb = container sqlite3 "database" surveyordb
            djangoapp = container djangoapp "django app" djangoapp djangoapp {
            }
        }

        operator = person Operator "review macro performance" operator
        fieldtech = person "Field Technician" "review micro performance" field_tech

        device -> gateway uplinks
        ran -> gateway "manages"
        gateway -> ns "uplinks"
        ns -> appserver "uplinks"
        ns -> joinserver "join request"
        joinserver -> ns "join accept"
        appserver -> ns "downlinks"
        appserver -> influxdb "write"
        networkserver -> gateway "downlinks"
        gateway -> device "downlinks"
        djangoapp -> influxdb "read"
        operator -> nginx "view"
        fieldtech -> nginx "view"
        networkserver -> device "MAC commands"
        networkserver -> device "Confirm/Ack"
        device -> networkserver "Confirm/Ack"

        nginx -> djangoapp proxy
        djangoapp -> surveyordb read/write

        deploymentEnvironment "Development" {
            deploymentNode "Azure VM" "" "azure-vm" {
                nginxInstance = containerInstance nginx
                surveyorInstance = containerInstance djangoapp
            }
        }
    }

    views {

        # systemlandscape everything "All Systems" {
        #     include *
        # }

        # Context Views
        systemContext networkserver "NetworkServer" {
            include *
        }
        systemContext device "device" {
            include *
        }
        systemContext surveyor "surveyor" {
            include *
        }

        # Container Views
        container networkserver "NetworkServerContainer" "Network Server Described" {
            include *
        }
        container surveyor "surveyorContainer" "surveyor parts" {
            include *
        }

        deployment surveyor "Development" "Surveyor_Deployment" {
            include *
            description "An example"
        }

        styles {

            element device {
                background papayawhip
                color black
                fontSize 22
                shape Hexagon
            }
            element operator {
                background #08427b
                color #ffffff
                fontSize 22
                shape Person
            }
            element field_tech {
                background purple
                color white
                fontSize 24
                shape Robot
            }
            element gateway {
                background #08427b
                color #ffffff
                fontSize 22
                shape Pipe
            }
            element influxdb {
                shape Cylinder
            }
            element nginx {
                background green
                color #ffffff
                fontSize 36
                shape WebBrowser
            }
        }
    }

}