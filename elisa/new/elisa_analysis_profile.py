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

fname='/Volumes/kulp/Colby/2024-02-07_plateA1B.xlsx' # CJA: output from plate reader, fetches data
lname='/Users/cagostino/Desktop/Desktop/ELISA/2024-02-07/Silent Trimer Antigen Characterization Plans.xlsx' # CJA: elisa template file, fetches antigen labels (requires that all 12 columns have a header)
first_read=pd.ExcelFile(fname)
AUC_plots=hv.Empty()
EC50_plots=hv.Empty()
# CJA: Second arg is sheet in Excel
# vert_labels=pd.read_excel(lname,1,usecols="B:B",skiprows=64,nrows=8) # CJA: antibodies (not used)
horiz_labels_odd=pd.read_excel(lname,1,usecols="C:N",skiprows=13,nrows=1) # CJA: antigen in row 15
horiz_labels_even=pd.read_excel(lname,1,usecols="C:N",skiprows=27,nrows=1) # CJA: antigen in row 29
# CJA: plate names (len(Names) must be equal to len(first_read.sheet_names)), corresponds to file name and title
Names=['PGT151 (anti-his capture)','tj5-5  (anti-his capture)','RM19R  (anti-his capture)']

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

    # outdf['blank']=dfspk1_avg.iloc[-1,1:]
    print('AUC Plot:')
    AUC=sf.makeHoverAUCPlot(outdf)
    AUC_plots = AUC_plots + AUC
    AUC_plots

    halfcurves=int(len(colnames)/4)
    plot=sf.plotCurves_overlay(allprofiles,allfits,outdf,dfspk1_stddev,dfspk1_avg['conc'].values,name,'WellName',ymax=2,cols=halfcurves,logplot=True) # CJA: adjust ymax based on absorbance range
    EC50_plots= EC50_plots + plot

#         conc     NC     PC    ant1  ant1.1    ant2  ant2.2    ant3  ant3.3
# 0  50.000000  2.542  2.821  1.7780  2.6190  2.9475  1.6980  2.4435   2.542
# 1  12.500000  2.935  3.027  1.6155  2.5985  2.9345  1.6040  2.5805   2.935
# 2   3.125000  2.767  2.646  1.6560  2.8635  2.9485  1.6630  2.6290   2.767
# 3   0.781250  2.732  2.551  1.7515  2.7055  2.9520  1.6255  2.6375   2.732
# 4   0.195312  2.645  2.205  1.7455  2.7090  2.8025  1.6340  2.4370   2.645
# 5   0.048828  2.735  1.984  1.7650  2.5460  2.4460  1.3485  2.1525   2.735
# 6   0.012207  2.452  1.276  1.6860  2.4705  1.5490  0.8325  1.3910   2.452
# 7   0.000000  0.014  0.006  0.0035  0.0045  0.0055  0.0035  0.0075   0.014

#         conc      NC    ant1    ant2    ant3    ant4    ant5
# 0  50.000000  2.6815  1.7780  2.6190  2.9475  1.6980  2.4435
# 1  12.500000  2.9810  1.6155  2.5985  2.9345  1.6040  2.5805
# 2   3.125000  2.7065  1.6560  2.8635  2.9485  1.6630  2.6290
# 3   0.781250  2.6415  1.7515  2.7055  2.9520  1.6255  2.6375
# 4   0.195312  2.4250  1.7455  2.7090  2.8025  1.6340  2.4370
# 5   0.048828  2.3595  1.7650  2.5460  2.4460  1.3485  2.1525
# 6   0.012207  1.8640  1.6860  2.4705  1.5490  0.8325  1.3910
# 7   0.000000  0.0100  0.0035  0.0045  0.0055  0.0035  0.0075

# array([0.09050967, 0.06717514, 0.01131371, 0.00212132, 0.00212132,
#        0.0523259 , 0.13859293, 0.00070711]), array([0.09050967, 0.00919239, 0.0516188 , 0.07566043, 0.01555635,
#        0.10889444, 0.14919953, 0.00070711]), array([0.00353553, 0.12232947, 0.0106066 , 0.09475231, 0.01909188,
#        0.0212132 , 0.06929646, 0.00070711]), array([0.06505382, 0.01697056, 0.03394113, 0.01202082, 0.03394113,
#        0.04313351, 0.03323402, 0.00070711]), array([0.16899852, 0.12374369, 0.12869343, 0.01202082, 0.09616652,
#        0.07424621, 0.05798276, 0.00212132])

# array([0.09050967, 0.06717514, 0.01131371, 0.00212132, 0.00212132,
#        0.0523259 , 0.13859293, 0.00070711]), array([0.09050967, 0.00919239, 0.0516188 , 0.07566043, 0.01555635,
#        0.10889444, 0.14919953, 0.00070711]), array([0.00353553, 0.12232947, 0.0106066 , 0.09475231, 0.01909188,
#        0.0212132 , 0.06929646, 0.00070711]), array([0.06505382, 0.01697056, 0.03394113, 0.01202082, 0.03394113,
#        0.04313351, 0.03323402, 0.00070711]), array([0.16899852, 0.12374369, 0.12869343, 0.01202082, 0.09616652,
#        0.07424621, 0.05798276, 0.00212132])]

