#!/bin/bash

/usr/bin/java -Xms${JAVA_HEAP_XMS} -Xmx${JAVA_HEAP_XMX} ${JAVA_JMX_OPTS} ${JAVA_OPTS} $@
