# 使用filebeat收集日志（filestream）


## 说明
- elastic版本为`8.9.0`。

- haproxy日志格式之间修改成json内容了，所以此次使用filestream模式收集日志并解析json内容。

- 官方文档：
  - https://www.elastic.co/guide/en/beats/filebeat/8.9/configuring-howto-filebeat.html
  - https://www.elastic.co/guide/en/beats/filebeat/8.9/filebeat-input-filestream.html
  - https://www.elastic.co/guide/en/beats/filebeat/8.9/replace-fields.html
  - https://www.elastic.co/guide/en/beats/filebeat/8.9/decode-json-fields.html

- **文档中记录的密码使用mkpasswd生成随机密码，此外，此密码仅用于个人实验环境。**


## 配置文件
- 配置文件内容如下。
  ```shell
  filebeat.inputs:
    - type: filestream
      id: haproxy-server-logs
      paths:
        - /var/opt/rh/rh-haproxy18/log/haproxy.log
  
  
  setup.template.name: "haproxy-server-logs"
  setup.template.pattern: "haproxy-server-logs-*"
  setup.template.settings:
    index.number_of_shards: 1
  
  
  setup.kibana:
    host: "kibana.freedom.org:5601"
  
  
  output.elasticsearch:
    hosts: ["http://elastic.freedom.org:9200"]
    index: "haproxy-server-logs-%{[agent.version]}-%{+yyyy.MM.dd}"
  
  
  processors:
    # 删除haproxy日志中的前缀："Aug 12 11:39:32 localhost haproxy[67261]: "
    # 正则中使用元素时需要再加上反斜杠，如\S就要写成\\S，filebeat好像对正则支持度还不够全面，只能使用比较笨的方法写了。
    - replace:
        fields:
          - field: "message"
            pattern: "^\\S+\\s\\S+\\s\\S+\\s\\S+\\s\\S+\\s"
            replacement: ""
    # 删除系统打印的前缀后，就可以进行json解析了。
    - decode_json_fields:
        fields: ["message"]
        target: ""
        add_error_key: true
  ```

