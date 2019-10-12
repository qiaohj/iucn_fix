library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])
group<-groups[i]
if (T){
  bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  density_map<-raster(sprintf("../../Raster/density_boundary/%s_density_boundary.tif", group))
  v<-values(density_map)
  print(length(v[which(!is.na(v))]))
  v[which(v==0)]<-NA
  print(length(v[which(!is.na(v))]))
  values(density_map)<-v
  p<-data.frame(rasterToPoints(density_map))
  print(nrow(p))
  buff<-500
  p[, "bio1"]<-extract(bio1, p[, c("x", "y")])
  p<-p[which(!is.na(p$bio1)),]
  print(nrow(p))
  for (buff in c(500, 1000, 2500, 5000)){
    print(buff)
    buff_r<-raster(sprintf("../../Raster/country_border_buffer/buff_%d.tif", buff))
    p[, sprintf("buff_%d", buff)]<-extract(buff_r, p[, c("x", "y")])
  }
  saveRDS(p, sprintf("../../Data/Density_Overlap_Border/%s.rda", group))
}

if (F){
  source("functions.r")
  buff<-500
  result<-data.frame()
  groups<-c("Amphibians", "Mammals", "Odonata", "Reptiles")
  
  
  for (group in groups){
    df<-readRDS(sprintf("../../Data/Density_Overlap_Border/%s.rda", group))
    
    
    for (buff in c(500, 1000, 2500, 5000)){
      print(paste(buff, group))
      
      df[which(is.na(df[, sprintf("buff_%d", buff)])), sprintf("buff_%d", buff)]<-0
      
      se<-summarySE(df[which(!is.na(df[, sprintf("buff_%d", buff)])),], colnames(df)[3],
                    sprintf("buff_%d", buff))
      colnames(se)[1]<-"in_out"
      se$buff<-buff
      se$group<-group
      if (nrow(result)==0){
        result<-se
      }else{
        result<-rbind(result, se)
      }
    }
  }
  write.table(result, "../../Tables/density_overlap_border.csv", row.names=F, sep=",")
  
  library(ggplot2)
  
  ggplot(result, aes(x=factor(buff), y=mean))+geom_point(aes(x=factor(buff), y=mean, shape=factor(in_out), color=factor(group)))+
    
    geom_errorbar(aes(ymin=mean-ci, ymax=mean+ci), width=.2,
                  position=position_dodge(.9)) 
}