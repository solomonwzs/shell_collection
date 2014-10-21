#!/bin/sh

MR_PROCESS_NUM=5

init_user_space(){
    touch "/tmp/list"
}

clear_user_space(){
    :
}

init_task_list(){
    find "/home/solomon/Picture" -iname "*.jpg"
}

map_process(){
    local size=$(ls -l "$1"|cut -d" " -f5)
    echo "$1 size:$size, $2 ok" >> "/tmp/list"
    sleep 0.1
}

reduce_process(){
    :
}
