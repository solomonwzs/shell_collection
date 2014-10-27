#!/bin/bash

_DF_BASE_DIR=$(dirname $0)
_DF_TMP_DIR=/tmp/df_$$

_DF_MSG_FIFO=$_DF_TMP_DIR/msg.fifo
_DF_USER_SCRIPT=$1

_DF_TASKS=()
_DF_TASK_NUM=0

_DF_MSG_NEW=0

source "$_DF_BASE_DIR/utils.sh"
source "$_DF_USER_SCRIPT"

_DF_GROUP_NUM=${#DF_NUM_GROUP[@]}

_df_init_tmp_space(){
    mkdir "$_DF_TMP_DIR"
    mkfifo "$_DF_MSG_FIFO"
}

_df_clear_tmp_space(){
    rm -r "$_DF_TMP_DIR"
}

_df_init_tmp_space
trap "_df_clear_tmp_space; exit" SIGINT SIGTERM

exec 3<>$_DF_MSG_FIFO

_DF_NUM_GROUP_COPY=("$DF_NUM_GROUP[@]")
for _df_i in $(seq 1 ${DF_NUM_GROUP[0]}); do
    echo "$_DF_MSG_NEW $_df_i" >&3
done

#for _df_i in "${DF_FUN_GROUP[@]}"; do
#    echo $(type -t $_df_i)
#done
#
#for _df_i in "${DF_NUM_GROUP[@]}"; do
#    echo "[$_df_i]"
#done

while IFS="" read -r _df_i; do
    _DF_TASKS+=("$_df_i")
done < <(init_task_list)
_DF_TASK_NUM=${#_DF_TASKS[@]}

for _df_i in $(seq 1 ${DF_NUM_GROUP[0]}); do
    echo "${DF_MSG_GROUP[0]} $_df_i" >&3
done


for _df_i in "${_DF_TASKS[@]}"; do
    while true; do
        read -u3 _df_msg _df_j
        for _df_k in $(seq 0 $(($_DF_GROUP_NUM-1))); do
            if [ "$_df_msg" == "${DF_MSG_GROUP[$_df_k]}" ]; then
                ${DF_FUN_GROUP[$_df_k]} "$_df_i" "$_df_j"

                echo "$_df_msg $_df_j" >&3
                break
            fi
        done

        if [ "$_df_k" == 0 ]; then
            break
        fi
    done
done

for _df_i in $(seq 0 $(($_DF_GROUP_NUM-1))); do
    echo ${DF_NUM_GROUP[$_df_i]}
done

exec 3>&-
exec 3<&-
_df_clear_tmp_space
