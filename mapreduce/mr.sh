#!/bin/bash

_MR_BASE_DIR=$(dirname "$0")
_MR_TMP_DIR=/tmp/mr_$$
_MR_TASK_FILE=$_MR_TMP_DIR/task_file

_MR_MSG_FIFO=$_MR_TMP_DIR/msg.fifo
_MR_USER_SCRIPT=$1

_MR_PROCESS_NUM=2
_MR_TASK_NUM=0
_MR_TASK_FINISH=0
_MR_TASKS=()

_MR_MSG_NEW=0
_MR_MSG_OK=1

source "$_MR_BASE_DIR/utils.sh"
source "$_MR_USER_SCRIPT"

_mr_init_tmp_space(){
    mr_info_msg1 ">>> init temporary files..."
    mkdir "$_MR_TMP_DIR"
    mkfifo "$_MR_MSG_FIFO"

    if [ "$(type -t init_user_space)" == "function" ]; then
        init_user_space
    fi
}

_mr_clear_tmp_space(){
    mr_info_msg1 ">>> clear temporary files..."
    rm -r "$_MR_TMP_DIR"

    if [ "$(type -t clear_user_space)" == "function" ]; then
        clear_user_space
    fi
}

if [ -n "$MR_PROCESS_NUM" ]; then
    _MR_PROCESS_NUM=$MR_PROCESS_NUM
fi

_mr_init_tmp_space
trap "_mr_clear_tmp_space; exit" SIGINT SIGTERM

mr_info_msg1 ">>> start..."
exec 3<>$_MR_MSG_FIFO

# while IFS="" read -r _mr_i; do
#     _MR_TASKS+=("$_mr_i")
# done < <(init_task_list)
# _MR_TASK_NUM=${#_MR_TASKS[@]}
init_task_list > $_MR_TASK_FILE
_MR_TASK_NUM=$(wc -l $_MR_TASK_FILE|awk '{print $1}')
mr_info_msg1 ">>> $_MR_TASK_NUM tasks"

for _mr_i in $(seq 1 "$_MR_PROCESS_NUM"); do
    echo "$_MR_MSG_NEW $_mr_i" >&3
done

mr_info_msg1 ">>> map start"
mr_draw_progress_bar 0 "$_MR_TASK_NUM"
# for _mr_i in "${_MR_TASKS[@]}"; do
while IFS="" read -r _mr_i; do
    while true; do
        read -u3 _mr_msg _mr_j
        if [ "$_mr_msg" == "$_MR_MSG_NEW" ]; then
            {
                map_process "$_mr_i" "$_mr_j"
                echo "$_MR_MSG_OK $_mr_j" >&3
                echo "$_MR_MSG_NEW $_mr_j" >&3
            } &
            break
        elif [ "$_mr_msg" == "$_MR_MSG_OK" ]; then
            _MR_TASK_FINISH=$(($_MR_TASK_FINISH+1))
            mr_draw_progress_bar "$_MR_TASK_FINISH" "$_MR_TASK_NUM"
        fi
    done
done < "$_MR_TASK_FILE"
# done

while [ "$_MR_TASK_FINISH" -lt "$_MR_TASK_NUM" ]; do
    read -u3 _mr_msg _mr_j
    if [ "$_mr_msg" == "$_MR_MSG_OK" ]; then
        _MR_TASK_FINISH=$(($_MR_TASK_FINISH+1))
        mr_draw_progress_bar "$_MR_TASK_FINISH" "$_MR_TASK_NUM"
    fi
done
echo ""
mr_info_msg1 ">>> map complete"

mr_info_msg1 ">>> reduce start"
reduce_process
mr_info_msg1 ">>> reduce complete"

exec 3>&-
exec 3<&-
_mr_clear_tmp_space

mr_info_msg1 ">>> complete"
