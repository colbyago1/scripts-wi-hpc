#!/bin/bash

inFile="$1"
outFile="order.html"  # Change the extension to .html
kozak="gccacc"
leader="atggactggacctggattctgttcctggtggcagcagcaaccagggtgcactct"
optional_linker="GG"
purification_tag="HHHHHH"
double_stop_codon="**"
name_ext="_6H_pVax"


# Open the HTML file and add the HTML structure
echo "<html><head><title>Your Title Here</title></head><body>" > "$outFile"

# Add your content
echo "<p>Clone into pVax</p>" >> "$outFile"
echo "<p>PROTEIN SEQUENCES ARE UPPERCASE; dna sequences are lowercase</p>" >> "$outFile"
echo "<p>Codon optimize PROTEIN SEQUENCES for human (and mouse)</p>" >> "$outFile"
echo "<p>Constructs contain <span style=\"color:red;\">kozak</span>, <span style=\"color:blue;\">IgE leader sequence</span>, <span style=\"color:green;\">linker, purification tag, and double stop codon (**)</span></p>" >> "$outFile"

index=1
tail -n +2 "$inFile" | while IFS=',' read -r name sequence || [ -n "$name" ]; do
    echo "<p>$index. $name$name_ext</p>" >> "$outFile"
    trimmed_sequence=$(echo "$sequence" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')  # Remove leading and trailing whitespace
    echo "<p><span style=\"color:red;\">$kozak</span><span style=\"color:blue;\">$leader</span>$trimmed_sequence<span style=\"color:green;\">$optional_linker$purification_tag$double_stop_codon</span></p>" >> "$outFile"
    (( index++ ))
done

# Close the HTML file
echo "</body></html>" >> "$outFile"

