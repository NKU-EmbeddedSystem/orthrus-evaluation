#!/bin/bash

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi

function do_clean() {
  echo Interrupt or Error
  for (( i = 0; i < $num; i++ )); do
    ssh $VM_SSH_PARAM$i " killall main.out"
  done
  exit 1
}

TEST_TOOL="/mnt/paper_test/tool/main.out"
VM_PWD=k

chsched sdb noop

# array=( noop deadline ortddl ortcfq )
# array=( ortddl )
array=(8)
# in s
test_duration=$((60))
param="-m 0 -l $test_duration -s 1 -u 1 -q 1 -o 0"
echo $param > data.config
VM_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.1"

# ssh $VM0_SSH_PARAM "rm /home/darfux/orthrus_test;sync; dd if=/dev/zero of=/home/darfux/orthrus_test bs=1M count=64 oflag=sync;sync"

trap do_clean INT

# cold start
for (( i = 0; i < 8; i++ )); do
  ssh $VM_SSH_PARAM$i " echo ok"
done


for num in "${array[@]}"
do
  mkdir -p $num
  echo "testing $num threads"
  for (( i = 0; i < $num; i++ )); do
    ssh $VM_SSH_PARAM$i " sleep 1; $TEST_TOOL $param -d /home/darfux/ort_test/test1 | tee $(pwd)/$num/$i.log" &
  done

  sleep $(($test_duration+5))
  for (( i = 0; i < $num; i++ )); do
    ssh $VM_SSH_PARAM$i " killall main.out"
  done
done
