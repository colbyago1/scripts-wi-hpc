#library(seqinr);
library(ggplot2);
library(gplots);

# NOTE: must run "setupNNKAnalysis" first. This sets the sequence and position numbering, etc..

'%ni%' =Negate('%in%');

# Sequence utility variables
code3 <- c("ALA","ARG","ASN","ASP","CYS","GLU","GLN","GLY","HIS","ILE","LEU","LYS","MET","PHE","PRO","SER","THR","TRP","TYR","VAL");
code1 <- c("A", "R", "N", "D", "C", "E", "Q", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V");
codeN <- c(seq(1,20));

codon3  <- c("AAG", "AAT", "CAG", "TTT", "AGG", "TTG", "GGG", "GCG", "GCT", "ATT", "GGT", "CCT", "TCT", "TCG", "CGG", "CTT", "GTG", "ACT", "ATG", "CAT", "GAG", "ACG", "GTT", "AGT", "TGT", "TGG", "CCG", "GAT", "CTG", "CGT", "TAT");
codonN <- c(seq(1,31));

#pos1 = c(seq(1,172));
#pos1 = c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","52A","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","82A","82B","82C","83","84","85","86","87","88","89","90","91","92","93","94","95");

#posN = c(seq(1,length(pos1)));

# Base sequence
seq="KKVVLGKKGDTVELTCTASQKKSIQFHWKNSNQIKILGNQGSFLTKGPSKLNDRADSRRSLWDQGNFPLIIKNLKIEDSDTYICEVEDQKEEVQLLVFG";
seq_vector =substring(seq, seq(1,nchar(seq),1),seq(1,nchar(seq),1));
#pos3 =aaa(seq_vector);

# Inteface positions
#pos_interface = c("28","30","31","33","35","44","46","47","48","49","50","51","52","52A","53","54","55","56","57","58","59","60","61","62","63","64","65","67","68","69","70","71","72","73","74","75","97","98","99","100","100A","100B","100C");

#IGHV1_02star02 = "CAGGTGCAGCTGGTGCAGTCTGGGGCTGAGGTGAAGAAGCCTGGGGCCTCAGTGAAGGTCTCCTGCAAGGCTTCTGGATACACCTTCACCGGCTACTATATGCACTGGGTGCGACAGGCCCCTGGACAAGGGCTTGAGTGGATGGGATGGATCAACCCTAACAGTGGTGGCACAAACTATGCACAGAAGTTTCAGGGCAGGGTCACCATGACCAGGGACACGTCCATCAGCACAGCCTACATGGAGCTGAGCAGGCTGAGATCTGACGACACGGCCGTGTATTACTGTGCGAG";

#codons_IGHV1_02star02 = c("CAG","GTG","CAG","CTG","GTG","CAG","TCT","GGG","GCT","GAG","GTG","AAG","AAG","CCT","GGG","GCC","TCA","GTG","AAG","GTC","TCC","TGC","AAG","GCT","TCT","GGA","TAC","ACC","TTC","ACC","GGC","TAC","TAT","ATG","CAC","TGG","GTG","CGA","CAG","GCC","CCT","GGA","CAA","GGG","CTT","GAG","TGG","ATG","GGA","TGG","ATC","AAC","CCT","AAC","AGT","GGT","GGC","ACA","AAC","TAT","GCA","CAG","AAG","TTT","CAG","GGC","AGG","GTC","ACC","ATG","ACC","AGG","GAC","ACG","TCC","ATC","AGC","ACA","GCC","TAC","ATG","GAG","CTG","AGC","AGG","CTG","AGA","TCT","GAC","GAC","ACG","GCC","GTG","TAT","TAC","TGT","GCG","AGA", # ADDED FROM HERE TO END FROM pos_codon, (VRC01GL yeast-codon-optimized).
# "GGT","AAG","AAC","TCT","GAT","TAC","AAT","TGG","GAT","TTC","CAA","CAT","TGG","GGC","CAG","GGC","ACT","TTG","GTT","ACT","GTT","TCA");


#Amino acid	Codons	Compressed		Amino acid	Codons	Compressed
#Ala/A	GCT, GCC, GCA, GCG	GCN
#Leu/L	TTA, TTG, CTT, CTC, CTA, CTG	YTR, CTN
#Arg/R	CGT, CGC, CGA, CGG, AGA, AGG	CGN, MGR
#Lys/K	AAA, AAG	AAR
#Asn/N	AAT, AAC	AAY
#Met/M	ATG
#Asp/D	GAT, GAC	GAY
#Phe/F	TTT, TTC	TTY
#Cys/C	TGT, TGC	TGY
#Pro/P	CCT, CCC, CCA, CCG	CCN
#Gln/Q	CAA, CAG	CAR
#Ser/S	TCT, TCC, TCA, TCG, AGT, AGC	TCN, AGY
#Glu/E	GAA, GAG	GAR
#Thr/T	ACT, ACC, ACA, ACG	ACN
#Gly/G	GGT, GGC, GGA, GGG	GGN
#Trp/W	TGG
#His/H	CAT, CAC	CAY
#Tyr/Y	TAT, TAC	TAY
#Ile/I	ATT, ATC, ATA	ATH
#Val/V	GTT, GTC, GTA, GTG	GTN
#START	ATG
#STOP	TAA, TGA, TAG	TAR, TRA

aa_names =c("ALA","LEU","ARG","LYS","ASN","MET","ASP","PHE","CYS","PRO","GLN","SER","GLU","THR","GLY","TRP","HIS","TYR","ILE","VAL");
aa_codons = data.frame(ALA=c("GCT", "GCC", "GCA", "GCG", NA   , NA ),LEU=c("TTA", "TTG", "CTT", "CTC", "CTA", "CTG"),ARG=c("CGT", "CGC", "CGA", "CGG", "AGA", "AGG"),LYS=c("AAA", "AAG",  NA  , NA  , NA, NA),ASN=c("AAT", "AAC",NA  , NA  , NA, NA),MET=c("ATG",NA  , NA  , NA, NA,NA),ASP=c("GAT", "GAC", NA  , NA, NA,NA),PHE=c("TTT", "TTC", NA  , NA, NA,NA),CYS=c("TGT", "TGC" , NA  , NA, NA,NA),PRO=c("CCT", "CCC", "CCA", "CCG",NA,NA),GLN=c("CAA", "CAG" , NA  , NA, NA,NA),SER=c("TCT", "TCC", "TCA", "TCG", "AGT", "AGC"),GLU=c("GAA", "GAG",NA,NA,NA,NA),THR=c("ACT", "ACC", "ACA", "ACG",NA,NA),GLY=c("GGT", "GGC", "GGA", "GGG",NA,NA),TRP=c("TGG",NA,NA,NA,NA,NA),HIS=c("CAT", "CAC",NA,NA,NA,NA),TYR=c("TAT", "TAC",NA,NA,NA,NA),ILE=c("ATT", "ATC", "ATA",NA,NA,NA),VAL=c("GTT", "GTC", "GTA", "GTG",NA,NA));

# Usage:
# as.vector(aa_codons[["HIS"]][!is.na(aa_codons[["HIS"]])]);

s2c <- function (string) 
{
    if (is.character(string) && length(string) == 1) {
     #   return(.Call("s2c", string, PACKAGE = "seqinr"))
     return(strsplit(string, "")[[1]])
    }
    else {
        warning("Wrong argument type in s2c(), NA returned")
        return(NA)
    }
}

a <- function (aa) 
{
    aa1 <- s2c("*ACDEFGHIKLMNPQRSTVWY")
    if (missing(aa)) 
        return(aa1)
    aa3 <- aaa()
    convert <- function(x) {
        if (all(x != aa3)) {
            warning("Unknown 3-letters code for aminoacid")
            return(NA)
        }
        else {
            return(aa1[which(x == aa3)])
        }
    }
    return(as.vector(unlist(sapply(aa, convert))))
}

aaa <- function(aa) 
{
    aa3 <- c("Stp", "Ala", "Cys", "Asp", "Glu", "Phe", "Gly", 
        "His", "Ile", "Lys", "Leu", "Met", "Asn", "Pro", "Gln", 
        "Arg", "Ser", "Thr", "Val", "Trp", "Tyr")
    if (missing(aa)) 
        return(aa3)
    aa1 <- a()
    convert <- function(x) {
        if (all(x != aa1)) {
            warning("Unknown one letter code for aminoacid")
            return(NA)
        }
        else {
            return(aa3[which(x == aa1)])
        }
    }
    return(as.vector(unlist(sapply(aa, convert))))
}



setupNNKAnalysis <-function(theSeq,thePositions=c()){
  
     # Reset these variables...globally!!!! using "<<-"
     seq <<- theSeq;
     seq_vector <<- substring(seq, seq(1,nchar(seq),1),seq(1,nchar(seq),1));
     pos3 <<- aaa(seq_vector);

     if (length(thePositions) == 0){
       pos1 <<- c(seq(1,nchar(seq)));
       posN <<- pos1;
     } else {
       pos1 <<- thePositions;
       posN <<- c(seq(1,length(thePositions)));
     }

}



getCodonsForAA <- function(aa){
  return (as.vector(aa_codons[[aa]][!is.na(aa_codons[[aa]])]));
}

stringNumDiff <- function(a,b){
  return (mapply(function(x,y) sum(x!=y), strsplit(a,""),strsplit(b,"")));
}

convertCODON <-function(str,rev=FALSE){
  for (i in 1:length(codon3)){
    if (rev){
      str = gsub(codonN[i],codon3[i],str,ignore.case=TRUE);
    } else {
      str = gsub(codon3[i],codonN[i],str,ignore.case=TRUE);
    }
  }

  return(str);
}
convertAA <-function(str,rev=FALSE){
  for (i in 1:length(code1)){
    if (rev){
      str = gsub(codeN[i],code1[i],str,ignore.case=TRUE);
    } else {
      str = gsub(code1[i],codeN[i],str,ignore.case=TRUE);
    }
  }

  return(str);
}

convertAA2 <-function(num){
  return(code1[num]);
}

convertAA3 <-function(str){
  for (i in 1:length(code3)){
      str = gsub(code3[i],codeN[i],str,ignore.case=TRUE);
  }

  return(str);
}

convertAA4 <-function(str){
  for (i in 1:length(code1)){
      str = gsub(code1[i],sprintf("%s,",code3[i]),str,ignore.case=TRUE);
  }

  return(str);
}

convertPos2 <-function(num){
  return(pos1[num]);
}

 
heatmapPlotCODON <- function(dat){
   codons = as.integer(convertCODON(dat$CODON));
   codons[is.na(codons)] = 0;
   pos    = as.integer(as.vector(dat$RESI));
#   hh = hist2d(codons,pos,nbins=c(max(codons)-min(codons)+1,max(pos)-min(pos)+1),col = c("white",heat.colors(256)),show=FALSE);
   hh = hist2d(codons,pos,nbins=31,col = c("white",heat.colors(256)),show=FALSE);
   hh[is.na(hh)] = 0;
   print(hh);
   numDecimals=2;
   prob1=(hh$counts / sum(hh$counts) * 1000*10^numDecimals);
   prob2=(hh$counts / sum(hh$counts) * 1000*10^numDecimals) %% 10;
   prob=(prob1-prob2)/ (10*10^numDecimals);
   hh$counts[hh$counts==0] = NA;
   print(ceiling(hh$x.breaks));
   
   label="Position,Codon heatmap";
#   heatmap.2(hh$counts, dendrogram=c("none"), scale=c("none"), labRow=convertAA(ceiling(hh$x.breaks),rev=TRUE),labCol=ceiling(hh$y.breaks),Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(hh$x.breaks)),colsep=c(0:length(hh$y.breaks)),col=colorRampPalette(c("lightgrey","yellow","red")),na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos",cellnote=as.matrix(prob),notecol="darkslategrey");

#    heatmap.2(prob, dendrogram=c("none"), scale=c("none"), labRow=ceiling(hh$x.breaks),labCol=ceiling(hh$y.breaks),Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(hh$x.breaks)),colsep=c(0:length(hh$y.breaks)),col=colorRampPalette(c("lightgrey","yellow","red")),na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos");
    heatmap.2(hh$counts, dendrogram=c("none"), scale=c("none"), labRow=ceiling(hh$x.breaks),labCol=ceiling(hh$y.breaks),Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(hh$x.breaks)),colsep=c(0:length(hh$y.breaks)),col=colorRampPalette(c("lightgrey","yellow","red")),na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos");
}


makeRectsForBlocks <- function(blocksX,blocksY){

  for (i in 1:length(blocksX)){

#    rect(blocksX[i]-0.25,blocksY[i]-0.45,
#         blocksX[i]+0.25,blocksY[i]+0.45,
#         lwd=0.5);
    points(blocksX[i],blocksY[i],pch=20,cex=0.5);
  }
  
}

getNumReadsNumAAsPerPosition <-function(dat){

  # Sum AA-counts over each position
  sumHH = c();
  numAA = c();
  minAA = c();
  maxAA = c();
  aveAA = c();
  sumCC = c();
  numCC = c();
  minCC = c();
  maxCC = c();
  aveCC = c();
  cat("Compute AA-counts over each position in dat\n");
  for (i in 1:length(posN)){
#  for (i in 1:5){
#     CODONcounts = table(factor(as.vector(subset(dat, RESI == i)$CODON),levels=codon3));
#     AAcounts = table(factor(as.vector(subset(dat, RESI == i)$AA),levels=code1));
     CODONcounts = table(factor(as.vector(subset(dat, POS == pos1[i])$CODON),levels=codon3));
     AAcounts = table(factor(as.vector(subset(dat, POS == pos1[i])$AA),levels=code1));
     #cat(sprintf("AAcounts[%s]\t",posN[i]));
     #cat(AAcounts);
     AAcounts.nonzero = AAcounts[AAcounts > 0];
#     cat("\nAAcounts.nonzero[%s]\t");
#     cat(AAcounts.nonzero);
#     cat("\tLENGth\t");
#     cat(length(AAcounts.nonzero));
#     cat("\n");
     sumcounts = sum(AAcounts);
     num.nonzero = length(AAcounts.nonzero);
     sumHH = cbind(sumHH,sumcounts);
     numAA = cbind(numAA,num.nonzero);
     aveAA = cbind(aveAA,mean(AAcounts));
     minAA = cbind(minAA,min(AAcounts));
     maxAA = cbind(maxAA,max(AAcounts));

     CCcounts.nonzero = CODONcounts[CODONcounts > 0];
     sumcodons = sum(CODONcounts);
     sumCC = cbind(sumCC,sumcodons);
     numCC = cbind(numCC,length(CCcounts.nonzero));
     aveCC = cbind(aveCC,mean(CODONcounts));
     minCC = cbind(minCC,min(CODONcounts));
     maxCC = cbind(maxCC,max(CODONcounts));
   }

  df = data.frame(reads=as.vector(sumHH[1,]),aas=as.vector(numAA),aveAA=as.vector(aveAA),minAA=as.vector(minAA),maxAA=as.vector(maxAA),pos=pos1,
                  readsCodon=as.vector(sumCC[1,]),codons=as.vector(numCC),aveCodon=as.vector(aveCC),minCodon=as.vector(minCC),maxCodon=as.vector(maxCC));
  return(df);
}

heatmapPlotAA.bigFreq <- function (dat,dat2,dat3,cutoff=0.10){
  # Sum AA-counts over each position
  sumHH = c();
  cat("Compute AA-counts over each position in dat\n");
  for (i in 1:length(posN)){
     AAcounts = table(factor(as.vector(subset(dat, RESI == i)$AA),levels=code1));
     sumcounts = sum(AAcounts);

     
     # FILTER: LOW-COUNT: if total counts at a position is < 10, then set sum to -1.
     if (sumcounts < 10){
       cat(sprintf("Position: %d has really low counts in dataset 1\n",i));
       sumHH = cbind(sumHH,-1);
     } else {
       
     # FILTER: NOT SIGNIFIGANT BY MULTINOMIAL CHI SQ TEST
     pval = getPval(AAcounts);
     #pval = 0.05;
     if (pval > 0.05){
         cat(sprintf("Position: %d does not have a signifigant difference from the null hypothesis\n",i));
         sumHH = cbind(sumHH,-1);
       } else {
         sumHH = cbind(sumHH,sumcounts);
       }
   }
     
   }

   cat("Compute Prob-counts over each position in dat\n");
   # Compute Prob matrix for first dataset 'dat' , 'hh'.
   probHH = c();
   for (i in 1:20){
     counts = table(factor(as.vector(subset(dat, AA == code1[i])$RESI),levels=c(1:length(posN))));
     probHH = rbind(probHH, as.vector(counts)/sumHH);
   }

  probHH[probHH < cutoff] = NA;
  my_palette <- diverge.color(start.color="blue",end.color="red",min.value=0,max.value=as.integer(5*max(probHH,na.rm=TRUE)),mid.color="yellow");
  heatmap.2(probHH*100, dendrogram=c("none"), scale=c("none"), labRow=code1,labCol=pos1,Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(code1)),colsep=c(0:length(pos1)),col=my_palette,na.col="white",density.info=c("none"),main="probHH",ylab="AA",xlab="Pos",add.expr=makeRectsForBlocks(posN,(21-as.integer(convertAA3(pos3)))));
  
}

