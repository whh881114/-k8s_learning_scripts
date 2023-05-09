{
  type: "nfs",

  namespace: "storage-class",
  image: "harbor.freedom.org/quay.io/nfs-client-provisioner",
  image_tag: "v3.1.0-k8s1.11",
  image_pull_policy: "IfNotPresent",

  replicas: 3,
  requests_cpu: "100m",
  requests_memory: "64Mi",
  limits_cpu: "1000m",
  limits_memory: "1024Mi",

  instances: [{name: "infra", nfs_server: "nfs.freedom.org", nfs_path: "/data/k8s-pvc-nfs/bj/infra"},
    {name: "mysql", nfs_server: "nfs.freedom.org", nfs_path: "/data/k8s-pvc-nfs/bj/mysql"},
    {name: "redis", nfs_server: "nfs.freedom.org", nfs_path: "/data/k8s-pvc-nfs/bj/redis"},
    {name: "biz", nfs_server: "nfs.freedom.org", nfs_path: "/data/k8s-pvc-nfs/bj/biz"},
    {name: "demo", nfs_server: "nfs.freedom.org", nfs_path: "/data/k8s-pvc-nfs/bj/demo"},
  ],
}