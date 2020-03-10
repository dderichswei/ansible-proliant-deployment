#!/bin/bash

docker build -t "ddsynergy:1" .
docker run -d --name "ddsynergy" --restart unless-stopped -v $(pwd):/home/notebook/notebooks -v /persistent/osdepl:/persistent/osdepl -p 8842:8888 ddsynergy:1
docker logs -f ddsynergy
