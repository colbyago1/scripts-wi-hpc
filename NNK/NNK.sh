#!/bin/bash

# ### Requirements ###
# # Ensure R1 + R2 in file name
# # Define library_fasta and tag
# # Ensure fastq in fastq directory
# # Ensure library_fasta in directory
# # Define unsort tag
# # Define Ab groupings

# library_fasta=""
# tag="JH-"

# cp fastq/* .

# #  Make directories
# for r1_file in "$tag"*R1*fastq; do common_name="${r1_file%_R1_001.trimmed.fastq}"; r2_file="${common_name}_R2_001.trimmed.fastq"; mkdir "$common_name"; mv "$r1_file" "$r2_file" "$common_name"; done

# # fastq to fasta conversion
# for i in `ls -d ./"$tag"-*`; do cd $i; for j in `ls *.fastq`; do j2=${j%.*};j3=`printf "%s.fasta" $j2`; echo $j $j3; sed -n '1~4s/^@/>/p;2~4p' $j > $j3; done; cd ..; done

# # Combine R1 and R2
# for i in `ls -d ./"$tag"*`; do for file in $i/*_R1_001.trimmed.fasta; do echo "Combining $file and ${file/_R1_/_R2_}"; cat "$file" "${file/_R1_/_R2_}" >> $i/combined.fasta; done; done

# # Split each fasta into a subset of files
# for i in `ls -d ./"$tag"*`; do cd $i; mkdir split_fastas; cd split_fastas; split -l 100000 ../"combined.fasta"; cd ../../; done

# # Array to store job IDs
# job_ids=()

# # Run queryNNK to generate data files for each subset in each directory

# # for i in `ls -d JH-*`; do
# #     echo $i;
# #     cd $i;
# #     mkdir singleBar10;
# #     cd singleBar10;
# #     rm slurm*;
# #     for j in `ls ../split_fastas/x*`; do
# #         echo $j;
# #         k=$(basename -- "$j");
# #         job_id=$(/wistar/kulp/software/slurmq --sbatch "/wistar/kulp/users/dwkulp/software/kulplab_scripts/deep_seq_anal/queryNNK.pl ../../Q23PT2cNNK2.fasta $j 1 > log.single10.$k" | awk '/Submitted batch job/ {print $4}');
# #         job_ids+=("$job_id")
# #     done;
# #     cd ..;
# #     mkdir dualBars10;
# #     cd dualBars10;
# #     rm slurm*;
# #     for j in `ls ../split_fastas/x??`; do
# #         echo $j;
# #         k=$(basename -- "$j");
# #         job_id=$(/wistar/kulp/software/slurmq --sbatch "/wistar/kulp/users/dwkulp/software/kulplab_scripts/deep_seq_anal/queryNNK.pl ../../Q23PT2cNNK2.fasta $j > log.dual10.$k" | awk '/Submitted batch job/ {print $4}');
# #         job_ids+=("$job_id")
# #     done;
# #     cd ..;
# #     mkdir singleBar12;
# #     cd singleBar12;
# #     rm slurm*;
# #     for j in `ls ../split_fastas/x??`; do
# #         echo $j;
# #         k=$(basename -- "$j");
# #         job_id=$(/wistar/kulp/software/slurmq --sbatch "/wistar/kulp/users/dwkulp/software/kulplab_scripts/deep_seq_anal/queryNNK.pl ../../Q23PT2cNNK2.fasta $j 1 12 > log.single12.$k" | awk '/Submitted batch job/ {print $4}');
# #         job_ids+=("$job_id")
# #     done;
# #     cd ../..;
# # done

# for i in `ls -d "$tag"*`; do
#     echo $i;
#     cd $i;
#     mkdir dualBars10;
#     cd dualBars10;
#     rm slurm*;
#     for j in `ls ../split_fastas/x??`; do
#         echo $j;
#         k=$(basename -- "$j");
#         job_id=$(/wistar/kulp/software/slurmq --sbatch "/wistar/kulp/users/dwkulp/software/kulplab_scripts/deep_seq_anal/queryNNK.pl ../../$library_fasta $j > log.dual10.$k" | awk '/Submitted batch job/ {print $4}');
#         job_ids+=("$job_id")
#     done;
#     cd ../..;
# done

# # wait
# for job_id in "${job_ids[@]}"
# do
#     while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
#     do
#         sleep 1
#     done
#     # rm "slurm-$job_id.out"
# done

# # Combine data files
# mkdir data; for i in `ls -d "$tag"*`; do for j in $i/*Bar*; do cat $j/*.data > data/${i}.${j##*/}.data; done; done

# mkdir analysis

path=$(echo "$PWD" | sed 's/.*workspace/workspace/')
full_path="/Volumes/kulp/linux/users/cagostino/$path/data/"

cd data

# Write loadNNK.R content
echo "# Load the analysis script that has lots of functions in it" > ../analysis/loadNNK.R
# echo 'source("/Volumes/kulp/linux/users/dwkulp/software/kulplab_scripts/deep_seq_anal/analyzeNNK2.R");' >> ../analysis/loadNNK.R
echo 'source("/Volumes/kulp/linux/users/cagostino/scripts/NNK/analyzeNNK2.R");' >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

