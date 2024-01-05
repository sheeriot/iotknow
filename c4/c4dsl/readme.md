# Starting up with Structurizer

```shell
# get the docker image from dockerhub
docker pull structurizr/lite

# run the docker image locally on port 8080
docker run --name struct -it --rm -p 8080:8080 \
    -v /home/kris/dev/iotknow/c4dsl:/usr/local/structurizr \
    structurizr/lite
```
