#!/bin/bash
set -euo pipefail

colors=(31 32 33 34 35 36 37 38)
styles=(1 2 3 4 5 6 7 8 9)

for color in "${colors[@]}"
do
    for style in "${styles[@]}"
    do
        echo -ne "\e[${style};${color}m [${style};${color}] \e[0m"
    done
    echo -e ""
done
