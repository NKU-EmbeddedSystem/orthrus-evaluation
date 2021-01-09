#!/bin/bash
array=( noop deadline ortddl ortcfq )

for sched in "${array[@]}"
do
    rm ${sched}.log
done

for sched in "${array[@]}"
do
    cat ${sched}_*.log >> ${sched}.log
done
