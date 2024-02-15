#!/bin/bash

for i in {1..5}; do
  key="model_${i}_pred_0"
  value=$(grep "\"$key\":" ranking_debug.json | awk '{print $2}' | sed 's/,$//')
  echo "$PWD/relaxed_model_${i}_pred_0.pdb,$value"
done