computeGateFrequencies <- function(prop_list,pdfbase,cutoff=5){

  topCounts = prop_list[[4]];
  botCounts = prop_list[[5]];
  
  topFreq = topCounts / sum(topCounts);
  botFreq = botCounts / sum(botCounts);

  botFreq[botFreq == 0] = NA;
  gateFreq = topFreq/botFreq;
  gateFreq[gateFreq<cutoff] = NA;
  
  pdfname = sprintf("gateEnrichment_%s.pdf",pdfbase);
  heatmapPlotAA(gateFreq,makepdf=pdfname);

  fname = sprintf("gateEnrichment_%s.csv",pdfbase);
  rownames(gateFreq) = code3;
  colnames(gateFreq) = pos1;
  write.csv(x=gateFreq,file=fname);
  
  gateFreqEnrichmentPerPosition = gateFreq;
  
  # Apply Fiters for per-position values
  topCounts.wt = 0;
  botCounts.wt = 0;
  for (i in 1:length(posN)){

     wt_index = (as.integer(convertAA3(pos3)))[i];
     gateFreq.wt = gateFreq[wt_index,i];
#     cat("GateFreq.wt: ",i," ",wt_index," ",gateFreq.wt,"\t");
     
     # If gateFreq.wt is 0, then set to equal top/bottom.
#     if ( (! (is.nan(gateFreq.wt) || (is.na(gateFreq.wt)))) &&
     if (gateFreq.wt==0 || is.na(gateFreq.wt)) {
       gateFreq.wt = 0.05;
     }
#     cat(gateFreq.wt,"\n");
     gateFreqEnrichmentPerPosition[,i] = gateFreq[,i]/gateFreq.wt;
     

     topCounts.wt = topCounts.wt + topCounts[wt_index,i];
     botCounts.wt = botCounts.wt + botCounts[wt_index,i];

          
  }
  gateFreqEnrichmentPerPosition = log10(gateFreqEnrichmentPerPosition);
  
  pdfname = sprintf("relativeGateEnrichmentPerPosition_%s.pdf",pdfbase);
  cat(pdfname,"\n");
  heatmapPlotAA(gateFreqEnrichmentPerPosition,makepdf=pdfname);

  fname = sprintf("relativeGateEnrichmentPerPosition_%s.csv",pdfbase);
  rownames(gateFreqEnrichmentPerPosition) = code3;
  colnames(gateFreqEnrichmentPerPosition) = pos1;
  write.csv(x=gateFreqEnrichmentPerPosition,file=fname);
  
  gateFreqAll.wt =  (topCounts.wt / sum(topCounts)) / (botCounts.wt / sum(botCounts));
  gateFreqEnrichment = log10(gateFreq / gateFreqAll.wt);

  pdfname = sprintf("relativeGateEnrichment_%s.pdf",pdfbase);
  cat(pdfname,"\n");
  heatmapPlotAA(gateFreqEnrichment,makepdf=pdfname);

  fname = sprintf("relativeGateEnrichment_%s.csv",pdfbase);
  rownames(gateFreqEnrichment) = code3;
  colnames(gateFreqEnrichment) = pos1;
  write.csv(x=gateFreqEnrichment,file=fname);
  
  return(list(gateFreq,gateFreqEnrichmentPerPosition,gateFreqEnrichment));
}

