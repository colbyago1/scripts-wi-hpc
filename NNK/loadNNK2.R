# Load the analysis script that has lots of functions in it
source("/Volumes/kulp/linux/users/dwkulp/software/kulplab_scripts/deep_seq_anal/analyzeNNK.R");

# Setup for the specific library requires sequence of library positions ONLY and position IDs in order.
setupNNKAnalysis(theSeq="VSTQLLIRSEQILNNAKIIIVTVKSIRIGPGQAFYYTFAQSSGGDLEITTHSIINMWQRAGQAMYTRDGGKDNNVNETFRPGGSDMRDNWRS",thePositions=c(255:260,272:286,303:309,312:320,361:375,423:435,455:481));

##############################
########## LOAD DATA #########
##############################

### UNSORT ###

cat("run2_unsort/unsort_dualBar10c.data\n");
Aunsort = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/unsort_dualBar10c.data",posBase="",numnt_min=-10,numnt_max=10);

### PGDM1400 ###

cat("run2_PGDM1400/PGDM1400_dualBar10c.data\n");
Atri = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/PGDM1400_dualBar10c.data",posBase="",numnt_min=-10,numnt_max=10);

### VRC01mat ###

cat("run2_VRC01mat/VRC01mat_dualBar10c.data\n");
Avmat = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/VRC01mat_dualBar10c.data",posBase="",numnt_min=-10,numnt_max=10);

### VRC01min ###

cat("run2_VRC01min/VRC01min_dualBar10c.data\n");
Avmin = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/VRC01min_dualBar10c.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_4A, 12A21 ###

cat("dualBars10/JH-4A-M1_S1_L001.dualBars10.data\n");
A4a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-4A-M1_S1_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-4A-M2_S2_L001.dualBars10.data\n");
A4b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-4A-M2_S2_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_5A, 12A21_min ###

cat("dualBars10/JH-5A-M1_S3_L001.dualBars10.data\n");
A5a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-5A-M1_S3_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-5A-M2_S4_L001.dualBars10.data\n");
A5b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-5A-M2_S4_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_6A,1-18 ###

cat("dualBars10/JH-6A-M1_S5_L001.dualBars10.data\n");
A6a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-6A-M1_S5_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-6A-M2_S6_L001.dualBars10.data\n");
A6b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-6A-M2_S6_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_7A, 118_minV1 ###

cat("dualBars10/JH-7A-M1_S7_L001.dualBars10.data\n");
A7a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-7A-M1_S7_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-7A-M2_S8_L001.dualBars10.data\n");
A7b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-7A-M2_S8_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_8A, 118_minV2 ###

cat("dualBars10/JH-8A-M1_S9_L001.dualBars10.data\n");
A8a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-8A-M1_S9_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-8A-M2_S10_L001.dualBars10.data\n");
A8b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-8A-M2_S10_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_9A, CH235.12 ###

cat("dualBars10/JH-9A-M1_S11_L001.dualBars10.data\n");
A9a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-9A-M1_S11_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-9A-M2_S12_L001.dualBars10.data\n");
A9b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-9A-M2_S12_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

### JH_10A, CH235.9 ###

cat("dualBars10/JH-10A-M1_S13_L001.dualBars10.data\n");
A10a = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-10A-M1_S13_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

cat("dualBars10/JH-10A-M2_S14_L001.dualBars10.data\n");
A10b = loadFile("/Users/colbyagostino/projects/NNK/dualBars10/JH-10A-M2_S14_L001.dualBars10.data",posBase="",numnt_min=-10,numnt_max=10);

##############################
######## HEAT MAP PLOT #######
##############################

# Compute frequencies and propensities
# PGDM1400.unsort.prop  = heatmapPlotAA.merge.propensity2(Atri,Aunsort,noplot=TRUE,posBase="");
# VRC01mat.unsort.prop  = heatmapPlotAA.merge.propensity2(Avmat,Aunsort,noplot=TRUE,posBase="");
# VRC01min.unsort.prop  = heatmapPlotAA.merge.propensity2(Avmin,Aunsort,noplot=TRUE,posBase="");
# JH_4A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A4a,Aunsort,noplot=TRUE,posBase="");
# JH_4A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A4b,Aunsort,noplot=TRUE,posBase="");
# JH_5A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A5a,Aunsort,noplot=TRUE,posBase="");
# JH_5A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A5b,Aunsort,noplot=TRUE,posBase="");
# JH_6A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A6a,Aunsort,noplot=TRUE,posBase="");
# JH_6A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A6b,Aunsort,noplot=TRUE,posBase="");
# JH_7A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A7a,Aunsort,noplot=TRUE,posBase="");
# JH_7A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A7b,Aunsort,noplot=TRUE,posBase="");
# JH_8A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A8a,Aunsort,noplot=TRUE,posBase="");
# JH_8A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A8b,Aunsort,noplot=TRUE,posBase="");
# JH_9A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A9a,Aunsort,noplot=TRUE,posBase="");
# JH_9A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A9b,Aunsort,noplot=TRUE,posBase="");
# JH_10A_M1.unsort.prop  = heatmapPlotAA.merge.propensity2(A10a,Aunsort,noplot=TRUE,posBase="");
# JH_10A_M2.unsort.prop  = heatmapPlotAA.merge.propensity2(A10b,Aunsort,noplot=TRUE,posBase="");

