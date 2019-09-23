library(raster)
library(rgdal)
library(rgeos)
library(dplyr)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  o<-readOGR("../../raw_from_Alice/nbuffers", "TM_WORLD_BL_Dissolve_B2500")
  mask<-raster("../../Raster/mask_1k.tif")
  sp_df_eck4<-spTransform(o, CRS=crs(mask))
  writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="TM_WORLD_BL_Dissolve_B2500_eck4", driver="ESRI Shapefile")
  
  o<-readOGR("../../raw_from_Alice/nbuffers", "TM_WORLD_BL_Dissolve_B5000")
  mask<-raster("../../Raster/mask_1k.tif")
  sp_df_eck4<-spTransform(o, CRS=crs(mask))
  writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="TM_WORLD_BL_Dissolve_B5000_eck4", driver="ESRI Shapefile")
  
}
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
if (F){
  args = commandArgs(trailingOnly=TRUE)
  i<-as.numeric(args[1])
  
  
  group<-groups[1]
  buffer<-"2500"
  for (buffer in c("2500", "5000")){
    country<-readOGR("../../Shape/polygon", sprintf("TM_WORLD_BL_Dissolve_B%s_eck4", buffer))
    coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
    t<-"top2"
    for (group in groups[i]){
      
      for (t in c("top2", "top3")){
        r<-raster(sprintf("../../Raster/Quantiles/%s_%s.tif", group, t))
        p<-data.frame(rasterToPoints(r))
        
        p$coastline<-extract(coastline, p[, c("x", "y")])
        
        occ<-SpatialPointsDataFrame(p[, c("x", "y")], p, proj4string = crs(country))
        
        
        co<-"US"
        for (co in unique(country@data$TM_WORLD_1)){
          print(paste(buffer, group, t, co))
          ft<-sprintf("../../Data/quantile_country_overlap/%s/%s/%s/%s.rda", buffer, group, t, co)
          if (file.exists(ft)){
            next()
          }
          dir.create(sprintf("../../Data/quantile_country_overlap/%s", buffer), showWarnings = F)
          dir.create(sprintf("../../Data/quantile_country_overlap/%s/%s", buffer, group), showWarnings = F)
          dir.create(sprintf("../../Data/quantile_country_overlap/%s/%s/%s", buffer, group, t), showWarnings = F)
          
          saveRDS(NA, ft)
          
          
          
          
          over_items<-over(f, occ, returnList=T)
          
          df_temp<-bind_rows(over_items, .id = "column_label")
          df_temp<-unique(df_temp[, c("x", "y", "coastline")])
          saveRDS(df_temp, sprintf("../../Data/quantile_country_overlap/%s/%s/%s/%s.rda", buffer, group, t, co))
          
        }
      }
    }
  }
}

result<-data.frame()
for (buffer in c("2500", "5000")){
  country<-readOGR("../../Shape/polygon", sprintf("TM_WORLD_BL_Dissolve_B%s_eck4", buffer))
  
  t<-"top2"
  for (group in groups){
    
    for (t in c("top2", "top3")){
      
      
      co<-"US"
      for (co in unique(country@data$TM_WORLD_1)){
        print(paste(buffer, group, t, co))
        ft<-sprintf("../../Data/quantile_country_overlap/%s/%s/%s/%s.rda", buffer, group, t, co)
        df<-readRDS(ft)
        f<-country[which(country@data$TM_WORLD_1==co),]
        item<-data.frame(group=group, country=co, top=t, buffer=buffer, n_overlap_all=nrow(df),
                         n_overlap_without_coalstline=nrow(df[which(!is.na(df$coastline)),]),
                         area_country_boarder=area(f)/1000000)
        if (nrow(result)==0){
          result<-item
        }else{
          result<-rbind(result, item)
        }
       
        
      }
    }
  }
}

write.table(result, "../../Tables/quantile_country_overlap.csv", row.names=F, sep=",")
