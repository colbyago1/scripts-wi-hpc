#!/bin/bash

# 171

a3m=$1
pos=$2
aminos=(G A L M F W K Q E S P V I Y H R N D T)
mkdir ${a3m::-4}
mkdir ${a3m::-4}/N
for a in "${aminos[@]}"; do
    sed -e "3s/./$a/$pos" -e "5s/./$a/$pos" "$a3m" > "${a3m::-4}/N/${a3m::-4}_${pos}${a}.a3m"
done
((pos++))
((pos++))
mkdir ${a3m::-4}/C
for a in "${aminos[@]}"; do
    sed -e "3s/./$a/$pos" -e "5s/./$a/$pos" "$a3m" > "${a3m::-4}/C/${a3m::-4}_${pos}${a}.a3m"
done