## 结果
- haproxy http日志解析。
  ```json
  {
    "_index": ".ds-haproxy-server-logs-8.9.0-2023.08.12-2023.08.12-000001",
    "_id": "rBy06IkBZokiYTLwBQ72",
    "_version": 1,
    "_score": 0,
    "_source": {
      "@timestamp": "2023-08-12T07:44:12.336Z",
      "client_ip": "10.8.255.9",
      "time_request": "10725",
      "datetime": "12/Aug/2023:15:43:42.280",
      "http_request": "GET /stats HTTP/1.1",
      "client_port": "43179",
      "action": "23",
      "server2client_bytes_read": "45484",
      "server_name": "<STATS>",
      "message": "{\"client_ip\":\"10.8.255.9\",\"client_port\":\"43179\",\"datetime\":\"12/Aug/2023:15:43:42.280\",\"frontend_name_transport\":\"haproxy-stats\",\"backend_name\":\"haproxy-stats\",\"server_name\":\"<STATS>\",\"time_request\":\"10725\",\"time_wait\":\"0\",\"time_conn\":\"0\",\"time_reponse\":\"0\",\"time_total\":\"10726\",\"status_code\":\"200\",\"server2client_bytes_read\":\"45484\",\"captured_request_cookie\":\"-\",\"captured_response_cookie\":\"-\",\"termination_state_with_cooke_status\":\"LR--\",\"termination_state\":\"LR\",\"action\":\"23\",\"frontend_concurrent_connections\":\"1\",\"backend_concurrent_connections\":\"0\",\"server_concurrent_connections\":\"0\",\"retries\":\"0\",\"srv_queue\":\"0\",\"backend_queue\":\"0\",\"captured_request_headers\":\"\",\"http_request\":\"GET /stats HTTP/1.1\"}",
      "host": {
        "name": "haproxy.k8s-flannel.freedom.org"
      },
      "captured_response_cookie": "-",
      "ecs": {
        "version": "8.0.0"
      },
      "srv_queue": "0",
      "time_reponse": "0",
      "retries": "0",
      "frontend_name_transport": "haproxy-stats",
      "log": {
        "offset": 1444520,
        "file": {
          "path": "/var/opt/rh/rh-haproxy18/log/haproxy.log"
        }
      },
      "input": {
        "type": "filestream"
      },
      "agent": {
        "id": "aa5d47fc-d0ce-4244-8c70-864ac71a639c",
        "name": "haproxy.k8s-flannel.freedom.org",
        "type": "filebeat",
        "version": "8.9.0",
        "ephemeral_id": "04ceb227-5ff5-478f-ac1f-452459d7a3da"
      },
      "time_total": "10726",
      "backend_concurrent_connections": "0",
      "backend_queue": "0",
      "captured_request_cookie": "-",
      "server_concurrent_connections": "0",
      "status_code": "200",
      "termination_state": "LR",
      "termination_state_with_cooke_status": "LR--",
      "backend_name": "haproxy-stats",
      "time_wait": "0",
      "time_conn": "0",
      "frontend_concurrent_connections": "1",
      "captured_request_headers": ""
    },
    "fields": {
      "server2client_bytes_read": [
        "45484"
      ],
      "server_name": [
        "<STATS>"
      ],
      "time_reponse": [
        "0"
      ],
      "status_code": [
        "200"
      ],
      "client_port": [
        "43179"
      ],
      "agent.type": [
        "filebeat"
      ],
      "datetime": [
        "12/Aug/2023:15:43:42.280"
      ],
      "frontend_concurrent_connections": [
        "1"
      ],
      "time_total": [
        "10726"
      ],
      "backend_concurrent_connections": [
        "0"
      ],
      "time_wait": [
        "0"
      ],
      "backend_name": [
        "haproxy-stats"
      ],
      "action": [
        "23"
      ],
      "client_ip": [
        "10.8.255.9"
      ],
      "agent.name": [
        "haproxy.k8s-flannel.freedom.org"
      ],
      "host.name": [
        "haproxy.k8s-flannel.freedom.org"
      ],
      "captured_response_cookie": [
        "-"
      ],
      "termination_state": [
        "LR"
      ],
      "captured_request_cookie": [
        "-"
      ],
      "frontend_name_transport": [
        "haproxy-stats"
      ],
      "srv_queue": [
        "0"
      ],
      "termination_state_with_cooke_status": [
        "LR--"
      ],
      "input.type": [
        "filestream"
      ],
      "log.offset": [
        1444520
      ],
      "agent.hostname": [
        "haproxy.k8s-flannel.freedom.org"
      ],
      "message": [
        "{\"client_ip\":\"10.8.255.9\",\"client_port\":\"43179\",\"datetime\":\"12/Aug/2023:15:43:42.280\",\"frontend_name_transport\":\"haproxy-stats\",\"backend_name\":\"haproxy-stats\",\"server_name\":\"<STATS>\",\"time_request\":\"10725\",\"time_wait\":\"0\",\"time_conn\":\"0\",\"time_reponse\":\"0\",\"time_total\":\"10726\",\"status_code\":\"200\",\"server2client_bytes_read\":\"45484\",\"captured_request_cookie\":\"-\",\"captured_response_cookie\":\"-\",\"termination_state_with_cooke_status\":\"LR--\",\"termination_state\":\"LR\",\"action\":\"23\",\"frontend_concurrent_connections\":\"1\",\"backend_concurrent_connections\":\"0\",\"server_concurrent_connections\":\"0\",\"retries\":\"0\",\"srv_queue\":\"0\",\"backend_queue\":\"0\",\"captured_request_headers\":\"\",\"http_request\":\"GET /stats HTTP/1.1\"}"
      ],
      "captured_request_headers": [
        ""
      ],
      "backend_queue": [
        "0"
      ],
      "retries": [
        "0"
      ],
      "time_request": [
        "10725"
      ],
      "@timestamp": [
        "2023-08-12T07:44:12.336Z"
      ],
      "server_concurrent_connections": [
        "0"
      ],
      "agent.id": [
        "aa5d47fc-d0ce-4244-8c70-864ac71a639c"
      ],
      "ecs.version": [
        "8.0.0"
      ],
      "log.file.path": [
        "/var/opt/rh/rh-haproxy18/log/haproxy.log"
      ],
      "agent.ephemeral_id": [
        "04ceb227-5ff5-478f-ac1f-452459d7a3da"
      ],
      "time_conn": [
        "0"
      ],
      "agent.version": [
        "8.9.0"
      ],
      "http_request": [
        "GET /stats HTTP/1.1"
      ]
    }
  } 
  ```

