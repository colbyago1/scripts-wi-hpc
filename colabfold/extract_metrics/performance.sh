#!/bin/bash

# Create the CSV file and write header
# echo "description,pLDDT,pTM,ipTM" > output.csv
while read -r line; do
    if grep -q "Query" <<< "$line"; then
        start=$(echo $line | awk '{print $1 " " $2}' | awk -F ',' '{print $1}')
        length=$(echo $line | awk '{print $7}' | sed 's/.$//')
    elif grep -q "rank_" <<< "$line"; then
        stop=$(echo $line | awk '{print $1 " " $2}' | awk -F ',' '{print $1}')
        start_seconds=$(date -d "$start UTC" +"%s")
        stop_seconds=$(date -d "$stop UTC" +"%s")
        difference=$((stop_seconds - start_seconds))
        hours=$((difference / 3600))
        minutes=$(( (difference % 3600) / 60 ))
        seconds=$((difference % 60))
        formatted_difference=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
        echo $formatted_difference,$length
    fi
done < log.txt