#!/bin/sh

main() {
  while [ ! -e "/var/lib/k0s/bin/ctr" ]; do
    echo 'waiting containerd inited'
    sleep 1
  done

  while [ ! -e "/run/k0s/containerd.sock" ]; do
    echo 'waiting /run/k0s/containerd.sock'
    sleep 1
  done

  sleep 5

  get_ns

  NAMESPACE=""

  while [ -z $NAMESPACE ]; do
    echo 'waiting containerd init namespace'
    get_ns
    sleep 1
  done

  sleep 10

  IMAGES=$(/var/lib/k0s/bin/ctr -a /run/k0s/containerd.sock -n k8s.io images ls | grep pause)

  if [ -z $IMAGES ]; then
      /var/lib/k0s/bin/ctr -a /run/k0s/containerd.sock -n k8s.io images pull registry.cn-shanghai.aliyuncs.com/k0s_on_handson/pause:3.2
      /var/lib/k0s/bin/ctr -a /run/k0s/containerd.sock -n k8s.io images tag registry.cn-shanghai.aliyuncs.com/k0s_on_handson/pause:3.2 k8s.gcr.io/pause:3.2
  else
      echo 'no need pull pause'
  fi

  echo 'pull pause done'
}

get_ns(){
  NAMESPACE=$(/var/lib/k0s/bin/ctr -a /run/k0s/containerd.sock ns ls|grep k8s)
}

main