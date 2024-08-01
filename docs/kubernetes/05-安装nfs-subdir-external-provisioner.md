# 安装nfs-subdir-external-provisioner

## 前言
- https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

## 部署
- 使用helm安装nfs-subdir-external-provisioner。
- 下载nfs-subdir-external-provisioner对应的helm包，修改values.yaml中的相关值。
```shell
replicaCount: 3

image.repository: "harbor.freedom.org/registry.k8s.io/sig-storage/nfs-subdir-external-provisioner"
image.tag: v4.0.2

nfs.server: nfs.freedom.org
nfs.path: /data1/kubernetes/infra
nfs.volumeName: nfs-subdir-external-provisioner-root
nfs.reclaimPolicy: Retain

storageClass.name: infra
storageClass.provisionerName: infra
```

```shell
replicaCount: 3

image.repository: "harbor.freedom.org/registry.k8s.io/sig-storage/nfs-subdir-external-provisioner"
image.tag: v4.0.2

nfs.server: nfs.freedom.org
nfs.path: /data1/kubernetes/mysql
nfs.volumeName: nfs-subdir-external-provisioner-root
nfs.reclaimPolicy: Retain

storageClass.name: mysql
storageClass.provisionerName: mysql
```

```shell
replicaCount: 3

image.repository: "harbor.freedom.org/registry.k8s.io/sig-storage/nfs-subdir-external-provisioner"
image.tag: v4.0.2

nfs.server: nfs.freedom.org
nfs.path: /data1/kubernetes/redis
nfs.volumeName: nfs-subdir-external-provisioner-root
nfs.reclaimPolicy: Retain

storageClass.name: redis
storageClass.provisionerName: redis
```

## 测试
- pvc-test.yml
```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim-infra
  annotations:
    nfs.io/storage-path: "test-path" # not required, depending on whether this annotation was shown in the storage class description
spec:
  storageClassName: infra
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim-mysql
  annotations:
    nfs.io/storage-path: "test-path" # not required, depending on whether this annotation was shown in the storage class description
spec:
  storageClassName: mysql
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim-redis
  annotations:
    nfs.io/storage-path: "test-path" # not required, depending on whether this annotation was shown in the storage class description
spec:
  storageClassName: redis
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```

- 结果
```shell
[root@master-1.k8s.freedom.org ~ 17:25]# 1> kubectl get pvc
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
test-claim-infra   Bound    pvc-16cba2cc-5a38-43de-b1ab-44bb291a217f   10Gi       RWX            infra          <unset>                 5h45m
test-claim-mysql   Bound    pvc-3dc6eee3-678d-4899-abfa-c8b834a4aec9   10Gi       RWX            mysql          <unset>                 5h45m
test-claim-redis   Bound    pvc-dc5d0890-ec05-40ca-8d07-96589b0422ef   10Gi       RWX            redis          <unset>                 5h45m
[root@master-1.k8s.freedom.org ~ 17:26]# 2> 
```