createTablesAndFigures <- function(prop_list,pdfbase){

  fname = sprintf("relativeEnrichmentPerPosition_%s.csv",pdfbase);
  rownames(prop_list[[1]]) = code3;
  colnames(prop_list[[1]]) = pos1;
  write.csv(x=prop_list[[1]],file=fname);
  
  fname = sprintf("relativeEnrichmentPerPosition_%s.pdf",pdfbase);
  heatmapPlotAA(prop_list[[1]],label=pdfbase,makepdf=fname);

  fname = sprintf("freqTopPerPosition_%s.csv",pdfbase);
  rownames(prop_list[[2]]) = code3;
  colnames(prop_list[[2]]) = pos1;
  write.csv(x=prop_list[[2]],file=fname);
  
#  fname = sprintf("freqTopPerPosition_%s.pdf",pdfbase);
#  heatmapPlotAA(prop_list[[2]]*100,label=pdfbase,makepdf=fname);

  fname = sprintf("countTop_%s.csv",pdfbase);
  rownames(prop_list[[4]]) = code3;
  colnames(prop_list[[4]]) = pos1;
  write.csv(x=prop_list[[4]],file=fname);
  
#  fname = sprintf("countTop_%s.pdf",pdfbase);
#  heatmapPlotAA(prop_list[[4]],label=pdfbase,makepdf=fname);

  fname = sprintf("freqBotPerPosition_%s.csv",pdfbase);
  rownames(prop_list[[3]]) = code3;
  colnames(prop_list[[3]]) = pos1;
  write.csv(x=prop_list[[3]],file=fname);
  
#  fname = sprintf("freqBotPerPosition_%s.pdf",pdfbase);
#  heatmapPlotAA(prop_list[[3]]*100,label=pdfbase,makepdf=fname);

  fname = sprintf("countBot_%s.csv",pdfbase);
  rownames(prop_list[[5]]) = code3;
  colnames(prop_list[[5]]) = pos1;
  write.csv(x=prop_list[[5]],file=fname);
  
#  fname = sprintf("countBot_%s.pdf",pdfbase);
#  heatmapPlotAA(prop_list[[5]],label=pdfbase,makepdf=fname);

  # Compute gate frequencies and write files.
  gf = computeGateFrequencies(prop_list, pdfbase=pdfbase);

  return(gf);
}

# Function to select mutations at positions that are enriched across many datasets
#  example: condenseTables(c("mat.12A12.prop","mat.VRC01.prop"),1,"average",1);
condenseTables <- function(tables, lower_cutoff=NA,upper_cutoff=NA,which.table="average", minNumTables=NA,tables.index=NA,pdfbase="condensedTables"){


  if (is.na(minNumTables)){
    minNumTables = length(tables);
  }

    
  # logicalTable has TRUE for values in table lower than cutoff
    logicalTable = list(length(get(tables[1])));

  for (i in 1:length(tables)){

    aTable = get(tables[i]);
    if (! is.na(tables.index)){
      aTable = get(tables[i])[[tables.index]];
    }
    aTable[is.na(aTable)] = FALSE;
    if (i == 1){
      if (is.na(upper_cutoff)){
        logicalTable = (aTable >= lower_cutoff);
      } else {
        logicalTable = (aTable <= upper_cutoff);
      }
    } else {
      if (is.na(upper_cutoff)){
#      logicalTable = logicalTable & aTable < lower_cutoff;
        logicalTable = (logicalTable) + (aTable >= lower_cutoff);
      } else {
        logicalTable = (logicalTable) + (aTable <= upper_cutoff);
      }
    }
  }

  cat("Done creating logicalTable\n");

  # Remove cells that have lower than minNumTables above lower_cutoff or below upper_cutoff;
  logicalTable[logicalTable < minNumTables] = FALSE;

  
  resultTable = list(length(get(tables[1])));
  if (which.table == "sum" || which.table == "average"){
    for (i in 1:length(tables)){
      aTable = get(tables[i]);
    if (! is.na(tables.index)){
        aTable = get(tables[i])[[tables.index]];
      }
      
      aTable[!logicalTable] = NA;
      if (i == 1){
        resultTable = aTable;
      } else {
        resultTable = resultTable + aTable;
      }
    }
    if (which.table == "average"){
      resultTable = resultTable / length(tables);
    }
    
  } else {
    resultTable = get(which.table);
    resultTable[!logicalTable] = NA;
  }


  pdfname = sprintf("%s.pdf",pdfbase);
  heatmapPlotAA(resultTable,makepdf=pdfname);

  fname = sprintf("%s.csv",pdfbase);
  write.csv(x=resultTable,file=fname);


  nonZeroColumns = which(sapply(1:length(resultTable[1,]), function(x) sum(resultTable[,x],na.rm=TRUE) ) != 0,arr.ind=TRUE);
  cat(paste(nonZeroColumns,collapse="+"));
  cat("\n");
  return(resultTable);
}

heatmapPlotAA <- function(dat_or_prop,label="Heatmap",min_cutoff=NA,max_cutoff=NA,makepdf=""){

  cat("Length dat or prop: ",length(dat_or_prop),"\t");
  if (!is.na(min_cutoff)){
    dat_or_prop = dat_or_prop[ dat_or_prop >= min_cutoff];
  }
  if (!is.na(max_cutoff)){
    dat_or_prop = dat_or_prop[ dat_or_prop <= max_cutoff];
  }
  cat("Length post-cutoff: ",length(dat_or_prop),"\t");
  
  if (makepdf != ""){
    pdf(makepdf,width=40);
  }
#  my_palette <- diverge.color(start.color="blue",end.color="red",min.value=0,max.value=as.integer(max(dat_or_prop,na.rm=TRUE)),mid.color="ivory");
  my_palette <- colorRampPalette(c("blue", "red"))(n = 50)
  heatmap.2(dat_or_prop, dendrogram=c("none"), scale=c("none"), labRow=code1,labCol=pos1,Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(code1)),colsep=c(0:length(pos1)),na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos",add.expr=makeRectsForBlocks(posN,(21-as.integer(convertAA3(pos3)))),col=my_palette); # col=my_palette,

  if (makepdf != ""){
    dev.off();
  }
  cat("\n");
}

heatmapPlotAA.merge <- function(prop,prop2="",cutoff=0.5,labelPlot="",makepdf=""){
  label="Position,AA heatmap";
  if (labelPlot != ""){
    label = sprintf("%s\n%s",labelPlot,label);
  }
  prop[prop<=cutoff] = NA;
  prop3 = prop;
  if (length(prop2) != 0){
    prop2[prop2<=cutoff] = NA;
    prop3 = (prop+prop2)/2;
    prop3[prop3 <= cutoff] = NA;
#    prop3[prop3 >= 1.0] = 1.0;
  }
#  prop3 = (prop3 - min(prop3,na.rm=TRUE)) / (max(prop3,na.rm=TRUE) - min(prop3,na.rm=TRUE));
#      colors=c(seq(-1.5,1.5,length=10));
#      my_palette <- diverge.color(start.color="blue",end.color="red",min.value=as.integer(5*min(prop3,na.rm=TRUE)),max.value=as.integer(5*max(prop3,na.rm=TRUE)),mid.color="blue");
  my_palette <- diverge.color(start.color="blue",end.color="red",min.value=0,max.value=as.integer(5*max(prop3,na.rm=TRUE)),mid.color="yellow");

   if (makepdf != ""){
     pdf(makepdf,width=15);
   }

  heatmap.2(10^prop3, dendrogram=c("none"), scale=c("none"), labRow=code1,labCol=pos1,Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(code1)),colsep=c(0:length(pos1)),col=my_palette,na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos",add.expr=makeRectsForBlocks(posN,(21-as.integer(convertAA3(pos3)))));

  if (makepdf != ""){
    dev.off();
   }
  return(prop3);
      
}
heatmapPlotAA.merge.propensity2 <- function(dat,dat2,labelPlot="",makepdf="",interface_only=FALSE,noplot=FALSE,posBase="L",newSeq="",top_percent_cutoff=0.01,enrichedTopOnly=FALSE){

   if (newSeq != ""){

     # Reset these variables...globally!!!! using "<<-"
     seq <<- newSeq;
     seq_vector <<- substring(seq, seq(1,nchar(seq),1),seq(1,nchar(seq),1));
     pos3 <<- aaa(seq_vector);
   }
   # Sum AA-counts over each position
  sumHH = c();
  cat("Compute AA-counts over each position in dat\n");
  for (i in 1:length(posN)){
     AAcounts = table(factor(as.vector(subset(dat, RESI == i)$AA),levels=code1));
     sumcounts = sum(AAcounts);

     
     # FILTER: LOW-COUNT: if total counts at a position is < 10, then set sum to -1.
     if (sumcounts < 10){
       cat(sprintf("Position: %d has really low counts in dataset 1\n",i));
       sumHH = cbind(sumHH,-1);
     } else {
       
     # FILTER: NOT SIGNIFIGANT BY MULTINOMIAL CHI SQ TEST
     pval = getPval(AAcounts);
     #pval = 0.05;
     if (pval > 0.05){
         cat(sprintf("Position: %d does not have a signifigant difference from the null hypothesis\n",i));
         sumHH = cbind(sumHH,-1);
       } else {
         sumHH = cbind(sumHH,sumcounts);
       }
   }
     
   }

   cat("Compute Prob-counts over each position in dat\n");
   # Compute Prob matrix for first dataset 'dat' , 'hh'.
   probHH   = c();
   countsHH = c();
   for (i in 1:20){
     counts   = table(factor(as.vector(subset(dat, AA == code1[i])$RESI),levels=c(1:length(posN))));
     countsHH = rbind(countsHH,as.vector(counts));
     probHH   = rbind(probHH, as.vector(counts)/sumHH);
   }

   
   # Sum AA-count over each position
   cat("Compute AA-counts over each position in dat2\n");
   sumHH2 = c();
   for (i in 1:length(posN)){
     AAcounts = table(factor(as.vector(subset(dat2, RESI == i)$AA),levels=code1));
     sumcounts = sum(AAcounts);

     # FILTER: LOW-COUNT: if total counts at a position is < 10, then set sum to -1.
     if (sumcounts < 10){
       cat(sprintf("Position: %d has really low counts in dataset 2\n",i));
       sumHH2 = cbind(sumHH2,-1);
     } else {
       sumHH2 = cbind(sumHH2,sumcounts);
     }
     
   }
   
   cat("Compute Prob-counts over each position in dat2\n");
   # Create Prob matrix for second dataset 'dat2' ; 'hh2'
   probHH2   = c();
   countsHH2 = c();
   for (i in 1:20){
     counts = table(factor(as.vector(subset(dat2, AA == code1[i])$RESI),levels=c(1:length(posN))));
     countsHH2 = rbind(countsHH2,as.vector(counts));
     probHH2   = rbind(probHH2, as.vector(counts)/sumHH2);
   }


   # FILTER - If 2nd dataset has a prob. of < 1%, then fix to 1%. (can not divide by 0).
   probHH2[probHH2 < 0.01] = 0.01;

   # FILTER - If 1st dataset has a prob < 0, then fix to 0. (This happens when LOW_COUNT has been triggered above).
   probHH[probHH < 0] = 0;
   
   # FILTER - If amino acid frequency is < top_percent_cutoff%, it is in the noise.
   probHH[probHH< top_percent_cutoff] = 0;
   
   # Compute the Enrichment value (ratio of dataset1 freq / dataset2 freq).
   prop = probHH / probHH2;

   # FILTER - only give those mutations that are more frequent in top than bottom
   if (enrichedTopOnly){
     prop[ prop <= 1 ] = 0;
   }
   
   cat("Compute AA-counts over each position for WT\n");
   
   # Apply Fiters for per-position values
   for (i in 1:length(posN)){

     # Skip propensity calculation of position if 0 or less counts in both datasets
     if (sumHH[i] <= 0 && sumHH2[i] <= 0){
       prop[,i] = NA;
       next;
     }
     
     # FILTER - Normalize data to WT Enrichment value.
     wt_index = (as.integer(convertAA3(pos3)))[i];
     prop.wt = prop[wt_index,i];
     cat(sprintf("PROP.WT = %5d, %5d, %8.3f, freq: %5f / %5f, sums: %6d %6d \n",i,wt_index,prop.wt,probHH[wt_index,i],probHH2[wt_index,i],sumHH[i],sumHH2[i]));
     
     # If Enrichment of WT is 0 then set to 'NA' (can not divide by 0).
     if ( (! (is.nan(prop.wt) || (is.na(prop.wt)))) &&
          (prop.wt==0)
         ){

       #  If dataset1 has > 320 counts (32 codons * 10) and we have 2.5-fold enrichment of at least 1 amino acid, then artifically set prop.wt to a low,low value
       if (sumHH[i] >= 320 && sum(!is.na(prop[,i])) > 1 && max(prop[,i],na.rm=TRUE) > 2.5){
                cat(sprintf("Position %d has a zero prop.wt value: %d, but good propensity of other AAs\n",i,prop.wt));
                prop.wt = abs(min(prop[,i],na.rm=TRUE)-0.5);
       } else {
         cat(sprintf("Position %d has a zero prop.wt value: %d\n",i,prop.wt));
         prop.wt = NA;
       }
     }
     prop[,i] = prop[,i]/prop.wt;

     
     # FILTER - Blank any amino acid that is more than 1 nucleotide from WT codon.
     
     # Within 1 nucleotide from germline gene
     # within1 = checkCodonMutations(i,code3,numNucChanges=2);
     # prop[codeN[!within1],i] = NA;
     
   }

   # FILTER - Propensities <= 0 set to 0.01. (can not take log10 0 or less). Should this be NA?
#   prop[prop<=0] = 0.01;
   prop[prop<=0] = NA;
   prop = log10(prop);

   # FILTER - Interface Only positions
   if (interface_only){
     prop[,which(pos %ni% pos_interface)] = NA;
   }


   # AFTER ALL FILTERS:
   #     Do not plot, just return propensity values
   if (noplot){
     rownames(prop) = code3;
     colnames(prop) = pos1;
     return( list(prop,probHH,probHH2,countsHH,countsHH2) );
   }
   
   # Make PDF flag
   if (makepdf != ""){
     pdf(makepdf,width=15);
   }
   
   label="Position,AA heatmap";
   if (labelPlot != ""){
     label = sprintf("%s\n%s",labelPlot,label);
   }
   pos_vec1 = posN;
   aa_vec1  = 21-as.integer(convertAA3(pos3));

   # Do the plotting with ggplot2
   if (interface_only){
     colors=c(seq(-1.5,1.5,length=10));
     my_palette <- colorRampPalette(c("blue", "lightgrey", "red"))(n = 10)
     heatmap.2(prop, dendrogram=c("none"), scale=c("none"), labRow=convertAA2(),labCol=convertPos2(ceiling(hh$y.breaks)),Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(hh$x.breaks)),colsep=c(0:length(hh$y.breaks)),col=my_palette,na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos",add.expr=makeRectsForBlocks(posN[which(pos1 %in% pos_interface)],(21-as.integer(convertAA3(pos3)))[which(pos1 %in% pos_interface)]),symkey=TRUE,symm=FALSE,symbreaks=TRUE);
   } else {
      colors=c(seq(-1.5,1.5,length=10));
      my_palette <- diverge.color(start.color="blue",end.color="red",min.value=as.integer(5*min(prop,na.rm=TRUE)),max.value=as.integer(5*max(prop,na.rm=TRUE)));
      heatmap.2(prop, dendrogram=c("none"), scale=c("none"), labRow=code1,labCol=pos1,Rowv=FALSE,Colv=FALSE,trace=c("none"),sepwidth=c(0.05,0.05),rowsep=c(0:length(code1)),colsep=c(0:length(pos1)),col=my_palette,na.col="white",density.info=c("none"),main=label,ylab="AA",xlab="Pos",add.expr=makeRectsForBlocks(posN,(21-as.integer(convertAA3(pos3)))));
   }
   
   if (makepdf != ""){
     dev.off();
   }
   
   rownames(prop) = code3;
   colnames(prop) = pos1;
   return( list(prop,probHH,probHH2,countsHH,countsHH2) );
}



