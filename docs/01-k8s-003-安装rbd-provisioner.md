# nfs-client-provisioner安装说明文档

## storage-class类型，ceph rbd提供pvc功能，生产环境首选。

## 准备工作
- 准备ceph集群，其版本最高为mimic，即为13，这是因为quay.io/external_storage/rbd-provisioner:v2.1.1-k8s1.11镜像最高只支持这个版本。
- 在k8s主机上能进行创建rbd块，格式化，挂载及写入文件的测试。
- 参考文档：https://blog.51cto.com/fengjicheng/2401702
    
## 准备ceph相关的pool
- node01.ceph.freedom.org上执行命令：
  ```shell
  ceph osd pool create kubernetes-datastorage-rbd-infra 64 64
  ceph osd pool create kubernetes-datastorage-rbd-mysql 64 64
  ceph osd pool create kubernetes-datastorage-rbd-redis 64 64

  ceph osd pool set kubernetes-datastorage-rbd-infra size 1
  ceph osd pool set kubernetes-datastorage-rbd-mysql size 1
  ceph osd pool set kubernetes-datastorage-rbd-redis size 1
  
  ceph osd pool application enable kubernetes-datastorage-rbd-infra rgw
  ceph osd pool application enable kubernetes-datastorage-rbd-mysql rgw
  ceph osd pool application enable kubernetes-datastorage-rbd-redis rgw
  ```

## 在master01.k8s.freedom.org执行生成的manifests文件即可。

  ```shell
  kubectl apply -f deploy-kubernetes-storageclass-rbd-infra.yaml
  kubectl apply -f deploy-kubernetes-storageclass-rbd-mysql.yaml
  kubectl apply -f deploy-kubernetes-storageclass-rbd-redis.yaml
  ```

## k8s集群节点安装ceph客户端
  ```shell
  ansible-playbook deploy-kubernetes-workers.yml -t ceph
  ansible-playbook deploy-kubernetes-masters.yml -t ceph
  ```