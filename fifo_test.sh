#!/bin/sh

N=5
FIFO=/tmp/$$.fifo

mkfifo $FIFO
exec 3<>$FIFO

loop(){
    for i in $(seq 1 $N); do
        #read tmp < $FIFO
        read -u3 tmp
        echo "$i out"
    done
}

loop &
LOOP_PID=$!
for i in $(seq 1 $N); do
    #echo $i > $FIFO
    echo $i >&3
    echo "$i in"
done
wait $LOOP_PID

echo "end"

rm $FIFO
