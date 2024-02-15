# -*- coding: utf-8 -*-
"""
Created on Tue May 26 15:19:48 2020

@author: jru
"""
import pandas as pd
import numpy as np
import scipy.stats as stats
import math
import linleastsquares as lls
import FitHill
import holoviews as hv
from holoviews import opts
from bokeh.models import HoverTool
from bokeh.io import export_png
import bokeh

from selenium import webdriver
import selenium

# opt = webdriver.ChromeOptions()
# opt.binary_location="/Applications/Google Chrome for Testing.app/Contents/MacOS/"
# chromeDriver = "/chromedriver.exe"
# driver = webdriver.Chrome(chromeDriver, options=opt)

def convertWellFormat(wellnames):
    """
    here we convert data from 'A01' format to 'A1' format
    """
    converted=[]
    for i in range(len(wellnames)):
        wellname=wellnames[i]
        if(wellname[1]=='0'):
            converted.append(wellname[0]+wellname[2])
        else:
            converted.append(wellname)
    return converted

def makeWellNames(nrows,ncols,direction):
    """
    makes an array of well names
    direction 0 means row first, 1 means column first
    """
    if(direction==0):
        wellnames=[getWellName(i+1,j+1) for i in range(nrows) for j in range(ncols)]
    else:
        wellnames=[getWellName(i+1,j+1) for j in range(ncols) for i in range(nrows)]
    return wellnames

def well2rowcol(wellname):
    """
    this function takes a wellname (e.g. A10) and returns row number, col number and well letter
    """
    welllett=wellname[0]
    wellnum=wellname[1:len(wellname)]
    return [(ord(welllett)-64),int(wellnum),welllett]

def getWellName(row,col):
    rowlett=chr(row+64)
    return rowlett+str(col)

def fitDF(ampdf,satval,inc0=True,snames=None):
    """
    this function fits a set of dilution curves to linear function
    the input dataframe should contain an x axis and amplitudes named after their highest conc well
    the 0 value is included if inc0 is true
    """
    xvals=ampdf['conc'].values
    xmult=max(xvals)
    allparams=[]
    wellnames=[]
    allfits=[]
    allprofiles=[]
    if(snames is None):
        snames=['S'+str(i+1) for i in range(len(ampdf.columns)-1)]
    else:
        snames.extend(['pos','neg'])
    #fitclass=lls.linleastsquares(xvals,True)
    for i in range(len(ampdf.columns)-1):
        wellname=ampdf.columns[i+1]
        wellnames.append(wellname)
        curve=ampdf[wellname].values
        if(inc0):
            goodvals=np.where(curve<=satval)
        else:
            goodvals=np.where((curve<=satval) & (xvals>0.0))
        if(len(goodvals[0])==0):
            #here we have no values under threshold
            amp=0.0
            off=0.0
            seamp=0.0
            seoff=0.0
            c2=0.0
            r2=0.0
        else:
            ysub=curve[goodvals[0]]
            xsub=xvals[goodvals[0]]
            #coef,se=fitclass.getfiterrors(curve)
            amp,off,seamp,seoff,c2,r2=lls.getAmpOffsetErrs(xsub,ysub)
        fit=xvals*amp+off
        allfits.append(fit)
        allprofiles.append(curve)
        auc=amp*xmult
        seauc=seamp*xmult
        allparams.append([amp,off,auc,seamp,seoff,seauc,c2,r2])
        print(wellname+','+str([c2,r2])+','+str([amp,off]))
    allparams=np.array(allparams)

    outdf=pd.DataFrame({'WellName':wellnames,'SampleName':snames})
    outdf['Amp']=allparams[:,0]
    outdf['Off']=allparams[:,1]
    outdf['AUC']=allparams[:,2]
    outdf['SEAmp']=allparams[:,3]
    outdf['SEOff']=allparams[:,4]
    outdf['SEauc']=allparams[:,5]
    outdf['c^2']=allparams[:,6]
    outdf['R^2']=allparams[:,7]
    return outdf,allprofiles,allfits

