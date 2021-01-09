#!/bin/bash

vmip="192.168.122.10"

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi


reload_sched sda

array=( noop deadline cfq  )
#array=( ortddl )
param="-m 0 -l 120 -q 0 -d /home/darfux/ort_test/test1"
echo $param > data.config

# ssh -oStrictHostKeyChecking=no darfux@$vmip "rm /home/darfux/orthrus_test; dd if=/dev/zero of=/home/darfux/orthrus_test bs=1M count=64 oflag=sync;sync"

for sched in "${array[@]}"
do
  chsched sda $sched
  echo "Testing $sched"
  sleep 5

  echo "/mnt/paper_test/tool/main.out $param | tee /mnt/paper_test/idle_latency/$sched.log"
  ssh -oStrictHostKeyChecking=no darfux@$vmip "/mnt/paper_test/tool/main.out $param > /mnt/paper_test/idle_latency/$sched.log"
  if [[ ! $? -eq 0 ]]; then
    echo Interrupt or Error
    exit
  fi
  sleep 60
done
