#!/bin/bash

# example: ./img_comp.sh /img/dir/path

PROCESS_NUM=2
TMP_DIR=/tmp/$$
PROCESS_FIFO=$TMP_DIR/pf.fifo
PROGRESS_BAR_FIFO=$TMP_DIR/pbf.fifo
COMPLETE_COUNT=0
ARGS_LIST=()
PIDS=()
PROGRESS_BAR_LEN=50
START_TIME=$(date +%s)

MSG_END="\033[0m"
MSG_RED="\033[01;31m"
MSG_GREEN="\033[01;32m"
MSG_YELLOW="\033[01;33m"
MSG_BLUE="\033[01;34m"
MSG_PURPLE="\033[01;35m"
MSG_CYAN="\033[01;36m"

function error_msg(){
    echo -e "$MSG_RED$1$MSG_END"
}

function info_msg0(){
    echo -e "$1$MSG_END"
}

function info_msg1(){
    echo -e "$MSG_GREEN$1$MSG_END"
}

function info_msg2(){
    echo -e "$MSG_YELLOW$1$MSG_END"
}

function info_msg3(){
    echo -e "$MSG_BLUE$1$MSG_END"
}

function init_tmp_dir(){
    mkdir $TMP_DIR
    mkfifo $PROCESS_FIFO
    mkfifo $PROGRESS_BAR_FIFO
}

function clean_tmp_dir(){
    info_msg1 ">>> clean up..."
    rm -r $TMP_DIR
}

function args_list(){
    find "$1" -iname "*.jpg" -print0
}

function draw_progress_bar(){
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

function progress_bar_process(){
    for i in $(seq 1 $1); do
        read -u4 j
        draw_progress_bar $i $1
    done
    echo ""
}

function map_process(){
    #size1=$(ls -l "$1"|cut -d" " -f5)
    #convert -quality 85 "$1" "$1"
    #size2=$(ls -l "$1"|cut -d" " -f5)
    #rate=$(bc <<< "scale=4; $size2/$size1*100")
    #info_msg0 "[OK] $1 rate=$rate%"

    sleep 0.1
}

function reduce_process(){
    info_msg1 ">>> reduce ok"
}

init_tmp_dir
trap "clean_tmp_dir; exit" SIGINT SIGTERM

exec 3<>$PROCESS_FIFO
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
#done < <(args_list "$@")
#### 1


### 2
info_msg1 ">>> start..."
exec 4<>$PROGRESS_BAR_FIFO


while IFS="" read -r -d "" i; do
    ARGS_LIST+=("$i")
done < <(args_list "$@")
info_msg2 ">>> ${#ARGS_LIST[@]} tasks"

progress_bar_process ${#ARGS_LIST[@]} &
draw_progress_bar 0 ${#ARGS_LIST[@]}
PIDS+=("$!")

for i in "${ARGS_LIST[@]}"; do
    read -u3 j
    {
        map_process "$i"
        echo $j>&3
        echo $j>&4
    } &
    PIDS+=("$!")
done
### 2


for i in "${PIDS[@]}"; do
    wait "$i"
done
reduce_process


exec 3>&-
exec 4>&-
clean_tmp_dir
info_msg1 ">>> end"
