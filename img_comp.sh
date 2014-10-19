#!/bin/bash

# example: ./img_comp.sh /img/dir/path

PROCESS_NUM=2
ARGS_LIST=()
PIDS=()
PROGRESS_BAR_LEN=50
START_TIME=$(date +%s)

TMP_DIR=/tmp/$$
MSG_FIFO=$TMP_DIR/msg.fifo
TASK_LIST_FILE=$TMP_DIR/task_list
#TASK_COUNT=0

COLOR_END="\033[0m"
COLOR_RED="\033[01;31m"
COLOR_GREEN="\033[01;32m"
COLOR_YELLOW="\033[01;33m"
COLOR_BLUE="\033[01;34m"
COLOR_PURPLE="\033[01;35m"
COLOR_CYAN="\033[01;36m"

MSG_STOP=0
MSG_HANDLE_1=1
MSG_HANDLE_2=2


error_msg(){
    echo -e "$COLOR_RED$1$COLOR_END"
}

info_msg0(){
    echo -e "$1$COLOR_END"
}

info_msg1(){
    echo -e "$COLOR_GREEN$1$COLOR_END"
}

info_msg2(){
    echo -e "$COLOR_YELLOW$1$COLOR_END"
}

info_msg3(){
    echo -e "$COLOR_BLUE$1$COLOR_END"
}

init_tmp_dir(){
    mkdir $TMP_DIR
    mkfifo $MSG_FIFO
}

clean_tmp_dir(){
    info_msg1 ">>> clean up..."
    rm -r $TMP_DIR
}

task_list(){
    find "$1" -iname "*.jpg" -print0
}

draw_progress_bar(){
    finish=$(($PROGRESS_BAR_LEN*$1/$2))
    #echo $(($(date +%s)-$START_TIME))|awk '{printf(">>> %02d:%02d [", $0/60, $0%60)}'
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

msg_queue_process(){
    while true; do
        read -u3 tag args
        if [ "$tag" -eq "$MSG_STOP" ]; then
            exit
        elif [ "$tag" -eq "$MSG_HANDLE_1" ]; then
            {
                map_process "$args"
                echo "$MSG_HANDLE_1 $args"
            } &
            PIDS+=("$!")
        elif [ "$tag" -eq "$MSG_HANDLE_2" ]; then
            :
        fi
    done
}

progress_bar_process(){
    for i in $(seq 1 $1); do
        read -u4 j
        draw_progress_bar $i $1
    done
    echo ""
}

map_process(){
    #size1=$(ls -l "$1"|cut -d" " -f5)
    #convert -quality 85 "$1" "$1"
    #size2=$(ls -l "$1"|cut -d" " -f5)
    #rate=$(bc <<< "scale=4; $size2/$size1*100")
    #info_msg0 "[OK] $1 rate=$rate%"

    sleep 0.1
}

reduce_process(){
    info_msg1 ">>> reduce ok"
}


init_tmp_dir
trap "clean_tmp_dir; exit" SIGINT SIGTERM

exec 3<>$MSG_FIFO
for i in $(seq 1 $PROCESS_NUM); do
    echo $i>&3
done

#### 1
#info_msg1 ">>> start..."
#while IFS="" read -r -d "" i; do
#    read -u3 j
#    {
#        map_process "$i"
#        echo $j>&3
#    } &
#    PIDS+=("$!")
#done < <(task_list "$@")
#### 1


### 2
info_msg1 ">>> start..."
exec 4<>$PROGRESS_BAR_FIFO


while IFS="" read -r -d "" i; do
    echo "$i">>$TASK_LIST_FILE
done < <(task_list "$@")
TASK_COUNT=$(wc -l "$TASK_LIST_FILE"|cut -d" " -f1)
info_msg2 ">>> $TASK_COUNT tasks"


progress_bar_process $TASK_COUNT &
draw_progress_bar 0 $TASK_COUNT
PIDS+=("$!")

while read i; do
    read -u3 j
    {
        map_process "$i"
        echo $j>&3
        echo $j>&4
    } &
    PIDS+=("$!")
done < $TASK_LIST_FILE
### 2


for i in "${PIDS[@]}"; do
    wait "$i"
done
reduce_process


exec 3>&-
exec 4>&-
clean_tmp_dir
info_msg1 ">>> end"
