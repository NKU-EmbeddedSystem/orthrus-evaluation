#!/bin/bash
set -ex

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi


VM_PWD=k

chsched sda noop

# array=( noop deadline ortddl ortcfq )
# array=( ortddl )
array=(10)
type=(read)
# in s
test_duration=60
VM_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.10"

# ssh $VM0_SSH_PARAM "rm /home/darfux/orthrus_test;sync; dd if=/dev/zero of=/home/darfux/orthrus_test bs=1M count=64 oflag=sync;sync"

trap do_clean INT

# cold start

for t in "${type[@]}"; do
    for num in "${array[@]}"; do
      echo "testing $num threads"
      mkdir -p "${t}"
      ssh $VM_SSH_PARAM$i " sleep 1; rm -f /home/darfux/ort_test/fio.test && fio -name iops -rw=$t -bs=4k -thread -numjobs=${num} -iodepth 1 -filename /home/darfux/ort_test/fio.test -ioengine libaio -direct=1 -size=1500M -runtime=${test_duration}" > $(pwd)/$t/$num.log

      sleep 10

    done
done
