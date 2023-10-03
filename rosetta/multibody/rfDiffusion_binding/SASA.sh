#!/bin/sh

p="$1"
partners="$2"

Ab="${partners%%_*}"
binder="${partners#*_}"

if [ ${#Ab} -gt 1 ]; then
    Ab=$(echo $Ab | sed 's/./&+/g' | sed 's/+$//')
fi

if [ ${#binder} -gt 1 ]; then
    binder=$(echo $binder | sed 's/./&+/g' | sed 's/+$//')
fi

# calculate sasa
totalSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p | awk '{lastword=$NF} END {print lastword}')
binderSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p --sele "chain $binder" | awk '{lastword=$NF} END {print lastword}')
AbSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p --sele "chain $Ab" | awk '{lastword=$NF} END {print lastword}')
echo "$p,$binderSASA,$AbSASA,$totalSASA,$(echo "$binderSASA + $AbSASA - $totalSASA" | bc)" >> "${p::-4}_SASA.csv"
