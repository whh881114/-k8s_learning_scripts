local other_conf = |||
  Here is the customized configuration content, adjusting to other mysql instances.
|||;

{
  namespace: "redis",
  image: "harbor.freedom.org/docker.io/redis",
  image_tag: "5.0.7",
  image_pull_policy: "IfNotPresent",

  replicas: 1,
  requests_cpu: "100m",
  requests_memory: "128Mi",
  limits_cpu: "1000m",
  limits_memory: "2048Mi",

  container_ports: [
    {name: "redis", containerPort: 6379},
  ],

  storage_class: "nfs-redis",
  storage_class_capacity: "10Gi",

  // redis的密码必须要每个实例都要单独定义。
  instances: [{name: "public", password: "x-Pvvkw2cytxfusWedkgxztxqdhp5ocs", memory: "1Gi"}],

  default_conf: |||
    bind 0.0.0.0
    protected-mode yes
    port 6379
    tcp-backlog 511
    timeout 0
    tcp-keepalive 300
    daemonize no
    supervised no
    pidfile redis.pid
    loglevel notice
    logfile "redis.log"
    databases 16
    always-show-logo yes
    save 900 1
    save 300 10
    save 60 10000
    stop-writes-on-bgsave-error yes
    rdbcompression yes
    rdbchecksum yes
    dbfilename dump.rdb
    dir /data
    replica-serve-stale-data yes
    replica-read-only yes
    repl-diskless-sync no
    repl-diskless-sync-delay 5
    repl-disable-tcp-nodelay no
    replica-priority 100
    # "requirepass"和"maxmemory"跟随实例变化，采用其他方式添加到配置文件中。
    requirepass [indiviual_redis_password]
    maxmemory [indiviual_redis_memory]
    maxmemory-policy volatile-ttl
    lazyfree-lazy-eviction no
    lazyfree-lazy-expire no
    lazyfree-lazy-server-del no
    replica-lazy-flush no
    appendonly yes
    appendfilename "appendonly.aof"
    appendfsync everysec
    no-appendfsync-on-rewrite no
    auto-aof-rewrite-percentage 100
    auto-aof-rewrite-min-size 64mb
    aof-load-truncated yes
    aof-use-rdb-preamble yes
    lua-time-limit 5000
    slowlog-log-slower-than 10000
    slowlog-max-len 128
    latency-monitor-threshold 0
    notify-keyspace-events ""
    hash-max-ziplist-entries 512
    hash-max-ziplist-value 64
    list-max-ziplist-size -2
    list-compress-depth 0
    set-max-intset-entries 512
    zset-max-ziplist-entries 128
    zset-max-ziplist-value 64
    hll-sparse-max-bytes 3000
    stream-node-max-bytes 4096
    stream-node-max-entries 100
    activerehashing yes
    client-output-buffer-limit normal 0 0 0
    client-output-buffer-limit replica 256mb 64mb 60
    client-output-buffer-limit pubsub 32mb 8mb 60
    hz 10
    dynamic-hz yes
    aof-rewrite-incremental-fsync yes
    rdb-save-incremental-fsync yes
  |||,
}