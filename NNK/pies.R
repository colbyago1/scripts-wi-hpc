for (i in 1:length(pos1)){
  name=sprintf("NewPie_VRC01class_%03d_M1.pdf", pos1[i]);
  #name=sprintf("NewPie_VRC01class_%03d_M2.pdf", pos1[i]);
  #name=sprintf("NewPie_VH146class_%03d_M1.pdf", pos1[i]);
  #name=sprintf("NewPie_VH146class_%03d_M2.pdf", pos1[i]);
  pdf(name,width=6,height=6);
  a=plotPieDistributionAA.new(c("Aunsort","Avmat","Avmin","A4a","A5a","Atri"),labels=c("Unsorted", "VRC01.mat", "VRC01.min", "12A21_M1", "12A21_min_M1", "PGDM1400"),pos=pos1[i],landscape=TRUE);
  #a=plotPieDistributionAA.new(c("Aunsort","Avmat","Avmin","A4b","A5b","Atri"),labels=c("Unsorted", "VRC01.mat", "VRC01.min", "12A21_M2", "12A21_min_M2", "PGDM1400"),pos=pos1[i],landscape=TRUE);
  #a=plotPieDistributionAA.new(c("Aunsort","A6a","A7a","A8a","A9a","A10a"),labels=c("Unsorted", "1-18_M1", "118_minV1_M1", "118_minV2_M1", "CH235.12_M1", "CH235.9_M1"),pos=pos1[i],landscape=TRUE);
  #a=plotPieDistributionAA.new(c("Aunsort","A6b","A7b","A8b","A9b","A10b"),labels=c("Unsorted", "1-18_M2", "118_minV1_M2", "118_minV2_M2", "CH235.12_M2", "CH235.9_M2"),pos=pos1[i],landscape=TRUE);
  dev.off();
}