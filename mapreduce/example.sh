#!/bin/sh

MR_PROCESS_NUM=5

init_user_space(){
    touch "/tmp/list"
}

clear_user_space(){
    :
}

init_task_list(){
    find "/home/solomon/Pictures" -iname "*.jpg"
}

map_process(){
    echo "$1 ok" >> "/tmp/list"
    sleep 0.2
}

reduce_process(){
    :
}