diverge.color <- function(start.color,end.color,min.value,max.value,mid.value=0,mid.color="ivory"){
	# based on ideas from Maureen Kennedy, Nick Povak, and Alina Cansler

        # creates a palette for the current session for a divergent-color
	# graphic with a non-symmetric range
	# "cuts" = the number of slices to be made in the range above and below "mid.value"

        ramp1 <- colorRampPalette(c(start.color,mid.color))
        ramp2 <- colorRampPalette(c(mid.color,end.color))

       # now specify the number of values on either side of "mid.value"
       
       max.breaks <- round(max.value - mid.value)
       min.breaks <- round(mid.value - min.value)
       
       num.breaks <- max(max.breaks,min.breaks)
       
       low.ramp <- ramp1(num.breaks)
       high.ramp <- ramp2(num.breaks)
       
       # now create a combined ramp from the higher values of "low.ramp" and 
       # the lower values of "high.ramp", with the longer one using all values 
       # high.ramp starts at 2 to avoid duplicating zero
       
       myColors <- c(low.ramp[(num.breaks-min.breaks):num.breaks],high.ramp[2:max.breaks])
  
      myColors
}

loadFile <- function(filename,returnSet=-1,posBase="L",numnt_min=0,numnt_max=10,seq_len_cutoff=NA){
  dat = read.csv(filename,header=T,sep="");
  cat(sprintf("Length full dataset: %10d\n",length(dat$NUMBAR)))

  if (is.na(seq_len_cutoff)){
    seq_len_cutoff = as.integer(max(as.integer(as.vector(dat$SEQLEN)),na.rm=TRUE)/2);
  }
  dat.len = subset(dat, as.integer(as.vector(dat$SEQLEN)) >= seq_len_cutoff);
  cat(sprintf("Length seq_len dataset: %10d, cutoff=%10d\n",length(dat.len$NUMBAR),seq_len_cutoff));
  
  dat.barcode1 = subset(dat.len, dat.len$NUMBAR == 1);
  pos = as.integer(as.vector(gsub(posBase,"",dat.barcode1$POS)));

#  dat.barcode1$RESI = posN[pos-min(pos)+1];
  
  dat.barcode1$RESI = as.integer(dat.barcode1$POS);
  cat(sprintf("Length barcode1 dataset: %10d\n",length(dat.barcode1$NUMBAR)))

#  dat.barcode1.onlybarcode = dat.barcode1;
  dat.barcode1.onlybarcode = subset(dat.barcode1, as.integer(as.vector(dat.barcode1$NUMNT)) >= numnt_min & as.integer(as.vector(dat.barcode1$NUMNT)) <= numnt_max);
  cat(sprintf("Length barcode1.onlybarcode dataset: %10d\n",length(dat.barcode1.onlybarcode$NUMBAR)))

  
  dat.use = subset(dat.barcode1.onlybarcode,dat.barcode1.onlybarcode$AA != "STOP");
  dat.use$ID = sprintf("%s_%s", dat.use$POS, dat.use$CODON);
  cat(sprintf("Length dat.use dataset: %10d\n",length(dat.use$NUMBAR)))

  dat.use2 = subset(dat.use, substr(dat.use$CODON,3,3) == 'G' | substr(dat.use$CODON,3,3) == 'T');
  cat(sprintf("Length dat.use2 dataset: %10d\n",length(dat.use2$NUMBAR)))

  
  if (returnSet == 1){
    return(dat);
  } else if (returnSet == 2){
    return(dat.barcode1);
  } else if (returnSet == 3){
    return(dat.barcode1.onlybarcode);
  } else if (returnSet == 4){
    return(dat.error);
  }

  return(dat.use2);
}


checkCodonMutations <- function(pos,aa,numNucChanges=1){

  results = c();
  for (i in 1:length(aa)){

    codons_for_aa = getCodonsForAA(aa[i]);
    germline_codon = codons_IGHV1_02star02[pos];
    if (min(stringNumDiff(codons_for_aa,germline_codon)) <= 1){
      results = rbind(results,TRUE);
    } else{
      results = rbind(results,FALSE);
    }
  }

  return(results);
}


counts <- function(name, pos, aa){
  cat(sprintf("%s\n",name));
  dat = loadFile(name);
  for (i in 1:length(pos)){
    dat.pos = subset(dat, dat$RESI == pos[i]);
    dat.pos.aa = subset(dat.pos, dat.pos$AA == aa[i]);
    cat(sprintf("Pos %s [ %d ] , AAs %s [ %d ]\n", pos[i],length(dat.pos$RESI), aa[i],length(dat.pos.aa$RESI)));
  }
}

