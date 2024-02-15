# Scripts for plotting protein conjugate SECMALS data


    
plotSECMALS <- function(file.raw,file.masses,timestart=13.25, timeend=13.95,peakstart=22,peakend=28,ystart=0,yend=3000000){
  data.raw    = read.csv(file.raw,header=T,sep=",",fileEncoding="latin1");
  data.masses = read.csv(file.masses,header=T,sep=",",fileEncoding="latin1");

  data.masses2 = subset(data.masses, data.masses$time..min > peakstart & data.masses$time..min < peakend);

  
  plot(data.raw$time..min.,data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1,type='l',col='red',lwd=2,xlim=c(timestart,timeend),ylab="",xlab="Time (min)",yaxt='n');mtext("UV Absorbance @ 280nm (arbitrary units)",side=2,line=1); par(new=T,mar=c(5,5,5,5));plot(data.masses2$time..min,data.masses2$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol.,xlim=c(timestart,timeend),axes=FALSE,ylim=c(ystart,yend),col='black',type='l',lty=1,lwd=2,ylab="",xlab="");axis(4,at=pretty(range(ystart,yend)),ylim=c(ystart,yend));mtext("Protein Molecular Mass (g/mol)",side=4,line=2.25);
  #dev.off();
}


plotSECMALS.multi.gg <- function(files.raw,files.masses,timestart=13.25, timeend=13.95,peakstart=22,peakend=28,ystart=0,yend=3000000){
library(scales);
    data.merge = plotSECMALS.gg(files.raw[1],files.masses[1],noplot=TRUE,timestart=timestart,timeend=timeend,peakstart=peakstart,peakend=peakend,autopeak=0.20,firsty=TRUE);
    p = ggplot(data.merge, aes(x=time..min.)) + geom_line(aes(y=raw.UV.absorbance.data..detector.voltage...V..channel.1,colour="UV"),size=1,color="red")+geom_line(aes(y=Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol./conversion, colour="Mass"),size=1,color="black");

    uv.max = summary(data.merge$raw.UV.absorbance.data..detector.voltage...V..channel.1)[6];
    mass.max = summary(data.merge$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol.)[6];
    extra_y_axis_buffer=100000; # automatically getting this from conversion factor would be better
    cat(sprintf("LOOP\n"));
    colors=colorRampPalette(c("blue", "orange"))(length(files.raw)); 
    for (i in seq(2,length(files.raw))){
        data.tmp = plotSECMALS.gg(files.raw[i],files.masses[i],noplot=TRUE,timestart=timestart,timeend=timeend,peakstart=peakstart,peakend=peakend,autopeak=0.25,firsty=TRUE);
        uv.max.tmp = summary(data.tmp$raw.UV.absorbance.data..detector.voltage...V..channel.1)[6];
        mass.max.tmp = summary(data.tmp$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol.)[6];
        if (uv.max.tmp > uv.max) uv.max = uv.max.tmp;
        if (mass.max.tmp > mass.max) mass.max = mass.max.tmp;

        p=p+geom_line(data=data.tmp,aes(y=raw.UV.absorbance.data..detector.voltage...V..channel.1,colour="UV"),size=1,color=colors[i])+geom_line(data=data.tmp,aes(y=Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol./conversion, colour="Mass"),size=1,color="black");
    }
    cat(sprintf("P1\n"));
    conversion = mass.max/uv.max+extra_y_axis_buffer;
    p=p+scale_y_continuous(sec.axis=sec_axis(~.*conversion+extra_y_axis_buffer))+theme_classic();
    return(p);
}

