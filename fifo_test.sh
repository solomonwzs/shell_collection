#!/bin/bash

N=50
M=4
FINISH=0
IDLE=4
PROGRESS_BAR_LEN=50
FIFO=/tmp/$$.fifo

map(){
    sleep 0.5
}

function draw_progress_bar(){
    finish=$(($PROGRESS_BAR_LEN*$1/$2))
    echo -ne ">>> ["
    for i in $(seq 1 $finish); do
        echo -ne "#"
    done
    for i in $(seq $(($finish+1)) $PROGRESS_BAR_LEN); do
        echo -ne "-"
    done
    echo -ne "] $(($1*100/$2))%"
    echo -ne "\r"
}

mkfifo $FIFO
exec 3<>$FIFO
trap "rm $FIFO; exit" SIGINT SIGTERM

for i in $(seq 1 $M); do
    echo "task $i">&3
done

#while [ "$FINISH" -lt "$N" ]; do
#    read -u3 tag args
#
#    if [ "$tag" == "task" ] && [ "$IDLE" -gt 0 ]; then
#        IDLE=$(($IDLE-1))
#        {
#            sleep 0.2
#            echo "$args ok"
#            echo "ok -" >&3
#        } &
#    elif [ "$tag" == "task" ] && [ "$IDLE" -eq 0 ]; then
#        echo "task $args" >&3
#    elif [ "$tag" == "ok" ]; then
#        IDLE=$(($IDLE+1))
#        FINISH=$(($FINISH+1))
#    fi
#done

draw_progress_bar 0 $N
while IFS="" read -r i; do
    while true; do
        read -u3 tag args
        if [ "$tag" == "task" ]; then
            {
                map $i
                echo "ok -" >&3
                echo "task $args" >&3
            } &
            break
        elif [ "$tag" == "ok" ]; then
            FINISH=$(($FINISH+1))
            draw_progress_bar $FINISH $N
        fi
    done
done < <(seq 1 $N)

while [ "$FINISH" -lt $N ]; do
    read -u3 tag args
    if [ "$tag" == "ok" ]; then
        FINISH=$(($FINISH+1))
        draw_progress_bar $FINISH $N
    fi
done
echo ""

exec 3>&-
exec 3<&-
rm $FIFO

echo "end"