- haproxy tcp日志解析。
  ```json
  {
  "_index": ".ds-haproxy-server-logs-8.9.0-2023.08.12-2023.08.12-000001",
  "_id": "hRy96IkBZokiYTLwiw_N",
  "_version": 1,
  "_score": 0,
  "_source": {
    "@timestamp": "2023-08-12T07:54:42.533Z",
    "client_ip": "10.8.255.9",
    "datetime": "12/Aug/2023:15:43:35.568",
    "backend_name": "tcp-k8s-pagoda-ingress-nginx-https",
    "termination_state": "--",
    "backend_concurrent_connections": "2",
    "client_port": "43215",
    "message": "{\"client_ip\":\"10.8.255.9\",\"client_port\":\"43215\",\"datetime\":\"12/Aug/2023:15:43:35.568\",\"frontend_name_transport\":\"tcp-k8s-pagoda-ingress-nginx-https\",\"backend_name\":\"tcp-k8s-pagoda-ingress-nginx-https\",\"server_name\":\"master02.k8s-flannel.freedom.org\",\"time_wait\":\"1\",\"time_conn\":\"1\",\"time_total\":\"662993\",\"server2client_bytes_read\":\"135042\",\"termination_state\":\"--\",\"action\":\"22\",\"frontend_concurrent_connections\":\"3\",\"backend_concurrent_connections\":\"2\",\"server_concurrent_connections\":\"0\",\"retries\":\"0\",\"srv_queue\":\"0\",\"backend_queue\":\"0\"}",
    "input": {
      "type": "filestream"
    },
    "retries": "0",
    "time_conn": "1",
    "time_total": "662993",
    "frontend_concurrent_connections": "3",
    "backend_queue": "0",
    "server2client_bytes_read": "135042",
    "ecs": {
      "version": "8.0.0"
    },
    "action": "22",
    "host": {
      "name": "haproxy.k8s-flannel.freedom.org"
    },
    "srv_queue": "0",
    "server_name": "master02.k8s-flannel.freedom.org",
    "time_wait": "1",
    "frontend_name_transport": "tcp-k8s-pagoda-ingress-nginx-https",
    "server_concurrent_connections": "0",
    "log": {
      "offset": 1507087,
      "file": {
        "path": "/var/opt/rh/rh-haproxy18/log/haproxy.log"
      }
    },
    "agent": {
      "version": "8.9.0",
      "ephemeral_id": "04ceb227-5ff5-478f-ac1f-452459d7a3da",
      "id": "aa5d47fc-d0ce-4244-8c70-864ac71a639c",
      "name": "haproxy.k8s-flannel.freedom.org",
      "type": "filebeat"
    }
  },
  "fields": {
    "server2client_bytes_read": [
      "135042"
    ],
    "server_name": [
      "master02.k8s-flannel.freedom.org"
    ],
    "client_port": [
      "43215"
    ],
    "agent.type": [
      "filebeat"
    ],
    "datetime": [
      "12/Aug/2023:15:43:35.568"
    ],
    "frontend_concurrent_connections": [
      "3"
    ],
    "time_total": [
      "662993"
    ],
    "backend_concurrent_connections": [
      "2"
    ],
    "time_wait": [
      "1"
    ],
    "backend_name": [
      "tcp-k8s-pagoda-ingress-nginx-https"
    ],
    "action": [
      "22"
    ],
    "client_ip": [
      "10.8.255.9"
    ],
    "agent.name": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "host.name": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "termination_state": [
      "--"
    ],
    "frontend_name_transport": [
      "tcp-k8s-pagoda-ingress-nginx-https"
    ],
    "srv_queue": [
      "0"
    ],
    "input.type": [
      "filestream"
    ],
    "log.offset": [
      1507087
    ],
    "agent.hostname": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "message": [
      "{\"client_ip\":\"10.8.255.9\",\"client_port\":\"43215\",\"datetime\":\"12/Aug/2023:15:43:35.568\",\"frontend_name_transport\":\"tcp-k8s-pagoda-ingress-nginx-https\",\"backend_name\":\"tcp-k8s-pagoda-ingress-nginx-https\",\"server_name\":\"master02.k8s-flannel.freedom.org\",\"time_wait\":\"1\",\"time_conn\":\"1\",\"time_total\":\"662993\",\"server2client_bytes_read\":\"135042\",\"termination_state\":\"--\",\"action\":\"22\",\"frontend_concurrent_connections\":\"3\",\"backend_concurrent_connections\":\"2\",\"server_concurrent_connections\":\"0\",\"retries\":\"0\",\"srv_queue\":\"0\",\"backend_queue\":\"0\"}"
    ],
    "backend_queue": [
      "0"
    ],
    "retries": [
      "0"
    ],
    "@timestamp": [
      "2023-08-12T07:54:42.533Z"
    ],
    "server_concurrent_connections": [
      "0"
    ],
    "agent.id": [
      "aa5d47fc-d0ce-4244-8c70-864ac71a639c"
    ],
    "ecs.version": [
      "8.0.0"
    ],
    "log.file.path": [
      "/var/opt/rh/rh-haproxy18/log/haproxy.log"
    ],
    "agent.ephemeral_id": [
      "04ceb227-5ff5-478f-ac1f-452459d7a3da"
    ],
    "time_conn": [
      "1"
    ],
    "agent.version": [
      "8.9.0"
    ]
  }}
  ```

