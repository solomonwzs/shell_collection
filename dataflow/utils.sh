#!/bin/bash

_DF_COLOR_END="\033[0m"
_DF_COLOR_RED="\033[01;31m"
_DF_COLOR_GREEN="\033[01;32m"
_DF_COLOR_YELLOW="\033[01;33m"
_DF_COLOR_BLUE="\033[01;34m"
_DF_COLOR_PURPLE="\033[01;35m"
_DF_COLOR_CYAN="\033[01;36m"

_DF_PROGRESS_BAR_LEN=50

df_error_msg(){
    echo -e "$_DF_COLOR_RED$1$_DF_COLOR_END"
}

df_info_msg0(){
    echo -e "$1$_DF_COLOR_END"
}

df_info_msg1(){
    echo -e "$_DF_COLOR_GREEN$1$_DF_COLOR_END"
}

df_info_msg2(){
    echo -e "$_DF_COLOR_YELLOW$1$_DF_COLOR_END"
}

df_info_msg3(){
    echo -e "$_DF_COLOR_BLUE$1$_DF_COLOR_END"
}
