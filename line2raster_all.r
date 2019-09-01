library(raster)
library(rgdal)
library(rgeos)
library(data.table)
library(plyr)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
IUCN_Lists<-c("../../Data/IUCN_Distribution_Lines/Amphibians",
              "../../Data/IUCN_Distribution_Lines/Birds",
              "../../Data/IUCN_Distribution_Lines/MAMMALS",
              "../../Data/IUCN_Distribution_Lines/Odonata",
              "../../Data/IUCN_Distribution_Lines/Reptiles")
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

i=4
args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])



if (T){
  #mask_bak<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  #mask<-mask_bak
  #res(mask)<-c(1000, 1000)
  #mask<-resample(mask_bak, mask)
  #v<-values(mask)
  #v[which(!is.na(v))]<-0
  #values(mask)<-v
  #plot(mask)
  #writeRaster(mask, "../../Raster/mask_1k.tif", overwrite=T)
  #p<-data.table(rasterToPoints(mask_bak))
  #i=1
  #for (i in c(1:length(groups))){
  print(groups[i])
  IUCN_List<-list.files(IUCN_Lists[i])
  j=1
  result<-data.frame()
  for (j in c(1:length(IUCN_List))){
    print(paste(groups[i], j, length(IUCN_List), nrow(result), sep=","))
    df<-readRDS(sprintf("%s/%s", IUCN_Lists[i], IUCN_List[j]))
    df<-data.table(df)
    if (j==1){
      result<-df
    }else{
      l<-list(result, df)
      result<-rbindlist(l)
    }
    l<-NA
    df<-NA
    gc()
  }
  saveRDS(result, sprintf("../../Data/IUCN_Distribution_Lines/%s_all.rda", groups[i]))
  
  count<-count(result, vars=c("x", "y"))
  
  saveRDS(count, sprintf("../../Data/IUCN_Distribution_Lines/%s_count.rda", groups[i]))
  #}
}
print(groups[i])
print("reading rda")
result<-readRDS(sprintf("../../Data/IUCN_Distribution_Lines/%s_all.rda", groups[i]))
print("calculating count")
result$x2<-round(result$x/1000)*1000
result$y2<-round(result$y/1000)*1000

count<-count(result, vars=c("x2", "y2"))


if (F){
  dd<-result[which(abs(result$x-9645568)<500),]
  dd<-dd[which(abs(dd$y-2979654)<500),]
  dd
  t_d<-data.frame(table(dd[, c("x", "y")]))
  
  df_spxx<-readRDS("../../Data/IUCN_Distribution_Lines/MAMMALS/Herpestes_javanicus.rda")
  dim(df_spxx)
  sp_xxx<-SpatialPointsDataFrame(df_spxx[, c("x", "y")], df_spxx, proj4string = crs(mask_bak))
  plot(sp_xxx)
  
  dd<-df_spxx[which(abs(df_spxx$x-9645358)<1),]
  dd<-dd[which(abs(dd$y-2979863)<1),]
  
}

print("saving count")
saveRDS(count, sprintf("../../Data/IUCN_Distribution_Lines/%s_count.rda", groups[i]))
print("projecting to raster")
mask<-raster("../../Raster/mask_1k.tif")
v<-values(mask)
v[cellFromXY(mask, count[, c("x2", "y2")])]<-count$freq
values(mask)<-v
plot(mask)
print("saving raster")
writeRaster(mask, sprintf("../../Raster/density_boundary/%s_density_boundary.tif", groups[i]), overwrite=T)
