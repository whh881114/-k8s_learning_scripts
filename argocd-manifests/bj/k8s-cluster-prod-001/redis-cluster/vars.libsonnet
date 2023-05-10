// 当定义其他redis实例的配置文件时，请按照default_conf模板修改。
// 另外，要注意的是，requirepass和 maxmemory需要保留格式，他们分别对应的值写在instances中即可。
local other_conf = |||
  Here is the customized configuration content, adjusting to other mysql instances.
  ...
  ...
  requirepass [indiviual_redis_password]
  maxmemory [indiviual_redis_memory]
  ...
  ...
|||;

{
  namespace: "redis-cluster",
  image: "harbor.freedom.org/docker.io/redis",
  image_tag: "5.0.7",
  image_pull_policy: "IfNotPresent",

  // 默认情况下部署三主三从，所以需要redis-cluster实例POD的数量是6。
  replicas: 6,
  requests_cpu: "100m",
  requests_memory: "128Mi",
  limits_cpu: "1000m",
  limits_memory: "2048Mi",

  container_ports: [
    {name: "server", containerPort: 6379},
    {name: "cluster", containerPort: 16379},
  ],

  storage_class: "nfs-redis",
  storage_class_capacity: "10Gi",

  // redis的密码必须要每个实例都要单独定义。
  // 如果不定义redis实例的memory值时，那redis.conf文件中的maxmemory就为默认的limits_memory值，
  // 当声明memory值时，请同时声明limits_memory值。
  instances: [
    {name: "public", password: "x-Pvvkw2cytxfusWedkgxztxqdhp5ocs"},
    {name: "password-bank", password: "uuglwtvYitnod@yevuqrDkr6xrlk3ach", memory: "4096Mi", limits_memory: self.memory},
    // {name: "cache", password: "srcgxzsl1av>fojzcjkOnikxste7Babs", memory: "1024Mi", limits_memory: self.memory, conf: other_conf},
  ],

  default_conf: |||
    dir /data
    bind 0.0.0.0
    cluster-enabled yes
    cluster-config-file nodes.conf
    logfile redis.log
    cluster-node-timeout 5000
    appendonly yes
    daemonize no
    pidfile redis.pid
    appendfilename appendonly.aof
    protected-mode yes
    \r\n
    # "requirepass"/"masterauth", "maxmemory"跟随实例变化，采用其他方式添加到配置文件中。
    requirepass [indiviual_redis_password]
    masterauth  [indiviual_redis_password]
    maxmemory [indiviual_redis_memory]
    maxmemory-policy volatile-ttl
    \r\n
    timeout 60
    tcp-keepalive 300
    loglevel notice
    \r\n
    appendfsync everysec
    no-appendfsync-on-rewrite no
    auto-aof-rewrite-percentage 100
    auto-aof-rewrite-min-size 64mb
    aof-load-truncated yes
    \r\n
    lua-time-limit 5000
    slowlog-log-slower-than 10000
    slowlog-max-len 128
    latency-monitor-threshold 0
    notify-keyspace-events ""
    hash-max-ziplist-entries 512
    hash-max-ziplist-value 64
    list-max-ziplist-entries 512
    list-max-ziplist-value 64
    set-max-intset-entries 512
    zset-max-ziplist-entries 128
    zset-max-ziplist-value 64
    hll-sparse-max-bytes 3000
    activerehashing yes
    client-output-buffer-limit normal 0 0 0
    client-output-buffer-limit slave 256mb 64mb 60
    client-output-buffer-limit pubsub 32mb 8mb 60
    hz 10
    aof-rewrite-incremental-fsync yes
  |||,
}