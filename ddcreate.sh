#!/bin/bash

docker build -t "ddsynergy:1" .
docker run -d --name "ddsynergy" --restart unless-stopped -v $(pwd):/home/notebook/notebooks -v /persistent/osdepl:/persistent/osdepl -p 8888:8888 ddsynergy:1
mkdir $pwd/html
docker run -d --name "nginx" --restart unless-stopped -v $(pwd)/html:/usr/share/nginx/html/media -p 80:80 nginx
docker logs -f ddsynergy
