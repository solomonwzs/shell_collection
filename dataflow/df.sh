#!/bin/bash

_DF_BASE_DIR=$(dirname $0)
_DF_TMP_DIR=/tmp/df_$$

_DF_MSG_FIFO=$_DF_BASE_DIR/msg.fifo
_DF_USER_SCRIPT=$1

source "$_DF_BASE_DIR/utils.sh"

_df_init_tmp_space(){
    mkdir "$_DF_TMP_DIR"
    mkfifo "$_DF_MSG_FIFO"
}

_df_clear_tmp_space(){
    rm -r "$_DF_TMP_DIR"
}
