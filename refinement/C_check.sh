#!/bin/bash

# a3m=$1
# pos=$2
# aminos=(G A L M F W K Q E S P V I Y H R N D T)
# mkdir ${a3m::-4}
# for a in "${aminos[@]}"; do
#     sed -e "3s/./$a/$pos" -e "5s/./$a/$pos" "$a3m" > "${a3m::-4}/${a3m::-4}_${pos}${a}.a3m"
# done

a3m=$1
pos=$2
pos2=$3
aminos=(G A L M F W K Q E S P V I Y H R N D T)
mkdir ${a3m::-4}
for a in "${aminos[@]}"; do
    for b in "${aminos[@]}"; do
        sed -e "3s/./$a/$pos" -e "5s/./$a/$pos" -e "3s/./$b/$pos2" -e "5s/./$b/$pos2" "$a3m" > "${a3m::-4}/${a3m::-4}_${pos}${a}_${pos2}${b}.a3m"
    done
done