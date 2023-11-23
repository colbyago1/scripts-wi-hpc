#!/bin/bash

#SBATCH --job-name=pMPNN
#SBATCH --partition=defq
#SBATCH --exclude=node050,node051,node052,node053,node054,node056
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --mem=12Gb

echo "$PWD"

shopt -s nullglob # This ensures that the loop doesn't run if no files match the pattern

# ref="/home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/untraditional_mini_sym/untraditional_ref.pdb"
ref="/home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/traditional_mini_sym/traditional_ref.pdb"
ref_basename=$(basename "$ref")
substrings=("NLWVTVYYGVPVWK" "KIEPLGVAPTRCKRR" "LGFLGAAGSTMGAASMTLTVQARNLLS" "GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD")
chains_to_design="A B C"

folder_with_pdbs="./"

output_dir="./pmpnn_seqs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_tied_positions=$output_dir"/tied_pdbs.jsonl"
path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"

echo "step 1"

for pdb in *pdb; do
    echo $pdb

    seq=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
    echo $seq

    extra_substring=0
    missing_substring=0
    last_end_position=0
    full_substrings=()
    substring_to_add=""

    for substring in "${substrings[@]}"; do
        # Find positions of the substring
        positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))
        
        # Check the length of positions array
        if [ "${#positions[@]}" -gt 1 ]; then
            # echo "Warning: Multiple positions found for substring '$substring'"
            extra_substring=1
        elif [ "${#positions[@]}" -lt 1 ]; then
            # echo "Warning: No positions found for substring '$substring'"
            ((missing_substring++))
            substring_to_add="$substring"
        else
            # Get the single position
            position="${positions[0]}"

            # Count the number of '[' characters in the substring
            bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

            # Calculate the ending position by subtracting 4 times the bracket count
            end_position=$((position + ${#substring} - 4 * bracket_count))
            # echo "$end_position"
            # find last position of last substring
            if [ "$last_end_position" -lt "$end_position" ]; then
                last_end_position="$end_position"
            fi

            # Add substring to present substrings
            full_substrings+=("$substring")
        fi
    done
    
    # echo "$last_end_position"
    # echo "full_substrings: ${full_substrings[@]}"

    case=0
    if [ "$missing_substring" -eq 0 ]; then
        if [ $((last_end_position - ${#seq})) -eq 0 ]; then
            echo "case 1"
            case=1
        else
            echo "case 2"
            case=2
        fi
    elif [[ ! "${seq:last_end_position}" =~ ^[G]+$ && "$missing_substring" -eq 1 && $((last_end_position - ${#seq})) -ne 0 ]]; then
        echo "case 3"
        case=3
    elif [[ "$missing_substring" -eq 1 && $((last_end_position - ${#seq})) -ne 0 && ${substring_to_add:0:1} == "G" ]]; then
        echo "case 4"
        case=4
    else
        echo "case 5"
        case=5
    fi

    if [ "$case" -eq 1 ]; then
        echo "copy"

        cp $pdb ${pdb::-4}-fix.pdb

    elif [ "$case" -eq 2 ]; then

        echo "remove residues"

        # get truncated chains from pdb
        offset=$(awk '/^ATOM/ && $5 == "A" {print $6; exit}' "$pdb")
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+A\s\+[0-9]\+\s\+' $pdb | awk -v last_end_position=$((last_end_position + offset)) '$6 >= offset && $6 < last_end_position' > "${pdb::-4}-A.pdb"
        offset=$(awk '/^ATOM/ && $5 == "B" {print $6; exit}' "$pdb")
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+B\s\+[0-9]\+\s\+' "$pdb" | awk -v last_end_position=$((last_end_position + offset)) '$6 >= offset && $6 < last_end_position' > "${pdb::-4}-B.pdb"
        offset=$(awk '/^ATOM/ && $5 == "C" {print $6; exit}' "$pdb")
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+C\s\+[0-9]\+\s\+' "$pdb" | awk -v last_end_position=$((last_end_position + offset)) '$6 >= offset && $6 < last_end_position' > "${pdb::-4}-C.pdb"

        # combine (fix filenames)
        cat ${pdb::-4}-A.pdb ${pdb::-4}-B.pdb ${pdb::-4}-C.pdb > ${pdb::-4}-fix.pdb
        rm ${pdb::-4}-B.pdb ${pdb::-4}-C.pdb
   
    elif [ "$case" -eq 3 ]; then
        
        echo "add residues"

        # extract chain and align
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+A\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-A.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-A.pdb --sele1 name CA and chain A --sele2 name CA and chain A"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain A: $rmsd"
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+B\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-B.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-B.pdb --sele1 name CA and chain B --sele2 name CA and chain B"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain B: $rmsd"
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+C\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-C.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-C.pdb --sele1 name CA and chain C --sele2 name CA and chain C"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain C: $rmsd"

        # get missing residues
        for chain in "A" "B" "C"; do
            ref_seq=$(cat "$ref" | awk '/^ATOM/ && $3 == "CA" && $5 == "'"$chain"'" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g') 
            position=$(echo "$ref_seq" | grep -bo "$substring_to_add" | cut -d':' -f1)
            end_position=$((position + ${#substring_to_add} - 4 * bracket_count))
            # Get the length of incomplete_string
            incomplete_string=${seq:last_end_position}
            present_string=$(echo "$incomplete_string" | sed 's/^G*//')
            # Count the number of preceding 'G's in string2
            count_G=$(echo "$substring_to_add" | grep -o '^G*' | tr -d '\n' | wc -c)
            # Add 'G' to the beginning of string1_without_preceding_G for each preceding 'G' in string2
            for ((i=1; i<=$count_G; i++)); do
                present_string="G$present_string"
            done
            start=$((position + ${#present_string}))
            end=$((end_position))
            offset=$(awk '/^ATOM/ && $5 == "'"$chain"'" {print $6; exit}' "$ref")
            grep "^ATOM\s\+[0-9]\+\s\+.*\s\+$chain\s\+[0-9]\+\s\+" "$ref" | awk -v start="$((start + offset))" -v end="$((end + offset))" '$6 >= start && $6 < end' > "${ref_basename::-4}-$chain.pdb"
        done

        # combine
        cat ${pdb::-4}-A-aligned.pdb "${ref_basename::-4}-A.pdb" ${pdb::-4}-B-aligned.pdb "${ref_basename::-4}-B.pdb" ${pdb::-4}-C-aligned.pdb "${ref_basename::-4}-C.pdb" > ${pdb::-4}-aln.pdb
        
        awk '
            /^ATOM/ {
                resi = substr($0, 23, 4)
                if (resi != previous_resi) {
                    previous_resi = resi
                    resSeq = sprintf("%4d", resSeq + 1)
                }
                $0 = substr($0, 1, 6) \
                    sprintf("%5d", ++serial) \
                    substr($0, 12, 11) \
                    resSeq \
                    substr($0, 27)
            }
            !/TER/ && !/END/ { 
                print 
            }
        ' ${pdb::-4}-aln.pdb > ${pdb::-4}-fix.pdb

        cat ${pdb::-4}-A-aligned.pdb ${ref_basename::-4}-A.pdb > ${pdb::-4}-A-aln.pdb

        awk '
            /^ATOM/ {
                resi = substr($0, 23, 4)
                if (resi != previous_resi) {
                    previous_resi = resi
                    resSeq = sprintf("%4d", resSeq + 1)
                }
                $0 = substr($0, 1, 6) \
                    sprintf("%5d", ++serial) \
                    substr($0, 12, 11) \
                    resSeq \
                    substr($0, 27)
            }
            !/TER/ && !/END/ { 
                print 
            }
        ' ${pdb::-4}-A-aln.pdb > ${pdb::-4}-A.pdb

        rm ${pdb::-4}-A-aligned.pdb ${pdb::-4}-B.pdb ${pdb::-4}-B-aligned.pdb ${pdb::-4}-C.pdb ${pdb::-4}-C-aligned.pdb ${ref_basename::-4}-A.pdb ${ref_basename::-4}-B.pdb ${ref_basename::-4}-C.pdb ${pdb::-4}-aln.pdb ${pdb::-4}-A-aln.pdb


    elif [ "$case" -eq 4 ]; then

        echo "deal with edge case"

        exception=0

        # extract chain and align
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+A\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-A.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-A.pdb --sele1 name CA and chain A --sele2 name CA and chain A"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain A: $rmsd"
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+B\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-B.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-B.pdb --sele1 name CA and chain B --sele2 name CA and chain B"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain B: $rmsd"
        grep '^ATOM\s\+[0-9]\+\s\+.*\s\+C\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-C.pdb
        command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-C.pdb --sele1 name CA and chain C --sele2 name CA and chain C"; for substring in "${full_substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; output=$(eval "$command"); rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}'); echo "RMSD chain C: $rmsd"

        # get missing residues
        for chain in "A" "B" "C"; do
            ref_seq=$(cat "$ref" | awk '/^ATOM/ && $3 == "CA" && $5 == "'"$chain"'" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g') 
            position=$(echo "$ref_seq" | grep -bo "$substring_to_add" | cut -d':' -f1)
            # find position of first character of substring_to_add in ref
            ref_resi=$position
            offset=$(awk '/^ATOM/ && $5 == "'"$chain"'" {print $6; exit}' "$ref")
            ref_resi=$((ref_resi + offset))
            end_position=$((position + ${#substring_to_add} - 4 * bracket_count))

            # find position of characters trailing last substring in pdb
            pdb_resi=()
            incomplete_string=${seq:last_end_position} # string of G's

            # echo "incomplete string: $incomplete_string"
            # echo "string to add: $substring_to_add"

            string_length=${#seq}
            offset=$(awk '/^ATOM/ && $5 == "'"$chain"'" {print $6; exit}' "$pdb")
            for ((i = last_end_position; i < string_length; i++)); do
                pdb_resi+=($((i+offset)))
            done
            # check alignment of pdb_resi to ref_resi
            aligned_resi=
            for i in "${pdb_resi[@]}"; do
                output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 ${pdb::-4}-$chain-aligned.pdb --sele1 name CA and chain $chain and resi $ref_resi --sele2 name CA and chain $chain and resi $i --noAlign --noOutputPdb)
                rmsd=$(echo "$output" | grep -oE "RMSD [0-9.]+" | awk '{print $2}')
                echo "$i,$rmsd"
                if (( $(echo "$rmsd < 1.5" | bc -l) )); then
                    echo "rmsd: $rmsd"
                    aligned_resi=$i
                    echo "aligned resi: $aligned_resi"
                    break
                fi
            done

            if [ -z $aligned_resi ]; then
                echo "exit 1"
                exception=1
                rm ${pdb::-4}-A.pdb ${pdb::-4}-A-aligned.pdb ${pdb::-4}-B.pdb ${pdb::-4}-B-aligned.pdb ${pdb::-4}-C.pdb ${pdb::-4}-C-aligned.pdb
                break
            fi

            # stitch
            last_resi=$(awk '/^ATOM/ && $5 == "'"$chain"'" {lastOffset=$6} END {if (lastOffset) print lastOffset}' "$pdb")
            diff=$((last_resi - aligned_resi))
            
            start=$((position + diff + 1))
            end=$((end_position))
            offset=$(awk '/^ATOM/ && $5 == "'"$chain"'" {print $6; exit}' "$ref")
            grep "^ATOM\s\+[0-9]\+\s\+.*\s\+$chain\s\+[0-9]\+\s\+" "$ref" | awk -v start="$((start + offset))" -v end="$((end + offset))" '$6 >= start && $6 < end' > "${ref::-4}-$chain.pdb"
        done

        if [ "$exception" -eq 0 ]; then
            echo "add residues"
            # combine
            cat ${pdb::-4}-A-aligned.pdb ${ref_basename::-4}-A.pdb ${pdb::-4}-B-aligned.pdb ${ref_basename::-4}-B.pdb ${pdb::-4}-C-aligned.pdb ${ref_basename::-4}-C.pdb > ${pdb::-4}-aln.pdb

            awk '
                /^ATOM/ {
                    resi = substr($0, 23, 4)
                    if (resi != previous_resi) {
                        previous_resi = resi
                        resSeq = sprintf("%4d", resSeq + 1)
                    }
                    $0 = substr($0, 1, 6) \
                        sprintf("%5d", ++serial) \
                        substr($0, 12, 11) \
                        resSeq \
                        substr($0, 27)
                }
                !/TER/ && !/END/ { 
                    print 
                }
            ' ${pdb::-4}-aln.pdb > ${pdb::-4}-fix.pdb

            cat ${pdb::-4}-A-aligned.pdb ${ref_basename::-4}-A.pdb > ${pdb::-4}-A-aln.pdb

            awk '
                /^ATOM/ {
                    resi = substr($0, 23, 4)
                    if (resi != previous_resi) {
                        previous_resi = resi
                        resSeq = sprintf("%4d", resSeq + 1)
                    }
                    $0 = substr($0, 1, 6) \
                        sprintf("%5d", ++serial) \
                        substr($0, 12, 11) \
                        resSeq \
                        substr($0, 27)
                }
                !/TER/ && !/END/ { 
                    print 
                }
            ' ${pdb::-4}-A-aln.pdb > ${pdb::-4}-A.pdb

            rm ${pdb::-4}-A-aligned.pdb ${pdb::-4}-B.pdb ${pdb::-4}-B-aligned.pdb ${pdb::-4}-C.pdb ${pdb::-4}-C-aligned.pdb ${ref_basename::-4}-A.pdb ${ref_basename::-4}-B.pdb ${ref_basename::-4}-C.pdb ${pdb::-4}-aln.pdb ${pdb::-4}-A-aln.pdb
        fi

    elif [ "$case" -eq 5 ]; then
        echo "exit 1"
    fi
    echo
done

echo "step 2"

for pdb in *fix.pdb; do
    echo $pdb
    # clash check
    output=$(/home/dwkulp/software/mslib.git/mslib/bin/clashCheck --pdblist $pdb)
    clashes=$(echo "$output" | awk '{print $NF}' | tail -n 1)
    echo "Clashes: $clashes"
    if [ $clashes -eq 0 ]; then

        seq=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
        echo $seq

        fixed_positions=()
        index=0
        # Loop through the substrings
        for substring in "${substrings[@]}"; do
            # Find positions of the substring
            positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

            # Check the length of positions array
            if [ "${#positions[@]}" -gt 1 ]; then
                echo "Warning: Multiple positions found for substring '$substring'"

            elif [ "${#positions[@]}" -lt 1 ]; then
                echo "Warning: No positions found for substring '$substring'"
            else
                # Get the single position
                position="${positions[0]}"

                # Count the number of '[' characters in the substring
                bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

                # Calculate the ending position by subtracting 4 times the bracket count
                end_position=$((position + ${#substring} - 4 * bracket_count))

                # Initialize an empty array to store positions
                position_list=()
                # Create an array of positions from start to end
                for ((i = position + 1; i <= end_position; i++)); do
                    position_list+=("$i")
                    # Echo the letter at that position
                    # letter=$(echo "$seq" | cut -c "$i")
                    # echo "Position $i: $letter"
                done
                fixed_positions+=("${position_list[*]}")
            fi
            # Increment the counter
            ((index++))
        done
        # echo "Fixed: ${fixed_positions[@]}"
        design_positions=()
        for ((i=1; i<=${#seq}; i++)); do
            if [[ ! " ${fixed_positions[@]} " =~ " $i " ]]; then
                design_positions+=("$i")
            fi
        done
        # echo "Design: ${design_positions[@]}"
        design_only=("${design_positions[@]}", "${design_positions[@]}", "${design_positions[@]}")
        echo "List: ${design_only[*]}"

        
        ### run pMPNN ###
        echo "Running pMPNN"

        folder_with_pdbs="${pdb::-4}"
        mkdir -p "$folder_with_pdbs"
        mv "$pdb" "$folder_with_pdbs"

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_tied_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_tied_positions --homooligomer 1

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design" --position_list "${design_only[*]}" --specify_non_fixed

        python /home/cagostino/work/software/ProteinMPNN/protein_mpnn_run.py \
                --jsonl_path $path_for_parsed_chains \
                --tied_positions_jsonl $path_for_tied_positions \
                --fixed_positions_jsonl $path_for_fixed_positions \
                --out_folder $output_dir \
                --num_seq_per_target 10 \
                --sampling_temp "0.1" \
                --batch_size 1
    else    
        echo "Skipping pMPNN"
    fi
    echo
done

# generate monomer fasta files
for fasta in pmpnn_seqs/seqs/*.fa; do
    tail -n +3 "$fasta" | awk -v input_file="${fasta::-3}" '{if (NR % 2 == 0) {sub(/\/.*/, "")} else {$0=sprintf(">%s_seq%02d", input_file, ++i)} print}' > "${fasta::-3}-monomer.fa"
done

### run ESMFold ###