def fitDF2(ampdf,satval,inc0=True,snames=None):
    """
    this function fits a set of dilution curves to hill function
    the input dataframe should contain an x axis and amplitudes named after their highest conc well
    the 0 value is included if inc0 is true
    """
    xvals=ampdf['conc'].values
    xmult=max(xvals)
    allparams=[]
    wellnames=[]
    allfits=[]
    allprofiles=[]
    
    mink=min(xvals[xvals>0.0])/2.0
    print(mink)
    maxk=max(xvals)*5.0
    
    if(snames is None):
        snames=['S'+str(i+1) for i in range(len(ampdf.columns)-1)]
    else:
        snames.extend(['pos','neg'])
    #fitclass=lls.linleastsquares(xvals,True)
    for i in range(len(ampdf.columns)-1):
        wellname=ampdf.columns[i+1]
        wellnames.append(wellname)
        curve=ampdf[wellname].values
        if(inc0):
            goodvals=np.where(curve<=satval)
        else:
            goodvals=np.where((curve<=satval) & (xvals>0.0))
        if(len(goodvals[0])==0):
            #here we have no values under threshold
            amp,off,k,seamp,seoff,sek,c2,r2=0.0
        else:
            ysub=curve[goodvals[0]]
            xsub=xvals[goodvals[0]]
            #coef,se=fitclass.getfiterrors(curve)
            #amp,off,seamp,seoff,c2,r2=lls.getAmpOffsetErrs(xsub,ysub) 
            params,errs,sampling=FitHill.getSimpleFitErrs(xsub,ysub,mink,maxk,1.0,xmult,ntrials=50)
            off=params[0]
            amp=params[1]
            k=params[2]
            auc=params[6]
            rk=params[7]
            seoff=errs[0]
            seamp=errs[1]
            sek=errs[2]
            seauc=errs[6]
            serk=errs[7]
            c2=params[4]
            r2=params[5]
        fit=FitHill.getHill(xvals,np.array([off,amp,k,1.0]))
        allfits.append(fit)
        allprofiles.append(curve)
        allparams.append([amp,off,k,auc,rk,seamp,seoff,sek,seauc,serk,c2,r2])
        print(wellname+','+str([c2,r2])+','+str([amp,off]))
    allparams=np.array(allparams)

    outdf=pd.DataFrame({'WellName':wellnames,'SampleName':snames})
    outdf['Amp']=allparams[:,0]
    outdf['Off']=allparams[:,1]
    outdf['EC50']=allparams[:,2]
    outdf['AUC']=allparams[:,3]
    outdf['rEC50']=allparams[:,4]
    outdf['SEAmp']=allparams[:,5]
    outdf['SEOff']=allparams[:,6]
    outdf['SEEC50']=allparams[:,7]
    outdf['SEauc']=allparams[:,8]
    outdf['SErEC50']=allparams[:,9]
    outdf['c^2']=allparams[:,10]
    outdf['R^2']=allparams[:,11]
    return outdf,allprofiles,allfits

def makeHoverAUCPlot(allparamsdf,labelname='WellName',plotname='AUC',ploterrname='SEauc'):
    """
    this makes a bar plot of the AUC (area under curve) for the samples
    need to make it so we can change labels and plotted value
    """
    hv.extension('bokeh',width=90)
    aucds=hv.Dataset(allparamsdf,vdims=[labelname,plotname,ploterrname])
    auxlabels=['AUC','Amp','Off','rEC50','SampleName']
    if(labelname!='WellName'):
        auxlabels[auxlabels.index(labelname)]='WellName'
    auxlabels[auxlabels.index(plotname)]='AUC'
    auxlabels[0]=plotname
    bars=hv.Bars(aucds,labelname,auxlabels)
    tooltips=[('WellName','@WellName'),('SampleName','@SampleName'),('Amplitude','@Amp'),('Baseline','@Off'),('AUC','@AUC'),('rEC50','@rEC50')]
    hover=HoverTool(tooltips=tooltips)
    bars.opts(tools=[hover],width=700,height=300,fill_alpha=0.5,xrotation=45)
    errs=hv.ErrorBars(aucds,[labelname],vdims=[plotname,ploterrname,ploterrname])
    return bars*errs

def plotCurves(allprofiles,allfits,allparamsdf,xvals,slabel='SampleName',ymax=3,cols=7,logplot=True):
    """
    this creates a multiplot panel with dilution profiles and fits
    """
    def curveGen(xvals,yvals1,yvals2,label):
        pts=hv.Scatter((xvals,yvals1),'conc','Absorbance')
        curve2=hv.Curve((xvals,yvals2),'conc','Absorbance')
        if(logplot):
            return (pts*curve2).opts(width=200,height=200,logx=True,logy=True,xlim=(0.005,2),ylim=(0.03,ymax),labelled=[],title=label)
        else:
            return (pts*curve2).opts(width=200,height=200,logx=False,logy=False,xlim=(-0.1,1.1),ylim=(0.0,ymax),labelled=[],title=label)

    r2vals=allparamsdf['R^2'].values
    snames=allparamsdf[slabel].values
    curve_dict={(col):curveGen(xvals,allprofiles[col-1],allfits[col-1],snames[col-1]+',R^2={:0.2f}'.format(r2vals[col-1])) for col in range(1,cols*2+1)}
    kdims = [hv.Dimension('col')]
    holomap = hv.HoloMap(curve_dict, kdims=kdims)
    print('plots are absorbance (y) vs. concentration (x)')
    #holomap
    return hv.NdLayout(holomap).cols(cols)


