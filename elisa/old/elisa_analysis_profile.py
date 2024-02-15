# Script form of ELISA_anlaysis

import pandas as pd
import numpy as np
import sys
sys.path.append('../code')
import serology_analysis_functions as sf
import bokeh
import holoviews as hv
from bokeh.io import export_png
hv.extension('bokeh')
from holoviews import opts
from holoviews.operation import contours
hv.extension('matplotlib')

# CJA: Google Chrome for Testing v114.0.5735.90
# CJA: Niharika's elisa template file

fname='/Users/colbyagostino/Desktop/ELISA/test/2023-12-19-815-2-19.xlsx' # CJA: output from plate reader, fetches data
lname='/Users/colbyagostino/Desktop/ELISA/test/Silent Trimer Antigen Characterization Plans.xlsx' # CJA: elisa template file, fetches antigen labels (requires that all 12 columns have a header)
first_read=pd.ExcelFile(fname)
AUC_plots=hv.Empty()
EC50_plots=hv.Empty()
# CJA: Second arg is sheet in Excel
# vert_labels=pd.read_excel(lname,1,usecols="B:B",skiprows=64,nrows=8) # CJA: antibodies (not used)
horiz_labels_odd=pd.read_excel(lname,1,usecols="C:N",skiprows=13,nrows=1) # CJA: antigen in row 15
horiz_labels_even=pd.read_excel(lname,1,usecols="C:N",skiprows=27,nrows=1) # CJA: antigen in row 29
# CJA: plate names (len(Names) must be equal to len(first_read.sheet_names)), corresponds to file name and title
Names=['TESTING', 'PGT121_2','PGDM1400_1','PGDM1400_2','VRC01_1','VRC01_2','3074_1','3074_2','17B-PDB_1','17B-PDB_2','F105_1','F105_2','39F_1','39F_2','A32_1','A32_2']

for i in range(0,len(first_read.sheet_names)):  
    name=Names[i]
    sname=i
    nrows=17
    df=pd.read_excel(fname,sname,usecols="C:N",skiprows=24,nrows=nrows)
    df=df.reset_index(drop=True)

    if i%2==0:
        labels=horiz_labels_odd
    else:
        labels=horiz_labels_even

    concs=[50.0/(4**i) for i in range(0,7)] # CJA: concs
    concs.append(0)
    df_baseline_correct=pd.DataFrame(df.values[::2] - df.values[1::2])

    dfspk1=df_baseline_correct
    colnames=labels.iloc[0,:].values
    # for i in range(len(colnames)):
    #   colnames[i]=str(colnames[i])+'_'+str(i)
    dfspk1.columns=colnames
    dfspk1.columns.name=''
    dfspk1['conc']=concs
    print(colnames)
    colnames=['conc']+colnames
    # dfspk1=dfspk1[colnames]
    column_to_move = dfspk1.pop('conc')
    dfspk1.insert(0, "conc", column_to_move)
    dfspk1=dfspk1.reset_index(drop=True)
    dfspk1=dfspk1.astype(float)
    dfspk1_avg = pd.DataFrame()
    dfspk1_avg['conc']=concs
    dfspk1_stddev = pd.DataFrame()
    for i in range(1,int((len(dfspk1.columns))-1),2):
        dfspk1_avg[dfspk1.columns[i]] = dfspk1.iloc[:,[i,i+1]].mean(axis=1)
        dfspk1_stddev[dfspk1.columns[i]] = dfspk1.iloc[:,[i,i+1]].std(axis=1)
    
    dfspk1_stddev=list(dfspk1_stddev.T.to_numpy())

    outdf,allprofiles,allfits=sf.fitDF2(dfspk1_avg,3)
    outdf['blank']=dfspk1_avg.iloc[-1,1:]
    print('AUC Plot:')
    AUC=sf.makeHoverAUCPlot(outdf)
    AUC_plots = AUC_plots + AUC
    AUC_plots

    halfcurves=int(len(colnames)/4)
    plot=sf.plotCurves_overlay(allprofiles,allfits,outdf,dfspk1_stddev,dfspk1_avg['conc'].values,name,'WellName',ymax=3,cols=halfcurves,logplot=True) # CJA: adjust ymax based on absorbance range
    EC50_plots= EC50_plots + plot