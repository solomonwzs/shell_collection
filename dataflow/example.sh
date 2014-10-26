#!/bin/bash

DF_NUM_GROUP=(5 3 4)
DF_MSG_GROUP=("GOTO_A" "GOTO_B" "GOTO_C")
DF_FUN_GROUP=("fun_a" "fun_b" "fun_c")

init_task_list(){
    local i
    for i in $(seq 1 19); do
        echo "Task$i"
    done
}

fun_a(){
    echo "fun_a"
}

fun_b(){
    echo "fun_b"
}

fun_c(){
    echo "fun_c"
}
