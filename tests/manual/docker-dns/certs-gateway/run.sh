#!/bin/sh
rm -rf /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m1.data /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m2.data /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m3.data

/etc/init.d/bind9 start

# get rid of hosts so go lookup won't resolve 127.0.0.1 to localhost
cat /dev/null >/etc/hosts

goreman -f /certs-gateway/Procfile start &

# TODO: remove random sleeps
sleep 7s

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs-gateway/ca.crt \
  --cert=/certs-gateway/server.crt \
  --key=/certs-gateway/server.key.insecure \
  --endpoints=https://m1.etcd.local:2379 \
  endpoint health --cluster

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs-gateway/ca.crt \
  --cert=/certs-gateway/server.crt \
  --key=/certs-gateway/server.key.insecure \
  --endpoints=https://m1.etcd.local:2379,https://m2.etcd.local:22379,https://m3.etcd.local:32379 \
  put abc def

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs-gateway/ca.crt \
  --cert=/certs-gateway/server.crt \
  --key=/certs-gateway/server.key.insecure \
  --endpoints=https://m1.etcd.local:2379,https://m2.etcd.local:22379,https://m3.etcd.local:32379 \
  get abc

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs-gateway/ca.crt \
  --cert=/certs-gateway/server.crt \
  --key=/certs-gateway/server.key.insecure \
  --endpoints=127.0.0.1:23790 \
  put ghi jkl

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs-gateway/ca.crt \
  --cert=/certs-gateway/server.crt \
  --key=/certs-gateway/server.key.insecure \
  --endpoints=127.0.0.1:23790 \
  get ghi
