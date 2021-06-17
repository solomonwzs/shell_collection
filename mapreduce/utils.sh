#!/bin/bash

_MR_COLOR_END="\033[0m"
_MR_COLOR_RED="\033[01;31m"
_MR_COLOR_GREEN="\033[01;32m"
_MR_COLOR_YELLOW="\033[01;33m"
_MR_COLOR_BLUE="\033[01;34m"
_MR_COLOR_PURPLE="\033[01;35m"
_MR_COLOR_CYAN="\033[01;36m"

_MR_PROGRESS_BAR_LEN=50

mr_error_msg(){
    echo -e "$_MR_COLOR_RED$1$_MR_COLOR_END"
}

mr_info_msg0(){
    echo -e "$1$_MR_COLOR_END"
}

mr_info_msg1(){
    echo -e "$_MR_COLOR_GREEN$1$_MR_COLOR_END"
}

mr_info_msg2(){
    echo -e "$_MR_COLOR_YELLOW$1$_MR_COLOR_END"
}

mr_info_msg3(){
    echo -e "$_MR_COLOR_BLUE$1$_MR_COLOR_END"
}

mr_draw_progress_bar(){
    local finish=$(($_MR_PROGRESS_BAR_LEN*$1/$2))
    local i
    local str=""

    str=$str">>> ["
    for i in $(seq 1 $finish); do
        str=$str"#"
    done
    if [ $finish -lt $_MR_PROGRESS_BAR_LEN ]; then
        for i in $(seq $(($finish+1)) $_MR_PROGRESS_BAR_LEN); do
            str=$str"-"
        done
    fi
    str=$str"] $(($1*100/$2))%"
    str=$str"\r"
    echo -ne "\033[2K$str"
}
