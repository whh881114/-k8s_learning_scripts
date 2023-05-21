#!/bin/bash

registry_url="harbor.freedom.org"
registry_project="freedom"
image="$registry_url"/"$registry_project"/jenkins:2.405-centos7

docker build -t $image .
docker push $image