#!/bin/bash

function killdd() {
  echo "test over, kill dd"
  ssh -oStrictHostKeyChecking=no darfux@osdvm1.darfux.cc "killall dd"
  exit
}

trap killdd SIGINT

VM1_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.11"
ssh $VM1_SSH_PARAM "rm /home/darfux/test.dat;sync"
while [[ true ]]; do
  ssh $VM1_SSH_PARAM "dd if=/dev/zero of=/home/darfux/test.dat bs=4M count=64 oflag=sync;sync"
done
