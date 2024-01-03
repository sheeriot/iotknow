#!/bin/bash

# docs as code using Structurizr
docker run --name lorawan82 -it --rm -p 8082:8080 \
    -v /home/kris/dev/iotknow/lorawan:/usr/local/structurizr \
    structurizr/lite