##############################
###### TABLES + FIGURES ######
##############################

# Create all tables and figures
# createTablesAndFigures(PGDM1400.unsort.prop, "New4_PGDM1400");
# createTablesAndFigures(VRC01mat.unsort.prop, "New4_VRC01mat");
# createTablesAndFigures(VRC01min.unsort.prop, "New4_VRC01min");
# createTablesAndFigures(JH_4A_M1.unsort.prop, "New4_JH_4A_M1");
# createTablesAndFigures(JH_4A_M2.unsort.prop, "New4_JH_4A_M2");
# createTablesAndFigures(JH_5A_M1.unsort.prop, "New4_JH_5A_M1");
# createTablesAndFigures(JH_5A_M2.unsort.prop, "New4_JH_5A_M2");
# createTablesAndFigures(JH_6A_M1.unsort.prop, "New4_JH_6A_M1");
# createTablesAndFigures(JH_6A_M2.unsort.prop, "New4_JH_6A_M2");
# createTablesAndFigures(JH_7A_M1.unsort.prop, "New4_JH_7A_M1");
# createTablesAndFigures(JH_7A_M2.unsort.prop, "New4_JH_7A_M2");
# createTablesAndFigures(JH_8A_M1.unsort.prop, "New4_JH_8A_M1");
# createTablesAndFigures(JH_8A_M2.unsort.prop, "New4_JH_8A_M2");
# createTablesAndFigures(JH_9A_M1.unsort.prop, "New4_JH_9A_M1");
# createTablesAndFigures(JH_9A_M2.unsort.prop, "New4_JH_9A_M2");
# createTablesAndFigures(JH_10A_M1.unsort.prop, "New4_JH_10A_M1");
# createTablesAndFigures(JH_10A_M2.unsort.prop, "New4_JH_10A_M2");

cat("Done Load\n");

# # Get most enriched mutations:
# cat("run2_PGDM1400/PGDM1400_dualBar10c.data\n");
# getMostEnriched(PGDM1400.unsort.prop[[1]],cutoff=0.3);
# cat("run2_VRC01mat/VRC01mat_dualBar10c.data\n");
# getMostEnriched(VRC01mat.unsort.prop[[1]],cutoff=0.3);
# cat("run2_VRC01min/VRC01min_dualBar10c.data\n");
# getMostEnriched(VRC01min.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-4A-M1_S1_L001.dualBars10.data\n");
# getMostEnriched(JH_4A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-4A-M2_S2_L001.dualBars10.data\n");
# getMostEnriched(JH_4A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-5A-M1_S3_L001.dualBars10.data\n");
# getMostEnriched(JH_5A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-5A-M2_S4_L001.dualBars10.data\n");
# getMostEnriched(JH_5A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-6A-M1_S5_L001.dualBars10.data\n");
# getMostEnriched(JH_6A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-6A-M2_S6_L001.dualBars10.data\n");
# getMostEnriched(JH_6A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-7A-M1_S7_L001.dualBars10.data\n");
# getMostEnriched(JH_7A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-7A-M2_S8_L001.dualBars10.data\n");
# getMostEnriched(JH_7A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-8A-M1_S9_L001.dualBars10.data\n");
# getMostEnriched(JH_8A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-8A-M2_S10_L001.dualBars10.data\n");
# getMostEnriched(JH_8A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-9A-M1_S11_L001.dualBars10.data\n");
# getMostEnriched(JH_9A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-9A-M2_S12_L001.dualBars10.data\n");
# getMostEnriched(JH_9A_M2.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-10A-M1_S13_L001.dualBars10.data\n");
# getMostEnriched(JH_10A_M1.unsort.prop[[1]],cutoff=0.3);
# cat("dualBars10/JH-10A-M2_S14_L001.dualBars10.data\n");
# getMostEnriched(JH_10A_M2.unsort.prop[[1]],cutoff=0.3);

# Condense mutations across sorts if you have them
# VCR01 = condenseTables(tables=c("VRC01mat.unsort.prop","VRC01min.unsort.prop","JH_4A_M1.unsort.prop","JH_4A_M2.unsort.prop","JH_5A_M1.unsort.prop","JH_5A_M2.unsort.prop"),minNumTables=3,tables.index=1,lower_cutoff=0);

# Plot AAs as follows:
#plotPieDistributionAA(c("Avmat","Avmin","A4a","A4b","A5a","A5b"),pos=316,landscape=TRUE);
#plotPieDistributionAA(c("A6a","A6b","A7a","A7b","A8a"","A8b","A9a","A9b","A10a"","A10b"),pos=223,landscape=TRUE);

