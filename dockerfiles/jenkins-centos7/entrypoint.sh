#!/bin/bash

/usr/bin/java \
    -Djava.awt.headless=true \
    -DJENKINS_HOME=/data \
    -jar /usr/lib/jenkins/jenkins.war \
    --logfile=/data/jenkins.log \
    --webroot=/data/war \
    --httpPort=8080 \
    --debug=5 \
    --handlerCountMax=100 \
    --handlerCountMaxIdle=20 \
    -javaagent:/lib/jmx_prometheus_javaagent.jar=60030:/etc/jmx-cfg.yml