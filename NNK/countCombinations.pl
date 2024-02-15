#!/usr/bin/perl

my @aminoacids= qw(A R N D C Q E G H I L K M F P S T W Y V);

my %codons_all = (
'GCT' => 'A', 'GCC' => 'A', 'GCA' => 'A', 'GCG' => 'A', 'TTA' => 'L',
'TTG' => 'L', 'CTT' => 'L', 'CTC' => 'L', 'CTA' => 'L', 'CTG' => 'L',
'CGT' => 'R', 'CGC' => 'R', 'CGA' => 'R', 'CGG' => 'R', 'AGA' => 'R',
'AGG' => 'R', 'AAA' => 'K', 'AAG' => 'K', 'AAT' => 'N', 'AAC' => 'N',
'ATG' => 'M', 'GAT' => 'D', 'GAC' => 'D', 'TTT' => 'F', 'TTC' => 'F',
'TGT' => 'C', 'TGC' => 'C', 'CCT' => 'P', 'CCC' => 'P', 'CCA' => 'P',
'CCG' => 'P', 'CAA' => 'Q', 'CAG' => 'Q', 'TCT' => 'S', 'TCC' => 'S',
'TCA' => 'S', 'TCG' => 'S', 'AGT' => 'S', 'AGC' => 'S', 'GAA' => 'E',
'GAG' => 'E', 'ACT' => 'T', 'ACC' => 'T', 'ACA' => 'T', 'ACG' => 'T',
'GGT' => 'G', 'GGC' => 'G', 'GGA' => 'G', 'GGG' => 'G', 'TGG' => 'W',
'CAT' => 'H', 'CAC' => 'H', 'TAT' => 'Y', 'TAC' => 'Y', 'ATT' => 'I',
'ATC' => 'I', 'ATA' => 'I', 'GTT' => 'V', 'GTC' => 'V', 'GTA' => 'V',
'GTG' => 'V',
'TAA' => 'STOP',
'TGA' => 'STOP',
'TAG' => 'STOP',);

#my $pre="ATGATACGGTCT";
#my $post="ATCATCGTCCAA";

# Prior to sequence of interest
#my $pre ="ATACGGTCT";
#my $pre ="GAAAATATC";  # TATA would be WT, so TATC is the first barcode

# L1
my $pre ="TATC";  # TATA would be WT, so TATC is the first barcode
# Post to sequence of interest
#my $post="ATAATCGTC"; # ATCATCGTC would be WT, so ATAATCGTC is the second barcode
# L1
my $post="ATAA"; # ATCATCGTC would be WT, so ATAATCGTC is the second barcode
# L1
# Length between pre and post
my $len =18;
my $wt = "TNNGKN";
print "L1\n";	

# # L2
# my $pre ="GAGT";  # TATA would be WT, so TATC is the first barcode
# # L2
# my $post="TTGG"; # ATCATCGTC would be WT, so ATAATCGTC is the second barcode
# # L2
# # Length between pre and post
# my $len =12;
# my $wt = "AGGD";
# print "L2\n";	

# # L3
# my $pre ="AGAC";  # TATA would be WT, so TATC is the first barcode
# # L3
# my $post="AACG"; # ATCATCGTC would be WT, so ATAATCGTC is the second barcode
# # L3
# # Length between pre and post
# my $len =15;
# my $wt = "GGSNT";
# print "L3\n";	

my $filename = $ARGV[1];
print "Processing file: $filename\n";

my %a = ('pre'  => $pre,
	 'post' => $post,
	 'len'  => $len,
	 'seq'  => "",
	 'regex'=> $ARGV[2],
	 'name' => ""
        );

my $hitCutoff = 3;
$hitCutoff = 0 if ($a{'regex'} ne "");

open(TMP, "$ARGV[0]");
my %counts;
my %freqs;
my $seq ="";
my $header ="";
while ($line =<TMP>){
    $line =~ s/\n//;

    if ($line =~ /\>(\S+)/){
	if ($header){
	    $a{'seq'} = $seq;
	    $a{'name'} = $header;
	    my $aas = processSeq(%a);
	    $counts{$aas} += 1; # counts of each amino acid sequence

	}
	$seq = "";
	$header = $1;
    } else {
	$seq .= $line;
    }
    
}
close(TMP);

