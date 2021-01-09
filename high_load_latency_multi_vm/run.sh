#!/bin/bash
set -x

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi

function do_clean() {
  echo Interrupt or Error
  kill $vm0pid
  kill -0
  exit 1
}

TEST_TOOL="/mnt/paper_test/tool/main.out"
VM_PWD=k

reload_sched sda

array=( noop deadline ortddl ortcfq )
#array=( ortddl )
# in s
test_duration=$((60))
param="-m 0 -l $test_duration -i 2000 -r 1 -c 8192 -u 10 -q 0 -d /home/darfux/ort_test/test1"
echo $param > data.config
VM_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.1"

# ssh $VM0_SSH_PARAM "rm /home/darfux/orthrus_test;sync; dd if=/dev/zero of=/home/darfux/orthrus_test bs=1M count=64 oflag=sync;sync"


trap do_clean EXIT
for sched in "${array[@]}"
do
  pids=()
  for (( i = 1; i < 5; i++ )); do
     ssh ${VM_SSH_PARAM}${i} "sync"
     ssh ${VM_SSH_PARAM}${i} "killall -9 main.out"
  done
  chsched sda $sched

  echo "Testing $sched"
  sleep 15
  bash vm0highload.sh > highload_$sched.log 2>&1 &
  vm0pid=$!
  sync

  echo "$TEST_TOOL $param | tee $(pwd)/$sched.log"


  for (( i = 1; i < 5; i++ )); do
      ssh ${VM_SSH_PARAM}${i} "killall -9 main.out"
      ssh ${VM_SSH_PARAM}${i} " $TEST_TOOL $param > $(pwd)/${sched}_$i.log" &
      pids[${i}]=$!
  done

  for pid in ${pids[*]}; do
      wait $pid
      if [[ ! $? -eq 0 ]]; then
          do_clean
      fi
  done


  kill $vm0pid

  sleep 15
done

do_clean
