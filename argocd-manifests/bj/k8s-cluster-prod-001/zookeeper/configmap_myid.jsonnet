local vars = import './vars.libsonnet';

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "myid",
      namespace: vars['namespace'],
    },
    data: {
      "myid.sh": |||
        #!/bin/bash
        #
        myid=`echo $HOSTNAME | awk -F "-" '{print $NF}'`
        myid=$[myid+1]
        echo $myid > /data/myid
      |||
    }
  }
]