#!/bin/bash


ar=( "$@" )

echo ${ar[@]}

for num in "${ar[@]}"
do
  echo $num
done