$a{'seq'} = $seq;
$a{'name'} = $header;
# processes seq based on pre and post (validates with length)
my $aas = processSeq(%a);
$counts{$aas} += 1; # counts of each amino acid sequence
#for ($i = 0; $i < $a{'len'}/3;$i++){
#    $freqs{$i+1}{substr($aas,$i,1)}+=1;
#}

my $total = 0; # total counts
foreach $key (sort { $counts{$b} <=> $counts {$a} } keys %counts){
    if ($key){
	$total += $counts{$key};
    }
}
#$hitCutoff = $total / 10;
#print "HitCutoff: $hitCutoff\n";
my $matches = 0;
# my $cys = 0;
my $diversity = 0;
my $output_file = "counts.txt";
open(my $fh, '>', $output_file) or die "Could not open file '$output_file' $!";
truncate $fh, 0;

foreach $key (sort { $counts{$a} <=> $counts {$b} } keys %counts){

    if ($key){
		$diversity += 1;
		# if counts of sequence is greater than hitCutoff, add counts of that key to matches
		if ($counts{$key} > $hitCutoff){
			# if ($key !~ /C/){
			$matches += $counts{$key};

			print "$key ".$counts{$key}." \n";
			printf $fh "$key ".$counts{$key}." \n";			
			# Compute AA frequencies
			# freqs[position in sequence][amino acid] += counts of sequence
			for ($i = 0; $i < $a{'len'}/3;$i++){
			$freqs{$i+1}{substr($key,$i,1)}+=$counts{$key};
				}
			# } else {
			# 	$cys += $counts{$key};
			# }
		}
    } else {
	print "No Match ".$counts{$key}." \n";
    }
}

close $fh;

print "Matches: $matches\n";
print "Diversity: $diversity\n";
# print "Cysteines: $cys\n";
printf "\n\t";
foreach (@aminoacids){
    my $aa = $_;
    printf "%3s ", $aa;
}
print "\n";
for ($i = 0; $i < $a{'len'}/3;$i++){
    my $index = $i+1;
    print $index."\t";
    foreach (@aminoacids){
	    my $aa = $_;
		# counts of aa at position / matches * 100 = percent of sequences that contain this aa (each row should equal 100)
	    if (exists $freqs{$i+1}{$aa}){
		my $freq = $freqs{$i+1}{$aa}/$matches*100;
		printf "%3d ", $freq;
	    } else {
		print "  - ";
	    }
    }
    print substr($wt,$i,1);
    print "\n";
}

my $output_file = "matrix.txt";
open(my $fh, '>', $output_file) or die "Could not open file '$output_file' $!";
truncate $fh, 0;

# print counts
for ($i = 0; $i < $a{'len'}/3;$i++){
    my $index = $i+1;
	my $wt = substr($wt,$i,1);
    foreach (@aminoacids){
	    my $aa = $_;
		# counts of aa at position / matches * 100 = percent of sequences that contain this aa (each row should equal 100)
	    if (exists $freqs{$i+1}{$aa}){
		my $freq = $freqs{$i+1}{$aa}/$matches*100;
		printf $fh "%d,%s,%s,%.2f\n", $index, $wt, $aa, $freq;
		} else {
			printf $fh "%d,%s,%s,%.2f\n", $index, $wt, $aa, 0;
	    }
    }
}

close $fh;

print "REGEX USED: ".$a{'regex'}."\n";

sub processSeq {
    my (%args) = @_;

    if ($args{'seq'} =~ /$args{'pre'}(\S+)$args{'post'}/){

	my $result = $1;
	if (length($result) == $args{'len'}){
	    # Convert to AA
	    my $aas = convertToAA($result);
	    return $aas if ($args{'regex'} eq "");
	    return $aas if ($aas =~ /$args{'regex'}/);

	    return "";
	}
    }
    return "";
}


sub convertToAA{
    my $NTseq = $_[0];
    my $AAseq = "";
    for ($i=0; $i < length($NTseq);$i+=3){
	my $AA = $codons_all{substr($NTseq,$i,3)};

	if ($AA eq "STOP"){
	    return "";
	}
	$AAseq .= $AA;
    }
    return $AAseq;
}