def plotCurves_overlay(allprofiles,allfits,allparamsdf,allsdsdf,xvals,title,slabel='SampleName',ymax=3,cols=6,logplot=True):
    """
    this creates a multiplot panel with dilution profiles and fits
    """
    def curveGen(xvals,yvals1,yvals2,yvals3,label,marker):
        pts=hv.Scatter((xvals,yvals1),'conc','Absorbance', label=label).opts(marker=marker,size=10)
        curve2=hv.Curve((xvals,yvals2),'conc','Absorbance', label=label)
        errors=list(np.column_stack((xvals,yvals1,yvals3)))
        errorbars=hv.ErrorBars(errors)
        if(logplot):
            return (pts*curve2*errorbars).opts(width=200,height=200,logx=True,logy=True,xlim=(0.005,2),ylim=(0.03,ymax),title=label)
        else:
            return (pts*curve2*errorbars).opts(width=200,height=200,logx=False,logy=False,xlim=(-0.1,1.1),ylim=(0.0,ymax),title=label)



    markers=['circle', 'diamond','triangle','plus','inverted_triangle','star','circle', 'diamond','triangle','plus','inverted_triangle','star']
    r2vals=allparamsdf['R^2'].values
    snames=allparamsdf[slabel].values
    curve_dict={(snames[col-1]):curveGen(xvals,allprofiles[col-1],allfits[col-1],allsdsdf[col-1],snames[col-1],markers[col-1]) for col in range(1,cols*2+1)}
    kdims = [hv.Dimension('Construct')]
    # vdims= [hv.Dimension('name', values=snames)]
    holomap = hv.HoloMap(curve_dict, kdims=kdims)
    print('plots are absorbance (y) vs. concentration (x)')
    #holomap
    plot=hv.NdOverlay(holomap).opts(width=600,height=400,logx=True,logy=False,xlim=(0.01,100),ylim=(0,ymax),xlabel="Concentration (uM)", ylabel="Absorbance 450-570nm",title=title,legend_position="right", fontsize={'title': 16, 'labels': 12, 'xticks': 8, 'yticks': 8},toolbar=None)
    # plot.relabel('Listed ticks (xticks=[0, 1, 2])').opts(xticks=[0, 0.00024414062, 0.0009765625, 0.00390625, 0.015625, 0.0625, 0.25, 1])
    # plot.relabel().opts()
    # plot.xaxis.ticker = [0, 0.00024414062, 0.0009765625, 0.00390625, 0.015625, 0.0625, 0.25, 1]
    # plot.xaxis.major_label_overrides =[(0, "Null"), (0.00024414062, "1:409600"), (0.0009765625, "1:102400"), (0.00390625, "1:25600"), (0.015625, "1:6400"), (0.0625, "1:1600"), (0.25, "1:400"),(1,"1:100")]
    # plot.xaxis.major_label_overrides ={0: "Null", 0.00024414062: "1:409600", 0.0009765625: "1:102400", 0.00390625: "1:25600", 0.015625: "1:6400", 0.0625: "1:1600", 0.25: "1:400", 1: "1:100"}
    

    # # hv.save(plot, filename="PGT121_ELISA_1.png")
    renderer=hv.renderer('bokeh')
    renderer.save(plot, title, fmt='png')
    return plot


# def plotCurves2(allprofiles,allfits,allparamsdf,xvals,slabel='SampleName',ymax=3,cols=7,logplot=True):
#     """
#     this creates a multiplot panel with dilution profiles and fits
#     """
#     def curveGen2(xvals,yvals1,yvals2,label):
#         if(logplot):
#             plot=hv.Curve([]).opts(width=200,height=200,logx=True,logy=False,xlim=(0.005,2),ylim=(0.03,ymax),labelled=[])
#         else:
#             plot=hv.Curve([]).opts(width=200,height=200,logx=False,logy=False,xlim=(-0.1,1.1),ylim=(0.0,ymax),labelled=[])

#         for col in range(1,cols*2+1):
#             plot + hv.Scatter((xvals[col-1],yvals1[col-1]),'conc','Absorbance',legend_label=label[col-1]+',R^2={:0.2f}'.format(r2vals[col-1]))
#             plot + hv.Curve((xvals[col-1],yvals2[col-1]),'conc','Absorbance',title=label[col-1]+',R^2={:0.2f}'.format(r2vals[col-1]))
        
#         return plot

#     r2vals=allparamsdf['R^2'].values
#     snames=allparamsdf[slabel].values
#     curve_dict=curveGen2(xvals,allprofiles,allfits,snames) 
#     # kdims = [hv.Dimension('col')]
#     holomap = curve_dict
#     print('plots are absorbance (y) vs. concentration (x)')
#     #holomap
#     return holomap