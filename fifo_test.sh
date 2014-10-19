#!/bin/bash

N=20
FINISH=0
IDLE=3
FIFO=/tmp/$$.fifo

mkfifo $FIFO
exec 3<>$FIFO
trap "rm $FIFO; exit" SIGINT SIGTERM

for i in $(seq 1 $N); do
    echo "task $i">&3
done

while [ "$FINISH" -lt "$N" ]; do
    read -u3 tag args

    if [ "$tag" == "task" ] && [ "$IDLE" -gt 0 ]; then
        IDLE=$(($IDLE-1))
        {
            sleep 0.2
            echo "$args ok"
            echo "ok -" >&3
        } &
    elif [ "$tag" == "task" ] && [ "$IDLE" -eq 0 ]; then
        echo "task $args" >&3
    elif [ "$tag" == "ok" ]; then
        IDLE=$(($IDLE+1))
        FINISH=$(($FINISH+1))
    fi
done

wait

exec 3>&-
exec 3<&-
rm $FIFO

echo "end"
