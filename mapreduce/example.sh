#!/bin/bash

MR_PROCESS_NUM=5

user_tmp_dir=/tmp/mr_example

init_user_space(){
    mkdir "$user_tmp_dir"
}

clear_user_space(){
    rm -r "$user_tmp_dir"
}

init_task_list(){
    find "/home/solomon/Pictures" -iname "*.jpg"
}

map_process(){
    local size=$(ls -l "$1"|cut -d" " -f5)
    local tmp_file="$user_tmp_dir/txt_ $2"
    echo "$1 size:$size, $2 ok" >> "$tmp_file"
    sleep 0.1
}

reduce_process(){
    while IFS="" read -r -d $'\0' file; do
        cat "$file" >> "$user_tmp_dir/res"
    done < <(find "$user_tmp_dir" -iname "*txt*" -print0)
    mv "$user_tmp_dir/res" ./res
}