library(plyr)
roundUp <- function(x) 10^ceiling(log10(x))
roundUpNice <- function(x, nice=c(1,2,4,5,6,8,10)) {
    if(length(x) != 1) stop("'x' must be of length 1")
    10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

simpleHist <- function(part.dat,xlabel="Number",mainlab="Histogram",xaxis_skip=1){


  a = hist(part.dat,breaks=seq(min(part.dat)-0.5,max(part.dat)+0.5,1),col="lightgreen",xaxt='n',xlab=xlabel,main=mainlab);
  axis(1,at=seq(0,max(part.dat),xaxis_skip));
#  axis(2,at=seq(0,max(a$counts),5));
#  axis(2,at=round_any(x=as.integer(seq(0,max(a$counts)+1000,sd(a$counts)/4)),600));

#  densityAxis = seq(0,max(a$density),0.002)

#  axis(4,at=a$counts);
#  c = curve(dnorm(x,mean=mean(part.dat),sd=sd(part.dat)),add=TRUE,col="darkblue",lwd=2);
#  a = hist(part.dat,breaks=seq(-0.5,max(part.dat)+0.5,1),col="lightgreen",axes=FALSE);  

}

getEnrichedRange <- function(prop,prop2=c(),name="NONE",cutoff_max=0.50,cutoff_min=-0.50,positions=c(),fixbb_format=TRUE,includeWT=TRUE){
  cat("START ENRICHED RANGE\n");
  numpos = length(prop[1,]);


  if (length(positions) == 0){
    positions = c(1:numpos);
  } else {
    numpos=length(positions);
  }
  #pos_maximums = data.frame(index=c(1:numpos),sortname=c(rep(name,numpos)));
  pos_maximums = data.frame(index=positions,sortname=c(rep(name,numpos)));

  
  for (i in positions){
    noEnrich = FALSE;

    wt_index = as.integer(convertAA3(pos3))[i];
    wt_aa    = code3[wt_index];
    wt_prop  = prop[wt_index,i];
    
#    max_index = which.max(prop[,i]);
    order_pos = order(prop[,i],decreasing=T);
    #order_pos = c(1:length(prop[,i]));

    if (fixbb_format){
      str = sprintf("%-4d A PIKAA ",i);
    } else {
      str = sprintf("%1s",wt_aa);
    }
    start_str_len = nchar(str);
    for (j in 1:length(prop[,i])){
      a_index = order_pos[j];
      a_aa    = code1[a_index];
      a_prop  = prop[a_index,i];

      b_prop  = 100;
      if (length(prop2) != 0){
        b_prop = prop2[a_index,i];
      }
      
      if (a_index == wt_index && !includeWT){
        next;
      }
      
      if (is.na(a_prop)){
        next;
      }

      if (a_prop >= cutoff_min && a_prop <= cutoff_max){

        if (length(prop2) == 0 || (!is.na(b_prop) && b_prop >= cutoff_min && b_prop <= cutoff_max)){
          if (fixbb_format){
            str = sprintf("%s%1s",str,a_aa);
          } else {
            str = sprintf("%s, %1s, %6.2f",str,a_aa,a_prop);
          }
        }
      }
    }
    if (fixbb_format){
      # Skip empty positions
      if (start_str_len != nchar(str)){
        cat(sprintf("%-50s EX 1 LEVEL 4 EX 2 LEVEL 4 EX 3 EX 4 USE_INPUT_SC EX_CUTOFF 1\n",str));
      } 

    } else {
      cat(sprintf("%s,%3d,%s\n",name,i,str));
    }
  }
  cat("END ENRICHED RANGE\n");
}

getMostEnriched <- function(prop,top=1,name="NONE",cutoff=0.00,positions=c()){
  cat("START MOST ENRICHED\n");
  numpos = length(prop[1,]);


  if (length(positions) == 0){
    positions = c(1:numpos);
  } else {
    numpos=length(positions);
  }
  #pos_maximums = data.frame(index=c(1:numpos),sortname=c(rep(name,numpos)));
  pos_maximums = data.frame(index=positions,resi=pos1[positions],sortname=c(rep(name,numpos)));

  
  for (i in positions){
    noEnrich = FALSE;

    wt_index = as.integer(convertAA3(pos3))[i];
    wt_aa    = code3[wt_index];
    wt_prop  = prop[wt_index,i];
    
#    max_index = which.max(prop[,i]);
    order_pos = order(prop[,i],decreasing=T);
    str = sprintf("%1s",wt_aa);
    for (j in 1:top){
      colName = sprintf("top%d_prop",j);
      colName_aa = sprintf("top%d_aa",j);
      if (i == positions[1]){
        pos_maximums[colName] = c(rep(0,numpos));
        pos_maximums[colName_aa] = c(rep("X",numpos));
      }

      max_index = order_pos[j];
      max_aa    = code3[max_index];
      max_prop  = prop[max_index,i];
#      cat(sprintf("%d, %s, %6.2f\n",i,colName,max_prop));
      pos_maximums[colName][i,1] = max_prop;
      pos_maximums[colName_aa][i,1] = max_aa;

                    
      if (j == 1 && (is.na(max_prop) || max_prop < cutoff)){
        str = "";
        noEnrich=TRUE;
#        break;
      }
      str = sprintf("%s, %1s, %6.2f",str,max_aa,max_prop);
      
    }

   if (!noEnrich){
        cat(sprintf("%s,%3s,%s\n",name,pos1[i],str));
   }


   
  }
  cat("END MOST ENRICHED\n");
  return(pos_maximums[pos_maximums$top1_prop > cutoff & !is.na(pos_maximums$top1_prop),]);
}




getAACountsPerPosition <- function(sets,top=1,cutoff=0.5){
  cat("AAAAAAAAAA\n");
  # For each position, count the aas
#  for (i in 1:171){
   for (i in 101:300){

    aas_at_this_pos = c();
    cat(sprintf("POSITION IS %d\n",i));
    # For each set
    for (j in 1:length(sets)){
      s = sets[[j]];
      pos = s[s$index == i,];
      cat(sprintf("Set: %d\n",j));
      if (length(pos$index) == 0){
        next;
      }

#      cat(sprintf("Pos %d: %s\n",j,names(pos)));
      for (t in 1:top){
        colName = sprintf("top%d_aa", t);
#        cat(sprintf("Trying name %s.\n",colName));
        aa = pos[colName];

        colName_prop = sprintf("top%d_prop", t);
        if (!is.na(pos[colName_prop]) & pos[colName_prop] > cutoff){
          aa_str = sprintf("%s", aa);
          aas_at_this_pos = c(aas_at_this_pos,aa_str);
        }
      }
#      cat(sprintf("\n"));

    }

    t = table(aas_at_this_pos)[order(table(aas_at_this_pos),decreasing=TRUE)];
    
    n = names(t);

    counts = as.integer(t);
    enriched_aas = t[counts > 1];

    str = "";
    for (d in 1:length(enriched_aas)){
        str = sprintf("%s, %3s, %3d",str,names(enriched_aas)[d],as.integer(enriched_aas[d]));
    }
    cat(sprintf("%d%s\n",i,str));
    
  }


}

gl = c("12A12-GL-pos-frag.all.data","3BNC60-GL-pos-frag.all.data","3BNC60-MN-GL-pos-frag.all.data","CHA31-GL-pos-frag.all.data","NIH45-46-GL-pos-frag.all.data","NIH45HC-VRC01LC-GL-pos-frag.all.data","PGV04-GL-H1-L1-pos-frag.all.data","PGV20-GL-pos-frag.all.data","VRC01-GL-pos-frag.all.data");
mat = c("12A12Mat-pos-frag.all.data","3BNC60-Mat-pos-frag.all.data","CHA31-Mat-pos-frag.all.data","NIH45-46-Mat-pos-frag.all.data","PGV04-Mat-pos-frag.all.data","PGV20-Mat-pos-frag.all.data","VRC01-Mat-pos-frag.all.data");

getMostEnrichedSets2 <-function(files,refFile,top=5,cutoff=1.0,positions=c()){

  ref = loadFile(refFile);
  
  mostEnriched =c();
  for (i in 1:length(files)){

    a = loadFile(files[i]);
    b = heatmapPlotAA.merge.propensity(a,ref,noplot=TRUE);
    c = getMostEnriched(b, name=files[i],cutoff=cutoff,top=top,positions=positions);

    mostEnriched = rbind(mostEnriched,c);
  }

  #combos = getAACountsPerPosition(list(a4,b4,c4,d4,f4),top=top);
  #combos = getAACountsPerPosition(mostEnriched,top=top);  

  #return(combos);
}

getMostEnrichedSets <- function(){

  top=5;
  cutoff=1.0;
  
  a1 = loadFile("data/RheGL-12a12-Positive.data");
  a2 = loadFile("data/RheGL-12a12-Negative.data");
  a3 = heatmapPlotAA.merge.propensity(a1,a2,noplot=TRUE);
  a4 = getMostEnriched(a3, name="12a12",cutoff=cutoff,top=top);
    
  b1 = loadFile("data/RheGL-3BNC60-Positive.data");
  b2 = loadFile("data/RheGL-3BNC60-Negative.data");
  b3 = heatmapPlotAA.merge.propensity(b1,b2,noplot=TRUE);
  b4 = getMostEnriched(b3, name="3BNC60",cutoff=cutoff,top=top);

  c1 = loadFile("data/RheGL-PGV04-Positive.data");
  c2 = loadFile("data/RheGL-PGV04-Negative.data");
  c3 = heatmapPlotAA.merge.propensity(c1,c2,noplot=TRUE);
  c4 = getMostEnriched(c3, name="PGV04",cutoff=cutoff,top=top);
  
  d1 = loadFile("data/RheGL-PGV19-Positive.data");
  d2 = loadFile("data/RheGL-PGV19-Negative.data");
  d3 = heatmapPlotAA.merge.propensity(d1,d2,noplot=TRUE);
  d4 = getMostEnriched(d3, name="PGV19",cutoff=cutoff,top=top);
  
  #e1 = loadFile("data/RheGL-PGV20-Positive.data");
  #e2 = loadFile("data/RheGL-PGV20-Negative.data");
  #e3 = heatmapPlotAA.merge.propensity(e1,e2,noplot=TRUE);
  #e4 = getMostEnriched(e3, name="PGV20",cutoff=cutoff,top=top);
  
  f1 = loadFile("data/RheGL-VRC01-10p-Positive.data");
  f2 = loadFile("data/RheGL-VRC01-10p-Negative.data");
  f3 = heatmapPlotAA.merge.propensity(f1,f2,noplot=TRUE);
  f4 = getMostEnriched(f3, name="VRC01-10p",cutoff=cutoff,top=top);
  
  #g1 = loadFile("data/RheGL-VRC01-Positive.data");
  #g2 = loadFile("data/RheGL-VRC01-Negative.data");
  #g3 = heatmapPlotAA.merge.propensity(g1,g2,noplot=TRUE);
  #g4 = getMostEnriched(g3, name="VRC01",cutoff=cutoff,top=top);


  combos = getAACountsPerPosition(list(a4,b4,c4,d4,f4),top=top);  

  
}


getPval <- function(observations){

#    chi.sq = chisq.test(observations, p=c(rep(1/20,20)));
    chi.sq = chisq.test(observations, simulate.p.value=T,B=100);

    return (chi.sq$p.value);
}


getCommonEnriched <- function(dat, numHits=4,cutoff=0){

  resi = unique(dat[order(dat$resi),]$resi);

  for (i in resi){

    pos_sub = subset(dat,resi == i);
    all_aas   = c(as.vector(pos_sub$aa1),as.vector(pos_sub$aa2),as.vector(pos_sub$aa3));
    good_aas = table(all_aas)[table(all_aas) >= numHits];
    if (length(good_aas) != 0){

      for (j in 1:length(good_aas)){
        aa = names(good_aas)[j];

        aas = c(as.vector(subset(pos_sub, pos_sub$aa1 == aa)$prop1),as.vector(subset(pos_sub, pos_sub$aa2 == aa)$prop2),as.vector(subset(pos_sub, pos_sub$aa3 == aa)$prop3));

        cat(sprintf("%4s %s %s %3d %6.2f\n",i,pos_sub$wt[1],aa,as.integer(good_aas[j]),10^mean(as.numeric(aas[!is.na(aas)]))));
      
    }
    
   }
  }
}

#lotPieDistributionAA <- function(dat,position){
#
# # Dat is the string name for a variable, use get to convert
# if (length(dat) == 1){
#   pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=dat[1]);
# } else if (length(dat) == 2) {
#   old.par = par(mfrow=c(1,2));
#   pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=dat[1]);
#   text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#   pie(table(as.vector(subset(get(dat[2]), RESI == position)$AA)),main=dat[2]);
#   par(old.par);
# } else if (length(dat) == 4){
#   old.par = par(mfrow=c(2,2));
#   pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=dat[1]);
#   text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#   pie(table(as.vector(subset(get(dat[2]), RESI == position)$AA)),main=dat[2]);
#   pie(table(as.vector(subset(get(dat[3]), RESI == position)$AA)),main=dat[3]);
#   pie(table(as.vector(subset(get(dat[4]), RESI == position)$AA)),main=dat[4]);
#   par(old.par);
#   
# } else if (length(dat) == 6){
#   old.par = par(mfrow=c(3,2));
#   pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=dat[1]);
#   text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#   pie(table(as.vector(subset(get(dat[2]), RESI == position)$AA)),main=dat[2]);
#   pie(table(as.vector(subset(get(dat[3]), RESI == position)$AA)),main=dat[3]);
#   pie(table(as.vector(subset(get(dat[4]), RESI == position)$AA)),main=dat[4]);
#   pie(table(as.vector(subset(get(dat[5]), RESI == position)$AA)),main=dat[5]);
#   pie(table(as.vector(subset(get(dat[6]), RESI == position)$AA)),main=dat[6]);
#   par(old.par);
#   
# }
# 
#
plotPieDistributionAA.fromCounts <- function(dat,position,make_ave=FALSE,landscape=FALSE){

  pos=sprintf("X%d",position);

  # Setup the plot placements
  if (length(dat) == 1){
    old.par = par(mfrow=c(1,1));
  } else {
    if (landscape){
      old.par = par(mfrow=c(2,round(length(dat)/2)));
    } else {
      old.par = par(mfrow=c(as.integer(length(dat)/2),2)); #par(mfrow=c(round(length(dat)/2),2));
    }
  }

  # loop over number of plots..
  for (i in 1:length(dat)){
    # Dat is the string name for a variable, use get to convert
#    pie(get(dat[i])[[pos]],labels=get(dat[i])[[1]],main=dat[i]);
    if (sum(get(dat[i])[,position]) > 0){
#      pie(get(dat[i])[,position],labels=names(get(dat[i])[,position]),main=dat[i]);
#      pie(get(dat[i])[,position],labels=get(dat[i])[[1]],main=dat[i]);
      pie(get(dat[i])[,position],labels=rownames(get(dat[i])),main=dat[i]);
      text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#    text(1,-1 ,sprintf("Total counts = %d",sum(get(dat[i])[[pos]])));
#      text(1,-1 ,sprintf("Total counts = %d",sum(get(dat[i])[,position])));
    }
  }

  par(old.par);
  
#  if (length(dat) == 1){
#    
#    pie(get(dat[1])[[pos]],labels=get(dat[1])[[1]],main=dat[1]);
#    text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#    text(1,-1 ,sprintf("Total counts = %d",sum(get(dat[1])[[pos]])));
#  } else if (length(dat) == 2) {
#
#    old.par = par(mfrow=c(1,2));
#    pie(get(dat[1])[[pos]],labels=get(dat[1])[[1]],main=dat[1]);
#    text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#    text(1,-1 ,sprintf("Total counts = %d",sum(get(dat[1])[[pos]])));
#    
#    pie(get(dat[2])[[pos]],labels=get(dat[2])[[1]],main=dat[2]);
#    text(0, -4,sprintf("Total counts = %d",sum(get(dat[2])[[pos]])));
#    par(old.par);
#  } else if (length(dat) == 4){
#    old.par = par(mfrow=c(2,2));
#    pie(get(dat[1])[[pos]],labels=get(dat[1])[[1]],main=dat[1]);
#    text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#    text(1,-1 ,sprintf("Total counts = %d",sum(get(dat[1])[[pos]])));
#    
#    pie(get(dat[2])[[pos]],labels=get(dat[1])[[1]],main=dat[2]);
#    text(1, -1,sprintf("Total counts = %d",sum(t2)));
#    pie(table(as.vector(subset(get(dat[3]), RESI == position)$AA)),main=dat[3]);
#    text(1, -1,sprintf("Total counts = %d",sum(t3)));
#    pie(table(as.vector(subset(get(dat[4]), RESI == position)$AA)),main=dat[4]);
#    text(1, -1,sprintf("Total counts = %d",sum(t4)));
#    par(old.par);
#    
#  } else if (length(dat) == 6){
#    if (make_ave){
#      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
#      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
#      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
#      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
#      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
#      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));
#      tall = t1+t2+t3+t4+t5+t6;
#      pie(tall,main="all average");
#    } else {
#      if (landscape){
#        old.par = par(mfrow=c(2,3));
#      } else {
#        old.par = par(mfrow=c(3,2));
#      }
#      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
#      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
#      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
#      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
#      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
#      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));
#      
#      pie(t1,main=dat[1]);
#      text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#      text(1, -1,sprintf("Total counts = %d",sum(t1)));
#      pie(t2,main=dat[2]);
#      text(0,-1,sprintf("Total counts = %d",sum(t2)));
#      pie(t3,main=dat[3]);
#      text(0,-1,sprintf("Total counts = %d",sum(t3)));
#      pie(t4,main=dat[4]);
#      text(0,-1,sprintf("Total counts = %d",sum(t4)));
#      pie(t5,main=dat[5]);
#      text(0,-1,sprintf("Total counts = %d",sum(t5)));
#      pie(t6,main=dat[6]);
#      text(0,-1,sprintf("Total counts = %d",sum(t6)));
#      par(old.par);
#    }
#    
#  } else if (length(dat) == 8){
#      old.par = par(mfrow=c(4,2));
#      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
#      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
#      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
#      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
#      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
#      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));
#      t7 = table(as.vector(subset(get(dat[7]), RESI == position)$AA));
#      t8 = table(as.vector(subset(get(dat[8]), RESI == position)$AA));
#      
#      pie(t1,main=dat[1]);
#      text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
#      text(1, -1,sprintf("Total counts = %d",sum(t1)));
#      pie(t2,main=dat[2]);
#      text(0,-1,sprintf("Total counts = %d",sum(t2)));
#      pie(t3,main=dat[3]);
#      text(0,-1,sprintf("Total counts = %d",sum(t3)));
#      pie(t4,main=dat[4]);
#      text(0,-1,sprintf("Total counts = %d",sum(t4)));
#      pie(t5,main=dat[5]);
#      text(0,-1,sprintf("Total counts = %d",sum(t5)));
#      pie(t6,main=dat[6]);
#      text(0,-1,sprintf("Total counts = %d",sum(t6)));
#      pie(t7,main=dat[7]);
#      text(0,-1,sprintf("Total counts = %d",sum(t7)));
#      pie(t8,main=dat[8]);
#      text(0,-1,sprintf("Total counts = %d",sum(t8)));
#      par(old.par);    
#  }
  
}

plotPieDistributionAA.new <- function(dat,pos,make_ave=FALSE,landscape=FALSE,labels=c()){
    
  # Pull position from Pos1 vector
  position = which(pos1 %in% pos);
  cat(sprintf("POS: %s : %s\n", position,pos));
  if (length(labels) == 0){
      labels=dat;
  }
    
  glayout=c(1,1);
  if (length(dat) == 8){
        glayout=c(2,4);
  }
  if (length(dat) == 6){
    glayout=c(2,3);
  }
  if (length(dat) == 2){
    glayout=c(1,2);
  }
  old.par=par(mfrow=glayout);
  for (i in 1:length(dat)){
            t1 = table(as.vector(subset(get(dat[i]), RESI == position)$AA));     
	    if (length(t1) != 0){
	        pie(t1,main=labels[i]);
		if (i == 1){
	            mtext(side=3,sprintf("WT = %s-%s",pos3[position],pos1[position]));
		}
	        mtext(side=1,sprintf("Total counts = %d",sum(t1)));
	    } else {
                ggplot() +  annotate("text", x = 10,  y = 10,           size = 6,
           label = sprintf("Small/no counts at this position for this sort %s\n",labels[i])) + theme_void();
	        #text(x=0.5,y=0.5,sprintf("Small/no counts at this position for this sort %s\n",labels[i]),cex=1.8);
	    }
  }
    
  par(old.par);
    
}

plotPieDistributionAA <- function(dat,pos,make_ave=FALSE,landscape=FALSE,labels=c()){
		    
  # Pull position from Pos1 vector
  position = which(pos1 %in% pos);
  cat(sprintf("POS: %s : %s\n", position,pos));
  if (length(labels) == 0){
       labels=dat;
  }
  # Dat is the string name for a variable, use get to convert
  if (length(dat) == 1){
    t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
    pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=label[1]);
    text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
    text(1,-1 ,sprintf("Total counts = %d",sum(t1)));
  } else if (length(dat) == 2) {

    t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
    t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
    old.par = par(mfrow=c(1,2));
    pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=labels[1]);
    text(0,-1,sprintf("WT = %s-%s",pos3[position],pos1[position]));
    text(1, -1,sprintf("Total counts = %d",sum(t1)));
    pie(table(as.vector(subset(get(dat[2]), RESI == position)$AA)),main=labels[2]);
    text(1, -1,sprintf("Total counts = %d",sum(t2)));
    par(old.par);
  } else if (length(dat) == 4){
    t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
    t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
    t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
    t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
    if (length(t1) == 0 || length(t2) == 0 || length(t3) == 0|| length(t4) == 0){
        return(-1);
    }
    old.par = par(mfrow=c(2,2));
    pie(table(as.vector(subset(get(dat[1]), RESI == position)$AA)),main=labels[1]);
    mtext(side=3,sprintf("WT = %s-%s",pos3[position],pos1[position]));
    #text(0,-1,pos=2,sprintf("WT = %s-%s",pos3[position],pos1[position]));
    #text(1, -1,sprintf("Total counts = %d",sum(t1)));
    mtext(side=1, sprintf("Total counts = %d",sum(t1)));
    pie(table(as.vector(subset(get(dat[2]), RESI == position)$AA)),main=labels[2]);
    mtext(side=1,sprintf("Total counts = %d",sum(t2)));
    pie(table(as.vector(subset(get(dat[3]), RESI == position)$AA)),main=labels[3]);
    mtext(side=1,sprintf("Total counts = %d",sum(t3)));
    pie(table(as.vector(subset(get(dat[4]), RESI == position)$AA)),main=labels[4]);
    mtext(side=1,sprintf("Total counts = %d",sum(t4)));
    par(old.par);
    
  } else if (length(dat) == 6){
    if (make_ave){
      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));
      tall = t1+t2+t3+t4+t5+t6;
      pie(tall,main="all average");
    } else {
      if (landscape){
        old.par = par(mfrow=c(2,3));
      } else {
        old.par = par(mfrow=c(3,2));
      }
      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));

      if (length(labels) == 0){
      	 labels=dat;
      }
      pie(t1,main=labels[1]);
      text(0,-1,pos=2,sprintf("WT = %s-%s",pos3[position],pos1[position]));
      text(1, -1,sprintf("Total counts = %d",sum(t1)));
      pie(t2,main=labels[2]);
      text(0,-1,sprintf("Total counts = %d",sum(t2)));
      pie(t3,main=labels[3]);
      text(0,-1,sprintf("Total counts = %d",sum(t3)));
      pie(t4,main=labels[4]);
      text(0,-1,sprintf("Total counts = %d",sum(t4)));
      pie(t5,main=labels[5]);
      text(0,-1,sprintf("Total counts = %d",sum(t5)));
      pie(t6,main=labels[6]);
      text(0,-1,sprintf("Total counts = %d",sum(t6)));
      par(old.par);
    }
    
  } else if (length(dat) == 8){
      old.par = par(mfrow=c(4,2));
      t1 = table(as.vector(subset(get(dat[1]), RESI == position)$AA));
      t2 = table(as.vector(subset(get(dat[2]), RESI == position)$AA));
      t3 = table(as.vector(subset(get(dat[3]), RESI == position)$AA));
      t4 = table(as.vector(subset(get(dat[4]), RESI == position)$AA));
      t5 = table(as.vector(subset(get(dat[5]), RESI == position)$AA));
      t6 = table(as.vector(subset(get(dat[6]), RESI == position)$AA));
      t7 = table(as.vector(subset(get(dat[7]), RESI == position)$AA));
      t8 = table(as.vector(subset(get(dat[8]), RESI == position)$AA));

      ts=c(t1,t2,t3,t4,t5,t6,t7,t8);

      for (i in 1:length(ts)){
          
	    if (length(ts[i]) != 0){
	        pie(ts[i],main=labels[i]);
		if (i == 1){
	            mtext(side=3,sprintf("WT = %s-%s",pos3[position],pos1[position]));
		}
	        mtext(side=1,sprintf("Total counts = %d",sum(ts[i])));
	    } else {
	        text(x=0.5,y=0.5,sprintf("Small/no counts at this position for this sort %s\n",labels[i]),cex=1.8);
	    }
      }
      par(old.par);    
  }
  
}
lotsOfPie <- function(positions,positionsHIV,vrc01,mat,gl,unsort){

  for (i in 1:length(positions)){
    fname_vrc01= sprintf("~/vax/work/eOD-GT8.1-NNK/eOD-GT8_1-NNK-fragments-061314/pie_position%d_%d_090514.pdf",positions[i],positionsHIV[i]);  
    pdf(fname_vrc01);
    plotPieDistributionAA(vrc01,positions[i]);
    dev.off();

    fname_mats= sprintf("~/vax/work/eOD-GT8.1-NNK/eOD-GT8_1-NNK-fragments-061314/pie_position%d_%d_mats_090514.pdf",positions[i],positionsHIV[i]);  
    pdf(fname_mats);
    plotPieDistributionAA(mat,positions[i]);
    dev.off();

    fname_gls= sprintf("~/vax/work/eOD-GT8.1-NNK/eOD-GT8_1-NNK-fragments-061314/pie_position%d_%d_gls_090514.pdf",positions[i],positionsHIV[i]);  
    pdf(fname_gls);
    plotPieDistributionAA(gl,positions[i]);
    dev.off();

    fname_unsort= sprintf("~/vax/work/eOD-GT8.1-NNK/eOD-GT8_1-NNK-fragments-061314/pie_position%d_%d_unsort_090514.pdf",positions[i],positionsHIV[i]);  
    pdf(fname_unsort);
    plotPieDistributionAA(unsort,positions[i]);
    dev.off();
  }

}