# 2     ant1         S3  1.644105  0.161219  0.006104   82.114841  163.840000  0.220867  0.206806  0.003278  11.036303  35.392226  0.048089    -6.832511
# 3   ant1.1         S4  2.611018  0.188234  0.006104  130.407319  163.840000  0.336009  0.285518  0.002342  16.776176  30.697575  0.068489   -12.195834
# 4     ant2         S5  2.958023  0.004098  0.010961  147.627964   91.232243  0.024553  0.022849  0.000309   1.227060   2.590657  0.000443 -2553.011617
# 5   ant2.2         S6  1.667095  0.003798  0.012085   83.186989   82.750333  0.050796  0.046298  0.001349   2.538776   9.349155  0.001534  -236.906963
# 6     ant3         S7  2.574397  0.009211  0.010439  128.492125   95.793855  0.071982  0.069935  0.001440   3.601628  12.455775  0.005150  -165.534606

# 1     ant1         S2  1.644105  0.161219  0.006104   82.114841  163.840000  0.205459  0.185576  0.002966  10.259259  34.738637  0.048089    -6.832511
# 2     ant2         S3  2.611018  0.188234  0.006104  130.407319  163.840000  0.295496  0.272227  0.003294  14.772949  34.784861  0.068489   -12.195834
# 3     ant3         S4  2.958023  0.004098  0.010961  147.627964   91.232243  0.025226  0.025251  0.000453   1.262738   3.793215  0.000443 -2553.011617
# 4     ant4         S5  1.667095  0.003798  0.012085   83.186989   82.750333  0.037079  0.032069  0.001010   1.852023   6.439362  0.001534  -236.906963
# 5     ant5         S6  2.574397  0.009211  0.010439  128.492125   95.793855  0.072443  0.062150  0.001118   3.619646  10.097778  0.005150  -165.534606

# array([1.778 , 1.6155, 1.656 , 1.7515, 1.7455, 1.765 , 1.686 , 0.0035]), array([2.619 , 2.5985, 2.8635, 2.7055, 2.709 , 2.546 , 2.4705, 0.0045]), array([2.9475, 2.9345, 2.9485, 2.952 , 2.8025, 2.446 , 1.549 , 0.0055]), array([1.698 , 1.604 , 1.663 , 1.6255, 1.634 , 1.3485, 0.8325, 0.0035]), array([2.4435, 2.5805, 2.629 , 2.6375, 2.437 , 2.1525, 1.391 , 0.0075]), array([2.542, 2.935, 2.767, 2.732, 2.645, 2.735, 2.452, 0.014])]
# array([1.778 , 1.6155, 1.656 , 1.7515, 1.7455, 1.765 , 1.686 , 0.0035]), array([2.619 , 2.5985, 2.8635, 2.7055, 2.709 , 2.546 , 2.4705, 0.0045]), array([2.9475, 2.9345, 2.9485, 2.952 , 2.8025, 2.446 , 1.549 , 0.0055]), array([1.698 , 1.604 , 1.663 , 1.6255, 1.634 , 1.3485, 0.8325, 0.0035]), array([2.4435, 2.5805, 2.629 , 2.6375, 2.437 , 2.1525, 1.391 , 0.0075])]

# array([1.80512346, 1.80452174, 1.80211925, 1.79257913, 1.75550276,
#        1.62264577, 1.25728904, 0.16121884]), array([2.79893331, 2.79797771, 2.79416229, 2.77901155, 2.72013023,
#        2.50913884, 1.92891252, 0.18823355]), array([2.96147316, 2.95952991, 2.95178239, 2.92119426, 2.804937  ,
#        2.41983257, 1.56265221, 0.0040985 ]), array([1.67049017, 1.66928287, 1.66447108, 1.64549881, 1.57375523,
#        1.34015579, 0.8415484 , 0.00379765]), array([2.58307113, 2.58146035, 2.57503734, 2.54966292, 2.45299299,
#        2.1301647 , 1.39689948, 0.0092111 ]), array([2.84458363, 2.84361331, 2.83973911, 2.82435493, 2.76456641,
#        2.55032422, 1.96115821, 0.19366018])]

# array([1.80512346, 1.80452174, 1.80211925, 1.79257913, 1.75550276,
#        1.62264577, 1.25728904, 0.16121884]), array([2.79893331, 2.79797771, 2.79416229, 2.77901155, 2.72013023,
#        2.50913884, 1.92891252, 0.18823355]), array([2.96147316, 2.95952991, 2.95178239, 2.92119426, 2.804937  ,
#        2.41983257, 1.56265221, 0.0040985 ]), array([1.67049017, 1.66928287, 1.66447108, 1.64549881, 1.57375523,
#        1.34015579, 0.8415484 , 0.00379765]), array([2.58307113, 2.58146035, 2.57503734, 2.54966292, 2.45299299,
#        2.1301647 , 1.39689948, 0.0092111 ])]