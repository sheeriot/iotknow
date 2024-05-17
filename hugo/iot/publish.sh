#!/bin/bash

# rm existing folder

# run build script
./build.sh

# rm existing folder
scp -r public/* iot:~/iot
