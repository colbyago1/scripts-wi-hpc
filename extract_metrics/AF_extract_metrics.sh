#!/bin/bash

> AF_output.csv
for d in 1D8_topo*[0-9]; do
    for i in {1..5}; do
        key="model_${i}_pred_0"
        value=$(grep "\"$key\":" ${d}/ranking_debug.json | awk '{print $2}' | sed 's/,$//')
        echo "${PWD}/${d}/relaxed_model_${i}_pred_0.pdb,${PWD}/${d}/relaxed_model_${i}_pred_0.pdb,$value" >> AF_output.csv
    done
done