echo "# Setup for the specific library requires sequence of library positions ONLY and position IDs in order." >> ../analysis/loadNNK.R
echo 'setupNNKAnalysis(theSeq="VSTQLLIRSEQILNNAKIIIVTVKSIRIGPGQAFYYTFAQSSGGDLEITTHSIINMWQRAGQAMYTRDGGKDNNVNETFRPGGSDMRDNWRS",thePositions=c(255:260,272:286,303:309,312:320,361:375,423:435,455:481));' >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

echo "########## LOAD DATA #########" >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

for i in *; do 
    # Get prefix of i
    i_pre="${i%%_*}"
    # Convert hyphen to underscore to comply with R syntax
    i_pre=$(echo "$i_pre" | sed 's/-/_/g')
    echo "cat(\"$i\\n\");" >> ../analysis/loadNNK.R
    echo "A_$i_pre = loadFile(\"$full_path$i\", posBase=\"\", numnt_min=-10, numnt_max=10);" >> ../analysis/loadNNK.R
    echo >> ../analysis/loadNNK.R
done

echo "######## HEAT MAP PLOT #######" >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

# hyphen-friendly
unsort="JH-0-M3"

for i in *; do 
    if [[ "$i" != *$unsort* ]]; then
        # Get prefix of i
        i_pre="${i%%_*}"
        unsort_noH=$(echo "$unsort" | sed 's/-/_/g')
        # Convert hyphen to underscore to comply with R syntax
        i_pre=$(echo "$i_pre" | sed 's/-/_/g')
        echo "$i_pre.unsort.prop = heatmapPlotAA.merge.propensity2(A_$i_pre,A_$unsort_noH,noplot=TRUE,posBase=\"\");" >> ../analysis/loadNNK.R
    fi
done

echo >> ../analysis/loadNNK.R
echo "###### TABLES + FIGURES ######" >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

for i in *; do 
    if [[ "$i" != *$unsort* ]]; then
        # Get prefix of i
        i_pre="${i%%_*}"
        # Convert hyphen to underscore to comply with R syntax
        i_pre=$(echo "$i_pre" | sed 's/-/_/g')
        echo "createTablesAndFigures($i_pre.unsort.prop, \"Fig_$i\");" >> ../analysis/loadNNK.R
    fi
done

echo >> ../analysis/loadNNK.R
echo "cat(\"Done Load\\n\");" >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R
echo "##### GET MOST ENRICHED #####" >> ../analysis/loadNNK.R
echo >> ../analysis/loadNNK.R

for i in *; do 
    if [[ "$i" != *$unsort* ]]; then
        # Get prefix of i
        i_pre="${i%%_*}"
        # Convert hyphen to underscore to comply with R syntax
        i_pre=$(echo "$i_pre" | sed 's/-/_/g')
        echo "cat(\"$i\\n\");" >> ../analysis/loadNNK.R
        echo "getMostEnriched($i_pre.unsort.prop[[1]],cutoff=0.3);" >> ../analysis/loadNNK.R
    fi
done

echo >> ../analysis/loadNNK.R
echo 'save.image(file = "loaded.RData")' >> ../analysis/loadNNK.R

full_path="/Volumes/kulp/linux/users/cagostino/$path/analysis/"

# hyphen-unfriendly
VRC01=("A_JH_0_M3" "A_JH_1A_M3" "A_JH_2A_M3" "A_JH_3A_M3" "A_JH_4A_M3" "A_JH_5A_M3")
VRC01_string=$(printf '"%s",' "${VRC01[@]}" | sed 's/,$//')
VH146=("A_JH_0_M3" "A_JH_6A_M3" "A_JH_7A_M3" "A_JH_8A_M3" "A_JH_9A_M3" "A_JH_10A_M3")
VH146_string=$(printf '"%s",' "${VH146[@]}" | sed 's/,$//')

echo "for (i in 1:length(pos1)){" > ../analysis/pies.R # good
echo "name=sprintf(\"NewPie_VRC01class_%03d_M3.pdf\", pos1[i]);" >> ../analysis/pies.R
echo "pdf(name,width=6,height=6);" >> ../analysis/pies.R # good
echo "a=plotPieDistributionAA.new(c($VRC01_string),labels=c($VRC01_string),pos=pos1[i],landscape=TRUE);" >> ../analysis/pies.R
echo "dev.off();" >> ../analysis/pies.R # good
echo "}" >> ../analysis/pies.R # good
echo >> ../analysis/pies.R # good
echo "for (i in 1:length(pos1)){" >> ../analysis/pies.R # good
echo "name=sprintf(\"NewPie_VH1-46class_%03d_M3.pdf\", pos1[i]);" >> ../analysis/pies.R
echo "pdf(name,width=6,height=6);" >> ../analysis/pies.R # good
echo "a=plotPieDistributionAA.new(c($VH146_string),labels=c($VH146_string),pos=pos1[i],landscape=TRUE);" >> ../analysis/pies.R
echo "dev.off();" >> ../analysis/pies.R # good
echo "}" >> ../analysis/pies.R # good

echo "setwd(\"$full_path\")"
echo "source(\"loadNNK.R\")"
echo "source(\"pies.R\")"

cd ..


echo "done"