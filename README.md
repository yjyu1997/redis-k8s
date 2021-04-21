## Redis集群 K8S部署

### 1.创建configMap

~~~sh
kubectl create configmap redis-conf --from-file=redis.conf --from-file update-node.sh 
~~~



### 2. 创建ServiceAccount(If Present请忽略)



https://github.com/yjyu1997/rocketmq-k8s/blob/master/nfs-provisioner/nfs-rbac.yaml

~~~sh
kubectl create -f nfs-rbac.yaml
~~~



### 3.创建StorageClass

~~~sh
kubectl create -f redis-nfs-class.yaml
~~~



### 4.创建Nfs-Provisioner

~~~sh
kubectl create -f redis-nfs-provisioner.yaml
~~~



### 5.创建StaticfulSet

~~~sh
kubectl create -f redis.yml
~~~





### 6.集群部署



1）新建一次性ubuntu容器

~~~sh
kubectl run -it ubuntu --image=ubuntu --restart=Never /bin/bash

~~~

2）使用redis-trib进行集群部署

~~~sh
cat > /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
 
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF
~~~

~~~sh
apt-get update
apt-get install -y vim wget python2.7 python-pip redis-tools dnsutils

~~~



~~~sh
pip install redis-trib
~~~



3）创建集群

~~~sh
redis-trib.py create \
  `dig +short redis-app-0.redis-service.default.svc.cluster.local`:6379 \
  `dig +short redis-app-1.redis-service.default.svc.cluster.local`:6379 \
  `dig +short redis-app-2.redis-service.default.svc.cluster.local`:6379

~~~



4）为每一个主节点添加从节点

~~~sh
redis-trib.py replicate \
  --master-addr `dig +short redis-app-0.redis-service.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-app-3.redis-service.default.svc.cluster.local`:6379

redis-trib.py replicate \
  --master-addr `dig +short redis-app-1.redis-service.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-app-4.redis-service.default.svc.cluster.local`:6379

redis-trib.py replicate \
  --master-addr `dig +short redis-app-2.redis-service.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-app-5.redis-service.default.svc.cluster.local`:6379

~~~





<font color=red>对外暴露服务 详见集群代理模式的部署</font>