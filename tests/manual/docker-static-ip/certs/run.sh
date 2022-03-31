#!/bin/sh
rm -rf /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m1.data /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m2.data /Users/mustafa/workspace/go/src/etcd/etcd/test-temp/m3.data

goreman -f /certs/Procfile start &

# TODO: remove random sleeps
sleep 7s

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs/ca.crt \
  --cert=/certs/server.crt \
  --key=/certs/server.key.insecure \
  --endpoints=https://localhost:2379 \
  endpoint health --cluster

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs/ca.crt \
  --cert=/certs/server.crt \
  --key=/certs/server.key.insecure \
  --endpoints=https://localhost:2379,https://localhost:22379,https://localhost:32379 \
  put abc def

ETCDCTL_API=3 ./etcdctl \
  --cacert=/certs/ca.crt \
  --cert=/certs/server.crt \
  --key=/certs/server.key.insecure \
  --endpoints=https://localhost:2379,https://localhost:22379,https://localhost:32379 \
  get abc
