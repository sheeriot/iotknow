docker run -it --rm -p 8080:8080 \
   --name struct \
   -v /home/kris/dev/examples/dsl/system-catalog:/usr/local/ \
   structurizr/lite

# works
docker run --name struct -it --rm -p 8080:8080 \
    -v /home/kris/dev/iotknow/c4dsl:/usr/local/structurizr \
    structurizr/lite


docker run --name struct -it --rm -p 8080:8080 \
    -v /home/kris/dev/examples/dsl/system-catalog:/usr/local/structurizr \
    structurizr/lite

docker run -it --rm -p 8080:8080 -v /home/kris/dev/iotknow/c4dsl/data:/usr/local structurizr/lite

docker run --name struct -it --rm -p 8080:8080 \
    -v /home/kris/dev/examples/dsl/amazon-web-services:/usr/local/structurizr \
    structurizr/lite

docker run --name land81 -it --rm -p 8081:8080 \
    -v /home/kris/dev/iotknow/c4surveyor/landscape:/usr/local/structurizr \
    structurizr/lite

docker run --name software82 -it --rm -p 8082:8080 \
    -v /home/kris/dev/iotknow/c4surveyor/software:/usr/local/structurizr \
    structurizr/lite