scoreSeq <- function(testseq,props,props2=c()){

  testseq_vector =substring(testseq, seq(1,nchar(testseq),1),seq(1,nchar(testseq),1));
  testseq_pos3   =aaa(testseq_vector);
  
  score  = 0.0;
  score2 = 0.0;
  
  # For each position
  for (p in 1:nchar(testseq)){

    aa_index = as.integer(convertAA3(testseq_pos3))[p];
    aa       = code3[aa_index];
    
    # For each enriched dataset
    aa_prop_ave = 0;
    for (i in 1:length(props)){
      prop = get(props[i]);
      aa_prop = prop[aa_index,p];
      if (is.na(aa_prop)){
        aa_prop = 0;
      }
#      cat(sprintf("PROP %d %s %6.2f\n",p,aa,aa_prop));
      aa_prop_ave = aa_prop_ave +aa_prop;
    }
    aa_prop_ave = aa_prop_ave / length(props);
    score = score + aa_prop_ave;

    if (length(props2) > 0){
      aa_prop_ave2 = 0;
      for (i in 1:length(props2)){
        prop2 = get(props2[i]);
        aa_prop2 = prop2[aa_index,p];
        if (is.na(aa_prop2)){
          aa_prop2 = 0;
        }
#      cat(sprintf("PROP %d %s %6.2f\n",p,aa,aa_prop));
        aa_prop_ave2 = aa_prop_ave2 +aa_prop2;
      }
      aa_prop_ave2 = aa_prop_ave2 / length(props2);
      score2 = score2 + aa_prop_ave2;
    }
    
  }



  # Divide score by length of sequence, because WT sequence should get a 0 at each position. Thus, WT score = 0.
  # score = score / nchar(testseq);
  cat(sprintf("%8.3f %8.3f %8.3f\n",score,score2,score2/score));
  return(c(score,score2));
}


