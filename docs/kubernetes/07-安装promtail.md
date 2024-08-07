# 安装loki

## 前言
- https://github.com/grafana/helm-charts/releases/download/promtail-6.16.4/promtail-6.16.4.tgz

## 部署
- 使用helm安装promtail。
- 配置相关参数，默认情况下配置的内容很少，只是更新下镜像地址即可。

## 安装结果
```shell
ok: [10.255.1.12] => {
    "msg": [
        [
            "release \"promtail\" uninstalled",
            "NAME: promtail",
            "LAST DEPLOYED: Wed Aug  7 11:02:10 2024",
            "NAMESPACE: grafana",
            "STATUS: deployed",
            "REVISION: 1",
            "TEST SUITE: None",
            "NOTES:",
            "***********************************************************************",
            " Welcome to Grafana Promtail",
            " Chart version: 6.16.4",
            " Promtail version: 3.1.0",
            "***********************************************************************",
            "",
            "Verify the application is working by running these commands:",
            "* kubectl --namespace grafana port-forward daemonset/promtail 3101",
            "* curl http://127.0.0.1:3101/metrics"
        ],
        [
            "Error from server (AlreadyExists): namespaces \"grafana\" already exists"
        ]
    ]
}
```

## 部署过程中的思考点
- 如果官方有helm chart，那么优先使用，毕竟官方写的模板会考虑周全。

- 官方的positions文件为什么要放在/run目录下呢，`positions.filename: /run/promtail/positions.yaml`？
  理由来自于谷歌的`gemini`回答。
  ```shell
  ## 为什么 promtail 的 position 文件放在 /run 目录下？
  
  这个问题问得非常好，直指了 /run 目录与 promtail position 文件之间看似矛盾的一点。
  
  ### 理解 /run 目录和 promtail position 文件
  
  /run 目录：如你所述，/run 目录中的文件会在系统重启后被清空。这是因为这些文件通常是进程运行时产生的临时文件，用于记录进程的当前状态。
  promtail position 文件：promtail 是一个日志采集工具，position 文件记录了它已经处理过的日志文件的偏移量，以确保在下一次启动时能够从上次中断的地方继续采集。
  
  ### 为什么将 position 文件放在 /run 目录下的原因
  
  1. 符合设计初衷：
     临时性： position 文件本质上也是一种运行时状态，记录了 promtail 在当前运行周期中的进度。当系统重启时，promtail 从头开始采集日志是一个合理的默认行为。
     避免数据持久化： 将 position 文件放在 /run 目录下，可以避免将这些临时状态信息持久化到其他存储介质中，减少了数据冗余和管理的复杂性。
  
  2. 与 promtail 的工作机制相适应：
     从头开始采集：promtail 在启动时会扫描指定目录下的所有日志文件，并从头开始读取。如果 position 文件存在，则会根据文件中的偏移量从上次中断的地方继续读取。
     容错性：将 position 文件放在 /run 目录下，即使 position 文件丢失或损坏，promtail 也可以从头开始采集，保证日志数据的完整性。
  
  3. 便于管理：
     集中管理： 将所有 promtail 相关的临时文件放在 /run 目录下，方便管理和维护。
     避免污染其他目录： 避免将这些临时文件散落在系统中的其他目录，保持系统目录结构的清晰。
  
  ### 如何解决 position 文件丢失的问题？
  
  如果你希望在系统重启后，promtail 能够从上次中断的地方继续采集日志，可以考虑以下几种方法：
  
  1. 将 position 文件持久化：
     自定义目录： 将 position 文件保存到一个自定义的目录中，例如 `/var/lib/promtail/positions.yaml`。
     配置 promtail： 在 promtail 的配置文件中指定 position 文件的路径。
  2. 使用外部存储：
     数据库： 将 position 信息存储到一个数据库中，例如 MySQL、PostgreSQL。
     分布式存储： 使用分布式存储系统，例如 Consul、etcd，来存储 position 信息。
  
  ### 总结
  
  将 promtail 的 position 文件放在 /run 目录下，虽然在系统重启后会丢失，但是符合 promtail 的设计初衷，并且具有良好的容错性和管理性。
  如果需要更高级的持久化功能，可以采用自定义目录或外部存储的方式。
  
  选择哪种方式，取决于你的具体需求和系统环境。
  
  需要注意的是：
  
  配置变更：如果更改了 position 文件的存储位置，需要在 promtail 的配置文件中进行相应的修改。
  数据一致性：如果使用外部存储，需要考虑数据一致性问题。
  
  希望这个解释能帮助你更好地理解 promtail 和 /run 目录之间的关系。
  
  如果你还有其他问题，欢迎随时提出。
  ```

- `kubernetes_sd_configs`工作原理是什么？
  ```shell
  简单来说，promtail运行在k8s集群中，promtail会和apiserver通信，可以获取到pod的元信息，之后在relabel_configs中进一系列重写，将元
  信息暴露出来，这些就是loki中的索引，可以用于查询。
  
  至此，有了这些元信息（标签/索引），如namespace=kube-system，pod=coredns-55b9c9ffdf-l2pb8，container=coredns，
  那么如何通过这些信息，找到这个pod的日志文件在哪呢？
  - action: replace
    replacement: /var/log/pods/*$1/*.log
    separator: /
    source_labels:
      - __meta_kubernetes_pod_uid
      - __meta_kubernetes_pod_container_name
    target_label: __path__
  
  以上的配置即可找到相对应的文件，举例来说，replacement改写后结果是`/var/log/pods/*6c4f4d7e-f548-4309-9df6-e6bde69ac222/promtail/0.log`，
  而实际路径为`/var/log/pods/grafana_promtail-hps4b_6c4f4d7e-f548-4309-9df6-e6bde69ac222/promtail/0.log`。
  那这里就会有一个疑问了，为什么不直接使用`/var/log/pods/*/promtail/0.log`呢？
  
  原因：/var/log/pods下可能有多个子目录，每个目录对应一个不同的Pod UID。使用通配符 * 匹配所有子目录中的日志文件，可能会导致日志文件
  匹配不准确，特别是如果有多个相同容器名称的日志目录。如果匹配到多个目录下的日志文件，那么在loki中查询到的内容就是别的pod的日志了。 
  ```
