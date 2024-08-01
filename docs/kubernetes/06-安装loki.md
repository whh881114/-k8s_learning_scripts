# 安装loki

## 前言
- https://grafana.com/docs/loki/latest/setup/install/helm/
- https://grafana.com/docs/loki/latest/setup/install/helm/concepts/
- https://grafana.com/docs/loki/latest/setup/install/helm/install-scalable/
- https://grafana.com/docs/loki/latest/get-started/deployment-modes/

## 部署
- 使用helm安装loki。
- 部署模式为`Simple Scalable`，默认模式。


## 安装结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "namespace/grafana created",
            "NAME: loki",
            "LAST DEPLOYED: Thu Aug  1 11:59:29 2024",
            "NAMESPACE: grafana",
            "STATUS: deployed",
            "REVISION: 1",
            "NOTES:",
            "***********************************************************************",
            " Welcome to Grafana Loki",
            " Chart version: 6.7.3",
            " Chart Name: loki",
            " Loki version: 3.1.0",
            "***********************************************************************",
            "",
            "** Please be patient while the chart is being deployed **",
            "",
            "Tip:",
            "",
            "  Watch the deployment status using the command: kubectl get pods -w --namespace grafana",
            "",
            "If pods are taking too long to schedule make sure pod affinity can be fulfilled in the current cluster.",
            "",
            "***********************************************************************",
            "Installed components:",
            "***********************************************************************",
            "* gateway",
            "* read",
            "* write",
            "* backend",
            "",
            "",
            "***********************************************************************",
            "Sending logs to Loki",
            "***********************************************************************",
            "",
            "Loki has been configured with a gateway (nginx) to support reads and writes from a single component.",
            "",
            "You can send logs from inside the cluster using the cluster DNS:",
            "",
            "http://loki-gateway.grafana.svc.cluster.local/loki/api/v1/push",
            "",
            "You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:",
            "",
            "  kubectl port-forward --namespace grafana svc/loki-gateway 3100:80 &",
            "",
            "And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:",
            "",
            "```",
            "curl -H \"Content-Type: application/json\" -XPOST -s \"http://127.0.0.1:3100/loki/api/v1/push\"  \\",
            "--data-raw \"{\\\"streams\\\": [{\\\"stream\\\": {\\\"job\\\": \\\"test\\\"}, \\\"values\\\": [[\\\"$(date +%s)000000000\\\", \\\"fizzbuzz\\\"]]}]}\"",
            "```",
            "",
            "Then verify that Loki did received the data using the following command:",
            "",
            "```",
            "curl \"http://127.0.0.1:3100/loki/api/v1/query_range\" --data-urlencode 'query={job=\"test\"}' | jq .data.result",
            "```",
            "",
            "***********************************************************************",
            "Connecting Grafana to Loki",
            "***********************************************************************",
            "",
            "If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:",
            "",
            "http://loki-gateway.grafana.svc.cluster.local/"
        ],
        []
    ]
}
```