plotNumReads <- function(dat,numReads="",pdfname="",codons=FALSE){

   if (numReads == ""){
     dat.numReads = getNumReadsNumAAsPerPosition(dat);
   } else {
     dat.numReads = numReads;
   }

   if (codons){
     if (pdfname != ""){
       pdf(sprintf("%s_numReadsCodon.pdf",pdfname),width=10);
     }

     print(ggplot(dat.numReads, aes(x=pos,y=readsCodon))+geom_bar(stat="identity"));
   } else {

     if (pdfname != ""){
       pdf(sprintf("%s_numReads.pdf",pdfname),width=10);
     }
     print(ggplot(dat.numReads, aes(x=pos,y=reads))+geom_bar(stat="identity"));
   }
   if (pdfname != ""){
     dev.off();
   } else {
     readline();
   }

   if (codons){
     if (pdfname != ""){
       pdf(sprintf("%s_numCodons.pdf",pdfname),width=10);
     }
     print(ggplot(dat.numReads, aes(x=pos,y=codons))+geom_bar(stat="identity"));
   } else {
     if (pdfname != ""){
       pdf(sprintf("%s_numAAs.pdf",pdfname),width=10);
     }
     print(ggplot(dat.numReads, aes(x=pos,y=aas))+geom_bar(stat="identity"));
   }
   if (pdfname != ""){
     dev.off();
   } else {
     readline();
   }

   if (codons){
     if (pdfname != ""){
       pdf(sprintf("%s_aveCodons.pdf",pdfname),width=10);
     }
     print(ggplot(dat.numReads, aes(x=pos,y=aveCodon))+geom_bar(stat="identity",fill="grey")+geom_linerange(ymax=dat.numReads$maxCodon,ymin=dat.numReads$minCodon)); #+ylim(c(0,2000)));
   } else {
     if (pdfname != ""){
       pdf(sprintf("%s_aveAAs.pdf",pdfname),width=10);
     }
     print(ggplot(dat.numReads, aes(x=pos,y=aveAA))+geom_bar(stat="identity",fill="grey")+geom_linerange(ymax=dat.numReads$maxAA,ymin=dat.numReads$minAA)+ylim(c(0,1000)));
   }
   if (pdfname != ""){
     dev.off();
   } else {
     readline();
   }

   return(dat.numReads);
}


meltTables <- function(sorts,cutoff=0.0,rn=code3,cn=pos1){

  all.aboveCutoff       = c();
  for (s in 1:length(sorts)){
    cat(sprintf("Working on sort %d\n", s));
    
    sort.aboveCutoff = as.matrix(get(gsub("^\\s+|\\s+$","",sorts[s])));
    sort.aboveCutoff[sort.aboveCutoff  <= cutoff]  = 0;
    sort.aboveCutoff[is.na(sort.aboveCutoff)] = 0;
    rownames(sort.aboveCutoff) = rn;
    colnames(sort.aboveCutoff) = cn;
    
    sort.aboveCutoff.m = melt(sort.aboveCutoff);
    sort.aboveCutoff.m$sort = gsub("^\\s+|\\s+$","",sorts[s]);

    all.aboveCutoff = rbind(all.aboveCutoff, sort.aboveCutoff.m);
  }
  return(all.aboveCutoff);
}

# Combine tables of position,aa into a new dataframe
# Plot circles...
# ggplot(d[d$aveValueAboveCutoff >= log(1.25) & d$numSortsAboveCutoff > 1 & d$pos %in% c(27,30,33,36,37,45,80,81,126,127,129,130,133,135,136,146),], aes(x=factor(aa),y=factor(pos)))+geom_point(aes(colour=exp(aveValueAboveCutoff),size=numSortsAboveCutoff))+scale_color_gradient(low="yellow",high="red",name="Fold Enrichment")+scale_size(range=c(2,10),name="# of sorts")+ylab("Position")+xlab("Amino Acid")+theme(axis.title.x=element_text(family="Helvetica",size=20),axis.title.y=element_text(family="Helvetica",size=20),axis.text.x=element_text(family="Helvetica",size=16),axis.text.y=element_text(family="Helvetica",size=16),legend.title=element_text(family="Helvetica",size=20),legend.position="top");
#


#geom_point(colour="black",data=data.frame(x=factor(ct[ct$foo == 1,]$pos),y=ct[ct$foo ==1,]$aa2),aes(x=x,y=y,size=8))+
#geom_point(colour="black",ct[ct$foo == 1,]$numSortsAboveCutoff+2.0),aes(x=x,y=y,size=size))+

