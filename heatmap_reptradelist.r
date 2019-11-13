library(raster)
library(rgdal)
library(rgeos)
library(sf)
library(fasterize)
library(gdalUtils)

setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")


if (T){
  species_list<-read.table("../../Tables/reptradelist.csv", head=T, sep=",", stringsAsFactors = F)
  r<-NA
  tag<-NA
  f<-species_list[1, 1]
  i=1
  for (i in c(1:nrow(species_list))){
    f<-species_list[i,]
    print(paste(f, i, nrow(species_list)))
    file<-sprintf("../../Raster/IUCN_Range_By_Species/Reptiles/%s.tif", gsub(" ", "_", f))
    if (!file.exists(file)){
      print(sprintf("Can't find raster for '%s'", f))
      next()
    }
    r1<-raster(file)
    origin(r1)<-c(0, 0)
    if (is.na(tag)){
      r<-r1
      tag<-1
    }else{
      print("merging")
      r<-mosaic(r, r1, fun=sum, filename="")
    }
  }
  target<-"../../Raster/heatmap_IUCN/Special_theme/reptradelist.tif"
  writeRaster(r, target, overwrite=T)
  
}

print(warnings())
