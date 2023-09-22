for (i in 1:length(pos1)){
  name=sprintf("NewPie_VRC01class_%03d_M1.pdf", pos1[i]);
  pdf(name,width=6,height=6);
  a=plotPieDistributionAA.new(c("A_JH_0_M3","A_JH_10A_M3","A_JH_8A_M3","A_JH_9A_M3"),labels=c("Unsorted", "VRC01.mat","9a", "8a"),pos=pos1[i],landscape=TRUE);
  dev.off();
}