#!/bin/bash

t0=`date +"%s"`

while [[ 1 ]]; do
    t1=`date +"%s"`
    t=$(($t1-$t0))

    m=$(($t/60))
    s=$(($t%60))
    
    str=`printf ">>> %.2d:%.2d\r" $m $s`
    echo -ne "$str"
    sleep 1
done
