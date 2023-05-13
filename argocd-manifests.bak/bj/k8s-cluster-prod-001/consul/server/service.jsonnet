local vars = import '../vars.libsonnet';

local services = [{name: "consul-server", type: "ClusterIP"}, {name: "consul-server-nodeport", type: "NodePort"}];

local ports = [
    if "protocol" in p then
    {
        name: p.name,
        port: p.containerPort,
        targetPort: p.containerPort,
        protocol: p.protocol
    }
    else
    {
        name: p.name,
        port: p.containerPort,
        targetPort: p.containerPort,
    }
    for p in vars['server_container_ports']
];

[
    {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
            name: "%s" % service.name,
            namespace: vars['namespace'],
            labels: {app: "consul-server"},
        },
        spec: {
            selector: {app: "consul-server"},
            type: "%s" % service.type,
            ports: ports
        }
    }

    for service in services
]