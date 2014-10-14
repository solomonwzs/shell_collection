#!/bin/sh

N=5
FIFO=/tmp/$$.fifo

mkfifo $FIFO
exec 3<>$FIFO

loop(){
    for i in $(seq 1 $N); do
        #until read tmp; do
        #    :
        #done
        read -u3 tmp tmp1
        echo "$tmp - $tmp1 out"
    done < $FIFO
}

loop &
LOOP_PID=$!
for i in $(seq 1 $N); do
    #sleep 0.1; echo $i > $FIFO
    sleep 0.1; echo "$i $i $i" >&3
    echo "$i in"
done
wait $LOOP_PID

echo "end"

rm $FIFO
