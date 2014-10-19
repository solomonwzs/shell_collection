#!/bin/bash

N=20
M=3
FINISH=0
FIFO=/tmp/$$.fifo

mkfifo $FIFO
exec 3<>$FIFO
trap "rm $FIFO; exit" SIGINT SIGTERM

for i in $(seq 1 $M); do
    echo $i>&3
done

while [ "$FINISH" -lt "$N" ]; do
    echo ":$FINISH"
    FINISH=$(($FINISH+1))
    #read -u3 j
    #{
    #    sleep 0.5
    #    echo $j>&3
    #    echo "$i $j"
    #} &
done #< <(seq 1 $N)

wait

exec 3>&-
exec 3<&-
rm $FIFO

echo "end"
