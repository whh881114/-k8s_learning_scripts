#!/bin/bash

# 当使用stateful部署模式为：workload为redis-cluster，其pod名称为redis-cluster-0/redis-cluster-1/redis-cluster-2/.....，
# 这里会存在一个问题：当所有的redis-cluster的pod同时删除时，redis-cluster将不可用，这是因为flannel/cilium网络插件
# 不支持固定pod的ip，使用脚本修改nodes.conf无法正常通知到其他pod。

# 现在使用stateful部署模式为多个workload搭建redis-cluster，即redis-cluster-1（pod名称为redis-cluster-1-0）/
# redis-cluster-2（pod名称为redis-cluster-2-0）/....，初始化使用各个workload的ClusterIP通信，这样只要ClusterIP类型的service
# 不删除就不会有影响，避免了pod全部删除后导致集群不可用的情况。


OPERATOR=$1
NAMESPACE=$2
WORKLOAD=$3
REPLICAS=$4


function scale_pod()
{
    replicas=$1
    kubectl -n $NAMESPACE scale statefulset/${PODNAME} --replicas=$replicas

    if [ $replicas -eq 0 ]; then
        pod_desired_state=terminated
        pod_num="0/0"
    else
        pod_desired_state=running
        pod_num="$replicas/$replicas"
    fi

    for((i=0; i<180; i++))
    do
        ret=`kubectl -n $NAMESPACE get statefulset ${PODNAME} | tail -n 1 | awk '{print $2}'`
        if [ $ret == "$pod_num" ]; then
            pod_state=$pod_desired_state
            echo "All the redis-cluster ${PODNAME} pods are $pod_state."
            break
        else
            pod_state="not $pod_desired_state"
            echo "All the redis-cluster ${PODNAME} pods are not $pod_desired_state. Please wait for a moment."
        fi
        sleep 10
    done

    if [ $pod_state == "not $pod_desired_state"  ]; then
        echo "All the redis-cluster ${PODNAME} pods cannot be $pod_state. Please check manually."
        exit 255
    fi
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 [namespace] [workload]"
    echo "Description: This script will initialize the redis cluster, and all data of it will be deleted."
    exit 0
fi

read -p "This script will initialize the redis cluster, and all data of it will be deleted.
        Enter y/yes to continue, other to exit: " input

case $(echo $input | tr [A-Z] [a-z]) in
    y|yes)
        scale_pod 1
        for((i=0; i<6; i++))
        do
            echo "rm -rf /data/*" | kubectl -n redis-cluster exec public-$i -c common -it -- /bin/bash
        done
        ;;
    *)
        echo "Exiting..."
        exit 0
        ;;
esac

# 将redis-cluster实例处于运行状态，从而进行删除文件。
scale_pod 6

for((i=0; i<6; i++))
do
    echo "rm -rf /data/*" | kubectl -n redis-cluster exec public-$i -c common -it -- /bin/bash
done

## 将redis-cluster实例数量改为0。
#scale_pod 0
#
## 将redis-cluster的实例数恢复成6。
#scale_pod 6
#
## 重建redis-cluster实例。
#kubectl -n $NAMESPACE exec ${PODNAME}-0 -it -- redis-cli -a "zuzo0qyiedklvsb7iudeuvydl&tkGQux" --cluster create --cluster-replicas 1 $(kubectl -n $NAMESPACE get pods -l app=$PODNAME -o jsonpath='{range.items[*]}{.status.podIP}:6379 ' | sed s/\ :6379\ $//)
#

