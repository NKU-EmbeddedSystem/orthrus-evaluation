#!/bin/bash

function killdd() {
  echo "test over, kill dd"
  ssh -oStrictHostKeyChecking=no darfux@osdvm1.darfux.cc "killall dd"
  exit
}

trap killdd EXIT

VM1_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.11"
ssh $VM1_SSH_PARAM "rm /home/darfux/ort_test/test1;sync"
ssh $VM1_SSH_PARAM "bash -ec 'while true; do dd if=/dev/zero of=/home/darfux/ort_test/test1 bs=4M count=64 oflag=sync; sync; done'"
