# -*- coding: utf-8 -*-
"""
Created on Thu Apr 23 13:38:40 2020

@author: jru
"""

from numba import jit
import numpy as np
import math
import NLLSfit

@jit(nopython=True)
def getAmpOffset(function,data):
    sumx2=np.sum(function*function)
    sumx=np.sum(function)
    sumy=np.sum(data)
    sumxy=np.sum(function*data)
    dlength=float(len(data))
    if(sumx2>0.0):
        divider=dlength*sumx2-sumx*sumx
        off=(sumx2*sumy-sumx*sumxy)/divider
        amp=(dlength*sumxy-sumx*sumy)/divider
    else:
        amp=0.0
        off=sumy/dlength
    return amp,off

@jit(nopython=True)
def getHill(xvals,params):
    return params[0]+params[1]*(xvals**params[3])/(params[2]+(xvals**params[3]))

@jit(nopython=True)
def getAmpOffsetC2(func,data,amp,off):
    resid=amp*func+off-data
    c2=np.sum(resid*resid)
    return c2/float(len(data)-2)

@jit(nopython=True)
def initKd(xvals,data,minkd1,maxkd1,guessn,mult):
    minc2=-1.0
    minkd=minkd1
    minamp=0.0
    minoff=0.0
    kd=minkd
    while(kd<=maxkd1):
        fitfunc=getHill(xvals,np.array([0.0,1.0,kd,guessn]))
        amp,off=getAmpOffset(fitfunc,data)
        c2=getAmpOffsetC2(fitfunc,data,amp,off)
        if(minc2<0.0 or c2<minc2):
            minc2=c2
            minkd=kd
            minamp=amp
            minoff=off
        kd*=mult
    return [minkd,minc2,minamp,minoff]

def runSimpleFit(xvals,data,minkd,maxkd,nval):
    kd,c2,amp,off=initKd(xvals,data,minkd,maxkd,nval,1.05)
    params=np.array([off,amp,kd,nval])
    fit=getHill(xvals,params)
    return 1,c2,params,fit

def getSimpleFitErrs(xvals,data,minkd,maxkd,nval,xmax,ntrials=50):
    sampling=[]
    def aucfunc(amp,kd,xmax):
        return amp*(xmax-kd*math.log(kd+xmax)+kd*math.log(kd))
    
    _,firstc2,firstparams,_=runSimpleFit(xvals,data,minkd,maxkd,nval)
    var=np.var(data)*(len(data)-1)
    c22=firstc2*(len(data)-2)
    firstr2=1.0-var/c22
    auc=aucfunc(firstparams[1],firstparams[2],xmax)
    firstrk=1.0/firstparams[2]
    firstparams=np.append(firstparams,[firstc2,firstr2,auc,firstrk])
    for i in range(ntrials):
        sim=getHill(xvals,firstparams)
        sim+=np.random.normal(0.0,math.sqrt(firstc2),len(sim))
        _,c2,params,fit=runSimpleFit(xvals,sim,minkd,maxkd,nval)
        var=np.var(sim)*(len(sim)-1)
        c22=c2*(len(sim)-2)
        r2=1.0-var/c22
        auc=aucfunc(params[1],params[2],xmax)
        rk=1.0/params[2]
        params=np.append(params,[c2,r2,auc,rk])
        sampling.append(params)
    sampling=np.array(sampling)
    errs=np.std(sampling,axis=0)
    return firstparams,errs,sampling

def runFit(xvals,data,minkd,maxkd,guessn,fampmin,fitn):
    def fitfunc(params):
        return getHill(xvals,params)
       
    guessparams=initKd(xvals,data,minkd,maxkd,guessn)
    fitclass=NLLSfit.NLLSFit(fitfunc)
    if(guessparams[1]<0.0):
        guessparams[1]=max(data)-min(data)
    params=[0.0,guessparams[2],guessparams[0],guessn]
    constraints=[[-0.1*params[1],fampmin*params[1],minkd,0.1],[0.1*params[1],5.0*params[1],maxkd,2.0]]
    fixes=[0,0,0,0]
    if(not fitn): fixes[3]=1
    iterations,c2,params,fit=fitclass.fitData(params,fixes,constraints,data,verbose=False)
    return iterations,c2,params,fit