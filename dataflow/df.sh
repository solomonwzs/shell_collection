#!/bin/bash

_DF_BASE_DIR=$(dirname $0)
_DF_TMP_DIR=/tmp/df_$$

_DF_MSG_FIFO=$_DF_TMP_DIR/msg.fifo
_DF_USER_SCRIPT=$1

_DF_MSG_NEW=0

source "$_DF_BASE_DIR/utils.sh"
source "$_DF_USER_SCRIPT"

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

for _df_i in "${DF_FUN_GROUP[@]}"; do
    echo $(type -t $_df_i)
done

for _df_i in "${DF_NUM_GROUP[@]}"; do
    echo "[$_df_i]"
done

exec 3>&-
exec 3<&-
_df_clear_tmp_space
