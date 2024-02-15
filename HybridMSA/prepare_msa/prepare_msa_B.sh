#!/bin/bash

# makes a3m for pdb for hybrid msa colabfold
i="$2"
printf -v i_formatted "%02d" $i
i2=$((2 * i))
fa="$1"
# get sequence from chain A
seq=$(sed -n "${i2}p" $fa)
length=${#seq}

# monomer
# write header and query to file
echo -e "#${length}\t1" > ${fa::-6}_seq${i_formatted}.a3m
echo ">101" >> ${fa::-6}_seq${i_formatted}.a3m
echo "$seq" >> ${fa::-6}_seq${i_formatted}.a3m

# # multimer
# # write header and query to file
# echo -e "#${length}\t3" > ${fa::-3}_seq${i_formatted}.a3m
# echo ">101" >> ${fa::-3}_seq${i_formatted}.a3m
# echo "$seq" >> ${fa::-3}_seq${i_formatted}.a3m
# echo ">101" >> ${fa::-3}_seq${i_formatted}.a3m
# echo "$seq" >> ${fa::-3}_seq${i_formatted}.a3m

cat ${fa::-6}_seq${i_formatted}.a3m ${fa::-6}.a3m > tmp
mv tmp ${fa::-6}_seq${i_formatted}.a3m

# cat ${fa::-3}.a3m >> ${fa::-3}_seq${i_formatted}.a3m