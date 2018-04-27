#!/bin/bash

sudo echo "Required sudo auth"

if [[ ! $? -eq 0 ]]; then
  exit
fi

function cleanup() {
  sudo killall main.out
}


trap cleanup SIGINT

hostname | grep -q sdvm
if [[ ! $? -eq 0 ]]; then
  TARGET=sdvm/test
else
  TARGET=ort_test
fi


seq=1
same=0
base=$same
ionice=0
runtime=30

echo $runtime > /mnt/paper_test/cfq/test_duration.conf

for (( i = 0; i <= 7; i++ )); do
  file_idx=$(($i))
  if [[ $same = 1 ]]; then
    file_idx=1
  fi
  prefix=""
  prio=$(($i))
  if [[ $ionice = 1 ]]; then
    prefix="ionice -c 2 -n $prio"
  fi
  sudo $prefix /mnt/paper_test/tool/main.out -u $i -m 0 -s $seq  -c $((16384+$prio)) -f 1 -o 1 -b $base -l $runtime -d /home/darfux/$TARGET/test$file_idx > /mnt/paper_test/cfq/$prio.log &
done


# /mnt/paper_test/tool/main.out -u 1 -m 0 -s 1  -c 16384 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/1.log &
# /mnt/paper_test/tool/main.out -u 2 -m 0 -s 1  -c 16385 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/2.log &
# /mnt/paper_test/tool/main.out -u 3 -m 0 -s 1  -c 16386 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/3.log &
# /mnt/paper_test/tool/main.out -u 4 -m 0 -s 1  -c 16387 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/4.log &
# /mnt/paper_test/tool/main.out -u 5 -m 0 -s 1  -c 16388 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/5.log &
# /mnt/paper_test/tool/main.out -u 6 -m 0 -s 1  -c 16389 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/6.log &
# /mnt/paper_test/tool/main.out -u 7 -m 0 -s 1  -c 16390 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/7.log &
# /mnt/paper_test/tool/main.out -u 8 -m 0 -s 1  -c 16391 -f 1 -d /home/darfux/$TARGET/test1 > /mnt/paper_test/cfq/8.log &

# /mnt/paper_test/tool/main.out -m 0 -u 1 -c 16384 -f 1 -d /home/darfux/sdvm/test/test1 > /mnt/paper_test/cfq/1.log &
# /mnt/paper_test/tool/main.out -m 0 -u 1 -c 16384 -f 1 -d /home/darfux/sdvm/test/test1 > /mnt/paper_test/cfq/2.log &
# /mnt/paper_test/tool/main.out -m 0 -u 2 -c 16391 -f 1 -d /home/darfux/sdvm/test/test3 > /mnt/paper_test/cfq/3.log &
# /mnt/paper_test/tool/main.out -m 0 -u 2 -c 16391 -f 1 -d /home/darfux/sdvm/test/test3 > /mnt/paper_test/cfq/4.log &
# /mnt/paper_test/tool/main.out -m 0 -u 3 -c 16387 -f 1 -d /home/darfux/sdvm/test/test5 > /mnt/paper_test/cfq/5.log &
#
# /mnt/paper_test/tool/main.out -u 1 -m 0 -s 1  -c 16384 -f 1 -d /home/darfux/ort_test/test1 > /mnt/paper_test/cfq/1.log
# /mnt/paper_test/tool/main.out -u 8 -m 0 -s 1  -c 16391 -f 1 -d /home/darfux/ort_test/test1 > /mnt/paper_test/cfq/8.log


sleep $(($runtime+2))


cleanup
