#!/bin/bash

server=192.168.122.10

function killdd() {
  echo "test over, kill dd"
  ssh -oStrictHostKeyChecking=no darfux@$server "killall dd"
  exit
}

trap killdd EXIT

VM1_SSH_PARAM="-oStrictHostKeyChecking=no darfux@$server"
ssh $VM1_SSH_PARAM "rm /home/darfux/ort_test/test1;sync;killall dd"
ssh $VM1_SSH_PARAM "bash -ec 'while true; do dd if=/dev/zero of=/home/darfux/ort_test/test1 bs=8M count=128 oflag=sync; sync; done'"
