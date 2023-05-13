{
    namespace: "consul",
    datacenter: "bj",
    image: "harbor.freedom.org/docker.io/consul",
    image_tag: "1.10.2",
    image_pull_policy: "IfNotPresent",

    server_replicas: 3,
    server_args_retry_json: ["consul-server-0.consul-server.$(NAMESPACE).svc.cluster.local",
                             "consul-server-1.consul-server.$(NAMESPACE).svc.cluster.local",
                             "consul-server-2.consul-server.$(NAMESPACE).svc.cluster.local"],
    server_agrs_retry_json_wan: ["node01.consul.freedom.org",
                                 "node02.consul.freedom.org",
                                 "node03.consul.freedom.org"],

    server_container_ports: [
        {name: "http", containerPort: 8500},
        {name: "https", containerPort: 8443},
        {name: "rpc", containerPort: 8400},
        {name: "serflan-tcp", containerPort: 8301},
        {name: "serflan-udp", containerPort: 8301, protocol: "UDP"},
        {name: "serfwan-tcp", containerPort: 8302},
        {name: "serfwan-udp", containerPort: 8302, protocol: "UDP"},
        {name: "server", containerPort: 8300},
        {name: "consuldns", containerPort: 8600},
    ],

    server_requests_cpu: "100m",
    server_requests_memory: "64Mi",
    server_limits_cpu: "500m",
    server_limits_memory: "256Mi",
    server_storage_class: "storageclass-nfs-infra",
    server_data_capcity: "10G",

    server_ingress: "consul-ui.k8s.bj.freedom.org",

    agent_container_ports: [
        {name: "http", containerPort: 8500},
        {name: "serflan-tcp", containerPort: 8301},
        {name: "serflan-udp", containerPort: 8301, protocol: "UDP"},
        {name: "consuldns", containerPort: 8600},
    ],
    agent_requests_cpu: "100m",
    agent_requests_memory: "64Mi",
    agent_limits_cpu: "500m",
    agent_limits_memory: "256Mi",

    coredns_ip: "172.16.0.10"
}