# Auto peak detection for secmals. find max UV, then +/- 1.5ml
plotSECMALS.gg <- function(file.raw,file.masses,timestart=13.4147825, timeend=13.95,peakstart=22,peakend=28,autopeak=FALSE,ystart=0,yend=3000000,noplot=FALSE,firsty=FALSE,debug=FALSE){
  library(ggplot2);
  data.raw    = read.csv(file.raw,header=T,sep=",",fileEncoding="latin1");
  data.masses = read.csv(file.masses,header=T,sep=",",fileEncoding="latin1");
  cat(sprintf("HERE\n"));


  
  #data.masses2 = subset(data.masses, data.masses$time..min > peakstart & data.masses$time..min < peakend);
  data.masses2 = data.masses;
  if (autopeak){
      cat(sprintf("NO!\n"));
      max.UV.time = data.raw[which.max(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1),]$time..min;
      peakstart = max.UV.time - autopeak;
      peakend   = max.UV.time + autopeak;
      cat(sprintf("autopeak peakstart: %8.3f\n",peakstart));
      cat(sprintf("autopeak peakend: %8.3f\n",peakend));
  }
  cat(sprintf("YES\n"));
  data.masses2[data.masses2$time..min < peakstart | data.masses2$time..min > peakend,]$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol. = NA;
  # Normalize first y axis from 0 to 1
  if (firsty){
      min=min(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1,na.rm=TRUE);
      max=max(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1,na.rm=TRUE);
      cat(sprintf("Min: %8.3f, Max: %8.3f\n",min,max));
      data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1 = (data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1 - min) / (max-min);
      cat(summary(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1));
  }
  data.merge1 = merge(data.raw,data.masses2,by="time..min.");
  data.merge = subset(data.merge1, data.merge1$time..min > timestart & data.merge1$time..min < timeend);
  if (debug){
      return(data.merge);
  }
  cat(sprintf("LENGTH %d\n",length(data.merge$time..min)));
  uv.max = summary(data.merge$raw.UV.absorbance.data..detector.voltage...V..channel.1)[6];
  mass.max = summary(data.merge$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol.)[6];
  extra_y_axis_buffer=4000000; # automatically getting this from conversion factor would be better
  cat("HERE2: ");
  conversion = mass.max/uv.max+extra_y_axis_buffer;
  cat("HERE2\n");
  if (!noplot){
      ggplot(data.merge, aes(x=time..min.)) + geom_line(aes(y=raw.UV.absorbance.data..detector.voltage...V..channel.1,colour="UV"),size=1,color="red")+geom_line(aes(y=Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol./conversion, colour="Mass"),size=1,color="black")+scale_y_continuous(sec.axis=sec_axis(~.*conversion+extra_y_axis_buffer))+theme_classic();
  } else {
      return(data.merge);
  }
#  ggplot(data.merge, aes(x=time..min.)) + geom_line(aes(y=raw.UV.absorbance.data..detector.voltage...V..channel.1,colour="UV"))+geom_line(aes(y=Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol./conversion, colour="Mass"))+theme_classic();

}

plotSECMALS.gg.withTXT <- function(file.raw, file.masses, timestart = 13.4147825, timeend = 13.95, peakstart = 22, peakend = 28, autopeak = FALSE, ystart = 0, yend = 3000000, noplot = FALSE, firsty = FALSE, debug = FALSE, text = NULL) {
  library(ggplot2)
  data.raw <- read.csv(file.raw, header = TRUE, sep = ",", fileEncoding = "latin1")
  data.masses <- read.csv(file.masses, header = TRUE, sep = ",", fileEncoding = "latin1")
  
  data.masses2 <- data.masses
  if (autopeak) {
    max.UV.time <- data.raw[which.max(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1), ]$time..min
    peakstart <- max.UV.time - autopeak
    peakend <- max.UV.time + autopeak
  }
  
  data.masses2[data.masses2$time..min < peakstart | data.masses2$time..min > peakend, ]$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol. <- NA
  
  if (firsty) {
    min <- min(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1, na.rm = TRUE)
    max <- max(data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1, na.rm = TRUE)
    data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1 <- (data.raw$raw.UV.absorbance.data..detector.voltage...V..channel.1 - min) / (max - min)
  }
  
  data.merge1 <- merge(data.raw, data.masses2, by = "time..min.")
  data.merge <- subset(data.merge1, data.merge1$time..min > timestart & data.merge1$time..min < timeend)
  
  if (debug) {
    return(data.merge)
  }
  
  uv.max <- summary(data.merge$raw.UV.absorbance.data..detector.voltage...V..channel.1)[6]
  mass.max <- summary(data.merge$Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol.)[6]
  
  extra_y_axis_buffer <- 4000000
  conversion <- mass.max / uv.max + extra_y_axis_buffer
  
  if (!noplot) {
    p <- ggplot(data.merge, aes(x = time..min.)) +
      geom_line(aes(y = raw.UV.absorbance.data..detector.voltage...V..channel.1, colour = "UV"), size = 1, color = "red") +
      geom_line(aes(y = Protein.Molar.Mass..for.Peak.1...Molar.Mass...g.mol. / conversion, colour = "Mass"), size = 1, color = "black") +
      scale_y_continuous(name = "UV Absorbance (mAU)", sec.axis = sec_axis(~ . * conversion + extra_y_axis_buffer, name = "Protein Molar Mass (kDa)")) +
      labs(x = "Time (min)") +  # Corrected x-axis label
      theme_classic()
    
    if (!is.null(text)) {
      p <- p + annotate("text", x = 0, y = 0.1, label = text, hjust = 0, vjust = 0)
    }
    
    p <- p + theme(axis.title.x = element_text(margin = margin(t = 5)),
                   axis.title.y = element_text(margin = margin(r = 10)),
                   axis.title.y.right = element_text(margin = margin(l = 5)))
    
    print(p)
    ggsave("23sept06_50.png", plot = p)
  } else {
    return(data.merge)
  }
}




