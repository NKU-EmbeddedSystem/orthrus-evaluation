#!/bin/bash

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi

function do_clean() {
  echo Interrupt or Error
  kill $vm1pid
  exit 1
}

TEST_TOOL="/mnt/paper_test/tool/main.out"
VM_PWD=k

reload_sched sdb

# array=( noop deadline ortddl ortcfq )
array=( ortddl )
# in s
test_duration=$((300))
param="-m 0 -l $test_duration -i 2000 -r 1 -c 8192 -u 10 -q 0 -d /home/darfux/ort_test/test1"
echo $param > data.config
VM0_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.10"

# ssh $VM0_SSH_PARAM "rm /home/darfux/orthrus_test;sync; dd if=/dev/zero of=/home/darfux/orthrus_test bs=1M count=64 oflag=sync;sync"

bash vm1highload.sh &
vm1pid=$!

trap do_clean INT

for sched in "${array[@]}"
do
  chsched sdb $sched
  echo "Testing $sched"
  sleep 5

  echo "$TEST_TOOL $param | tee $(pwd)/$sched.log"


  ssh $VM0_SSH_PARAM " $TEST_TOOL $param | tee $(pwd)/$sched.log"

  if [[ ! $? -eq 0 ]]; then
    do_clean
  fi

  sleep 3
done

do_clean