#ggplot(data=ct[ct$aveValueAboveCutoff > log10(2) & ct$numSortsAboveCutoff > 5 & ct$pos %in% c(24:50,77:86,126:146),], aes(y=aa2,x=factor(pos)))+
#geom_point(colour="grey85",data=data.frame(x=factor(ct[ct$foo == 1,]$pos),y=ct[ct$foo ==1,]$aa2,size=6),aes(x=x,y=y,size=size))+
#geom_point(data=ct[ct$aveValueAboveCutoff > log10(2) & ct$numSortsAboveCutoff > 5 & ct$pos %in% c(24:50,77:86,126:146),],aes(x=factor(pos),y=aa2,colour=10^aveValueAboveCutoff,size=numSortsAboveCutoff))+
#geom_point(aes(size=numSortsAboveCutoff+1.0),colour="black")+
#geom_point(colour="black",data=data.frame(x=factor(ct[ct$foo == 1,]$pos),y=ct[ct$foo ==1,]$aa2,size=ct[ct$foo ==1,]$numSortsAboveCutoff+1.0),aes(x=x,y=y,size=size),shape=10)+
#scale_color_gradient(low="yellow",high="red",name="Binding Enrichment")+
#scale_size(range=c(4,12),name="# Abs with Binding Enrichment")+
#ylab("Mutation")+
#xlab("Position")+
#theme(axis.title.x=element_text(family="Helvetica",size=20),axis.title.y=element_text(family="Helvetica",size=20),axis.text.x=element_text(family="Helvetica",size=16),axis.text.y=element_text(family="Helvetica",size=16),legend.title=element_text(family="Helvetica",size=20),legend.position="top");

# Sorts are strings for instance c("gl.VRC01", "gl.PGV04");
combineTables <- function(sorts,cutoff=0.0, returnFullTable=FALSE,proteinSeq=c(),rn=code3,cn=pos1){

  positions = c();
  aas       = c();
  numSortsAbove = c();
  averageEnrich = c();

  all.aboveCutoff       = c();
  all.aboveCutoff.count = c();
  
  for (s in 1:length(sorts)){
    cat(sprintf("Working on sort %d\n", s));
    
    sort.aboveCutoff = as.matrix(get(gsub("^\\s+|\\s+$","",sorts[s])));
    sort.aboveCutoff[sort.aboveCutoff  <= cutoff]  = 0;
    sort.aboveCutoff[is.na(sort.aboveCutoff)] = 0;
    
    sort.aboveCutoff.count = sort.aboveCutoff;
    sort.aboveCutoff.count[sort.aboveCutoff.count > cutoff] = 1;
    if (s == 1){
      all.aboveCutoff       = sort.aboveCutoff;
      all.aboveCutoff.count = sort.aboveCutoff.count;
    } else {
      all.aboveCutoff       = all.aboveCutoff + sort.aboveCutoff;
      all.aboveCutoff.count = all.aboveCutoff.count + sort.aboveCutoff.count;
    }
    
  }
  cat(sprintf("HERE: %d\n", length(colnames(all.aboveCutoff))));
  if (returnFullTable){
    return(all.aboveCutoff);
  }
  
  # Now compute average
  all.aboveCutoff.ave = all.aboveCutoff / all.aboveCutoff.count;
  all.aboveCutoff.ave[is.na(all.aboveCutoff.ave)] = 0;
  
  # Reset the names of rows/cols in case old tables are being used
  rownames(all.aboveCutoff.ave) = rn;
  colnames(all.aboveCutoff.ave) = cn;

  df = data.frame(pos=c(),aa=c(), numSortsAboveCutoff=c(),aveValueAboveCutoff=c());
  
  for (i in 1:length(rownames(all.aboveCutoff.ave))){
      for (j in 1:length(colnames(all.aboveCutoff.ave))){

        tmp = data.frame(pos=c(colnames(all.aboveCutoff.ave)[j]),
                               aa= c(rownames(all.aboveCutoff.ave)[i]),
                               numSortsAboveCutoff=c(all.aboveCutoff.count[i,j]),
                               aveValueAboveCutoff=c(all.aboveCutoff.ave[i,j]));
        df = rbind(df, tmp);
        
      }
  }

  df$aa2 = factor(df$aa, levels = rev(levels(df$aa)));

  df$wt = 0;
  if (length(proteinSeq) != 0){
    df$wt = sapply(1:length(df$wt), function(x) { p=df[x,]$pos; a=as.vector(df[x,]$aa2); b=proteinSeq[proteinSeq$pos == p & proteinSeq$aa == a,]; if (length(b$pos) == 1) { return(1); } else { return(0);} });
  }


  return (df);
}

writeMatrix <- function(sorts,positions=c(24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,45,77,78,79,80,81,82,83,84,85,86,126:142,144,145,146)){
  for (s in 1:length(sorts)){
    a.sort = get(sorts[s]);
    rownames(a.sort) = code3;
    colnames(a.sort) = pos1;

    a.select = a.sort[,positions];
    
    write.csv(x=a.select,file=sprintf("matrix_%s.csv",sorts[s]));
  }

}
# 8 sorts: "standard.prop.gl.VRC01","standard.prop.gl.NIH4546","standard.prop.gl.12A12","standard.prop.gl.3BNC60MN","standard.prop.gl.CHA31","standard.prop.gl.PGV04H1L1","standard.prop.gl.PGV20","standard.prop.gl.PGV19"
# Positions: c(24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,45,77,78,79,80,81,82,83,84,85,86,126:142,144,145)
normalizedHeatmap <- function(sorts,positions=c(24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,45,77,78,79,80,81,82,83,84,85,86,126:142,144,145),pdfname="",noNormalization=FALSE){
  library(reshape);

  # Get melted sorts
  sorts.melt = c();
  the.max = -100;
  the.min = 100;
  
  for (s in 1:length(sorts)){
    a.sort = get(sorts[s]);
    rownames(a.sort) = code3;
    colnames(a.sort) = pos1;
    a.melt = melt(a.sort);
    
    a.melt.select = a.melt[a.melt$X2 %in% positions,];

    a.max = max(a.melt.select$value,na.rm=TRUE);
    a.min = min(a.melt.select$value,na.rm=TRUE);
    if (the.max < a.max){
      the.max = a.max;
    }
    if (the.min > a.min){
      the.min = a.min;
    }
  }
  cat(sprintf("Min=%6.2f, Max =%6.2f\n",the.min,the.max));
  
  # Add normalized value column to each melted sort and plot
  for (s in 1:length(sorts)){
    a.sort = as.matrix(get(sorts[s]));
    rownames(a.sort) = code3;
    colnames(a.sort) = pos1;

    a.norm = (a.sort+abs(the.min)) / (the.max+abs(the.min)); 
    write.csv(x=a.norm,file=sprintf("normalized_%s.csv",sorts[s]));
    
    a.melt = melt(a.sort);
    
    a.melt.select = a.melt[a.melt$X2 %in% positions,];
    
    cat(sprintf("%s length %d\n",sorts[s],length(a.melt.select$value)));
    if (noNormalization){
      a.melt.select$normValue = a.melt.select$value;
    } else {
      a.melt.select$normValue = (a.melt.select$value+abs(the.min)) / (the.max+abs(the.min));
    }

    # Print a blank labeled plot.
    if (pdfname != ""){
      pdf(sprintf("normalizedHeatmap_Legends_%s_%s.pdf",pdfname,sorts[s]));
    }
#   print(ggplot(a.melt.select,aes(factor(X1),factor(X2)))+geom_tile(aes(fill=normValue),colour="white")+scale_fill_gradient(low="white",high="red")+xlab("Amino Acids")+ylab("Positions")+theme(axis.title.x=element_blank(),axis.title.y=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(),legend.position="none"));
#    print(ggplot(a.melt.select,aes(factor(X1),factor(X2)))+geom_tile(aes(fill=normValue),colour="white")+scale_fill_gradient(low="white",high="red")+xlab("Amino Acids")+ylab("Positions")+theme(axis.title.x=element_blank(),axis.title.y=element_blank(),axis.text.x=axis.title.x=element_text(family="Helvetica",size=56),axis.text.y=element_text(family="Helvetica",size=56),axis.ticks=element_blank(),legend.title=element_text(family="Helvetica",size=56),legend.position="top"));
#       print(ggplot(a.melt.select,aes(factor(X1),factor(X2)))+geom_tile(aes(fill=normValue),colour="white")+scale_fill_gradient(low="white",high="red")+xlab("Amino Acids")+ylab("Positions")+theme(axis.title.x=element_blank(),axis.title.y=element_blank(),axis.title.x=element_text(angle=-90,family="Helvetica",size=35),axis.text.y=element_text(family="Helvetica",size=9),axis.ticks=element_blank(),legend.title=element_blank(),legend.position="top"));


    print(ggplot(a.melt.select,aes(factor(X2),factor(X1)))+geom_tile(aes(fill=normValue),colour="white")+scale_fill_gradient(low="white",high="red")+xlab("Positions")+ylab("Amino Acids")+theme(axis.title.x=element_blank(),axis.title.y=element_blank(),axis.title.x=element_text(angle=-90,family="Helvetica",size=35),axis.text.y=element_text(family="Helvetica",size=9),axis.ticks=element_blank(),legend.title=element_blank(),legend.position="top"));

    if (pdfname != ""){
      dev.off();
    } else {
      readline(prompt = "Pause. Press <Enter> to continue...")
    }
    
  }

  
  
}

# QC of data
# Number of times WT AA is the most observed at a given position
# Number of times WT AA is in the top 3 at a given position (allow for some noise)
QCdata <- function(dat,printTop=FALSE,printTop3=FALSE){

    for (d in 1:length(dat)){

        data = dat[d];
        sum.counts.all = 0;
        sum.all = 0;
        sum.pos = 0;
        sum.top3 = 0;
        sum.low.count = 0;
                                        # For each position
        for (i in 1:length(pos3)){
            # Sort according to frequency

            dat.col = get(data)[,i][order(get(data)[,i],decreasing=TRUE)];
            aa.names = names(dat.col);

            sum.counts.all = sum.counts.all + sum(dat.col);
            
            # Filter low-count positions
            if (sum(dat.col) < 32*10) { sum.low.count = sum.low.count + 1; next; }
            
            sum.all = sum.all +1;
            
            if (toupper(aa.names[1]) == toupper(pos3[i])){
                sum.pos = sum.pos + 1;
                if (printTop){
                    cat(sprintf("Position %d, total counts %d\n" , i,sum(dat.col)));
                }
            }

            if (toupper(aa.names[1])  == toupper(pos3[i]) || toupper(aa.names[2])  == toupper(pos3[i]) || toupper(aa.names[3])  == toupper(pos3[i])){
                sum.top3 = sum.top3 + 1;
                if (printTop3){
                    cat(sprintf("Position Top3 %d\n" , i));
                }
            }
        }
        cat(sprintf("\nQC for %s:\n",data));
        cat(sprintf("\t Total counts: %9d\n", sum.counts.all));
        cat(sprintf("\t Number positions with low read count: %4d\n", sum.low.count));
        cat(sprintf("\t Number of positions with WT AA is most observed:         %4d, total positions: %d\n",sum.pos,sum.all));
        cat(sprintf("\t Number of positions with WT AA is in top3 most observed: %4d, total positions: %d\n",sum.top3,sum.all));
        cat(sprintf("\n"));
    }
    
}