- haproxy 非json日志解析。
  ```json
  {
  "_index": ".ds-haproxy-server-logs-8.9.0-2023.08.12-2023.08.12-000001",
  "_id": "pRy06IkBZokiYTLwBQ72",
  "_version": 1,
  "_score": 0,
  "_source": {
    "@timestamp": "2023-08-12T07:44:12.335Z",
    "log": {
      "offset": 1439953,
      "file": {
        "path": "/var/opt/rh/rh-haproxy18/log/haproxy.log"
      }
    },
    "message": "Server tcp-k8s-pagoda-ingress-nginx-https/master03.k8s-flannel.freedom.org is UP, reason: Layer4 check passed, check duration: 1ms. 3 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.",
    "input": {
      "type": "filestream"
    },
    "host": {
      "name": "haproxy.k8s-flannel.freedom.org"
    },
    "agent": {
      "version": "8.9.0",
      "ephemeral_id": "04ceb227-5ff5-478f-ac1f-452459d7a3da",
      "id": "aa5d47fc-d0ce-4244-8c70-864ac71a639c",
      "name": "haproxy.k8s-flannel.freedom.org",
      "type": "filebeat"
    },
    "ecs": {
      "version": "8.0.0"
    },
    "error": {
      "message": "parsing input as JSON: invalid character 'S' looking for beginning of value",
      "data": "Server tcp-k8s-pagoda-ingress-nginx-https/master03.k8s-flannel.freedom.org is UP, reason: Layer4 check passed, check duration: 1ms. 3 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.",
      "field": "message"
    }
  },
  "fields": {
    "error.field": [
      "message"
    ],
    "input.type": [
      "filestream"
    ],
    "log.offset": [
      1439953
    ],
    "agent.hostname": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "message": [
      "Server tcp-k8s-pagoda-ingress-nginx-https/master03.k8s-flannel.freedom.org is UP, reason: Layer4 check passed, check duration: 1ms. 3 active and 0 backup servers online. 0 sessions requeued, 0 total in queue."
    ],
    "agent.type": [
      "filebeat"
    ],
    "@timestamp": [
      "2023-08-12T07:44:12.335Z"
    ],
    "agent.id": [
      "aa5d47fc-d0ce-4244-8c70-864ac71a639c"
    ],
    "ecs.version": [
      "8.0.0"
    ],
    "error.message": [
      "parsing input as JSON: invalid character 'S' looking for beginning of value"
    ],
    "log.file.path": [
      "/var/opt/rh/rh-haproxy18/log/haproxy.log"
    ],
    "agent.ephemeral_id": [
      "04ceb227-5ff5-478f-ac1f-452459d7a3da"
    ],
    "agent.name": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "agent.version": [
      "8.9.0"
    ],
    "host.name": [
      "haproxy.k8s-flannel.freedom.org"
    ],
    "error.data": [
      "Server tcp-k8s-pagoda-ingress-nginx-https/master03.k8s-flannel.freedom.org is UP, reason: Layer4 check passed, check duration: 1ms. 3 active and 0 backup servers online. 0 sessions requeued, 0 total in queue."
    ]
  }}
  ```