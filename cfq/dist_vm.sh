#!/bin/bash

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi

function do_clean() {
  echo Interrupt or Error
  for (( i = 0; i < $vmnum; i++ )); do
    echo "stopping vm$i"
    ssh $VM_SSH_PARAM$i "killall main.out"
  done
  exit 1
}

TEST_TOOL="/mnt/paper_test/tool/main.out"
VM_PWD=k

# reloadcfq sdb
chsched sdb cfq

# in seconds
test_duration=$((60))
VM_SSH_PARAM="-oStrictHostKeyChecking=no darfux@192.168.122.1"
vmnum=8
seq=1

echo $test_duration > /mnt/paper_test/cfq/test_duration.conf


trap do_clean INT

# cold start
for (( i = 0; i < $vmnum; i++ )); do
  ssh $VM_SSH_PARAM$i " echo ok"
done

sleep 2

for (( i = 0; i < $vmnum; i++ )); do
  prio=$(($i))
  cfqprio=$(($prio+16384))
  echo "starting vm$i"
  ssh $VM_SSH_PARAM$i " bash -c 'sleep 2; /mnt/paper_test/tool/main.out -u $i -m 0 -s $seq  -c $cfqprio -f 1 -l $test_duration -d /home/darfux/ort_test/test1 > /mnt/paper_test/cfq/$prio.log' &" &
done

sleep $(($test_duration+4))

do_clean
