// 当定义其他实例的配置文件时，请按照default_conf模板修改。
// 另外，要注意的是，[instance_name]和[namespace]需要保留格式。
local other_conf = |||
  Here is the customized configuration content, adjusting to other mysql instances.
  ...
  ...
  server.1=[instance_name]-0.[instance_name].[namespace].svc.cluster.local:2888:3888
  server.2=[instance_name]-1.[instance_name].[namespace].svc.cluster.local:2888:3888
  server.3=[instance_name]-2.[instance_name].[namespace].svc.cluster.local:2888:3888
  ...
  ...
|||;

{
  namespace: "zookeeper",
  image: "harbor.freedom.org/docker.io/zookeeper",
  image_tag: "3.4.14",
  image_pull_policy: "IfNotPresent",

  replicas: 3,
  requests_cpu: "100m",
  requests_memory: "128Mi",
  limits_cpu: "1000m",
  limits_memory: "2048Mi",

  container_ports: [
    {name: "client", containerPort: 2181},
    {name: "server", containerPort: 2888},
    {name: "leader-election", containerPort: 3888},
    {name: "http", containerPort: 8080},
  ],

  storage_class: "nfs-infra",
  storage_class_capacity: "10Gi",

  instances: [
      {name: "public", },
      {name: "demo", conf: other_conf},
  ],

  default_conf: |||
    tickTime=2000
    initLimit=10
    syncLimit=5
    dataDir=/data
    dataLogDir=/datalog
    clientPort=2181
    server.1=[instance_name]-0.[instance_name].[namespace].svc.cluster.local:2888:3888
    server.2=[instance_name]-1.[instance_name].[namespace].svc.cluster.local:2888:3888
    server.3=[instance_name]-2.[instance_name].[namespace].svc.cluster.local:2888:3888
  |||,
}