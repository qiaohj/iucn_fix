library(raster)
library(rgdal)
library(rgeos)
library(dplyr)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  o<-readOGR("../../raw_from_Alice/l", "world")
  mask<-raster("../../Raster/mask_1k.tif")
  sp_df_eck4<-spTransform(o, CRS=crs(mask))
  writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="world_eck4", driver="ESRI Shapefile")
  
  
}
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
if (F){
  args = commandArgs(trailingOnly=TRUE)
  i<-as.numeric(args[1])
  print("load country polygon")
  country<-readOGR("../../Shape/polygon", "world_eck4")
  print("load coastline boundary")
  coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
  
  group<-groups[1]
  buffer<-"2500"
  t<-"top2"
  for (group in groups[i]){
    for (t in c("top2", "top3")){
      print("load quantile raster")
      r<-raster(sprintf("../../Raster/Quantiles/%s_%s.tif", group, t))
      print("raster to point")
      p<-data.frame(rasterToPoints(r))
      print("extract coastline information")
      p$coastline<-extract(coastline, p[, c("x", "y")])
      print("data.frame to spatial points")
      occ<-SpatialPointsDataFrame(p[, c("x", "y")], p, proj4string = crs(country))
      co<-"CHN"
      co<- unique(country@data$GID_0)[1]
      for (co in unique(country@data$GID_0)){
        print(paste(group, t, co))
        ft<-sprintf("../../Data/quantile_country_buffer_overlap/%s/%s/%s.rda", group, t, co)
        if (file.exists(ft)){
          next()
        }
        dir.create(sprintf("../../Data/quantile_country_buffer_overlap/%s", group), showWarnings = F)
        dir.create(sprintf("../../Data/quantile_country_buffer_overlap/%s/%s", group, t), showWarnings = F)
        
        saveRDS(NA, ft)
        
        country_border<-country[which(country$GID_0==co),]
        occ_in<-over(country_border, occ, returnList=T)
        df_temp<-bind_rows(occ_in, .id = "column_label")
        df_temp<-unique(df_temp[, c("x", "y", "coastline")])
        df_temp<-df_temp[!is.na(df_temp$x),]
        df_temp$label<-paste(df_temp$x, df_temp$y)
        #plot(country_border)
        #points(df_temp$x, df_temp$y, col="red")
        if ((nrow(df_temp)==0)){
          saveRDS(df_temp, ft)
          next()
        }
        for (buffer in c("500", "1000", "2500", "5000")){
          
          print(paste(buffer, group, t, co)) 
          occ_item<-SpatialPointsDataFrame(df_temp[, c("x", "y")], df_temp, proj4string = crs(country))
          f<-readOGR("../../Shape/polyline/country_border_buffer", sprintf("%s_%s", co, buffer))
          
          over_items<-over(f, occ_item, returnList=T)
          
          df_occ_item<-bind_rows(over_items, .id = "column_label")
          df_occ_item<-unique(df_occ_item[, c("x", "y", "coastline")])
          df_occ_item$label<-paste(df_occ_item$x, df_occ_item$y)
          df_temp[, sprintf("buff_%s", buffer)]<-0
          df_temp[which(df_temp$label %in% df_occ_item$label), sprintf("buff_%s", buffer)]<-1
          
          
        }
        saveRDS(df_temp, ft)
      }
    }
  }
}

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
if (T){
  
  print("load country polygon")
  country<-readOGR("../../Shape/polygon", "world_eck4")
  
  group<-groups[1]
  buffer<-"2500"
  t<-"top2"
  result<-data.frame()
  for (group in groups){
    for (t in c("top2", "top3")){
      
      co<-"CHN"
      co<- unique(country@data$GID_0)[1]
      for (co in unique(country@data$GID_0)){

        print(paste(group, t, co))
        ft<-sprintf("../../Data/quantile_country_buffer_overlap/%s/%s/%s.rda", group, t, co)
        df<-readRDS(ft)
        all<-nrow(df)
        df_without_coastline<-df[which(is.na(df$coastline)),]
        all_without_coastline<-nrow(df_without_coastline)
        item_b<-data.frame(group=group, co=co, t=t, all=all, all_without_coastline=all_without_coastline)
        for (buffer in c("500", "1000", "2500", "5000")){
          item<-item_b
          item$buff<-buffer
          if (nrow(df)==0){
            item$all_in_buff<-0
            item$all_out_buff<-0
            item$all_in_buff_without_coastline<-0
            item$all_out_buff_without_coastline<-0
            
          }else{
            item$all_in_buff<-nrow(df[which(df[, sprintf("buff_%s", buffer)]==1),])
            item$all_out_buff<-nrow(df[which(df[, sprintf("buff_%s", buffer)]==0),])
            item$all_in_buff_without_coastline<-nrow(df_without_coastline[which(df_without_coastline[, sprintf("buff_%s", buffer)]==1),])
            item$all_out_buff_without_coastline<-nrow(df_without_coastline[which(df_without_coastline[, sprintf("buff_%s", buffer)]==0),])
            
          }
          if (nrow(result)==0){
            result<-item
          }else{
            result<-rbind(result, item)
          }
        }
        
      }
    }
  }
  write.table(result, "../../Tables/quantile_country_buffer_overlap.csv", row.names=F, sep=",")
}


if (F){
  col<-c("black", "red", "green", "blue", "purple", "pink")
  group<-"Amphibians"
  
  co<-"ARG"
  t<-"top2"
  buffer<-"500"
  ft<-sprintf("../../Data/quantile_country_buffer_overlap/%s/%s/%s.rda", group, t, co)
  df<-readRDS(ft)
  country_border<-readOGR
  occ<-SpatialPointsDataFrame(df[, c("x", "y")], df, proj4string = crs(country))
  writeOGR(occ, "../../Shape/test", "Amphibians_ARG_top2_all", driver="ESRI Shapefile")
  for (buffer in c("500", "1000", "2500", "5000")){
    country<-readOGR("../../Shape/polyline/country_border_buffer", sprintf("%s_%s", co, buffer))
    occ_in<-over(country, occ, returnList=T)
    df_occ_item<-bind_rows(occ_in, .id = "column_label")
    df_occ_item<-unique(df_occ_item[, c("x", "y", "coastline")])
    occ_in<-SpatialPointsDataFrame(df_occ_item[, c("x", "y")], df_occ_item, proj4string = crs(country))
    writeOGR(occ_in, "../../Shape/test", sprintf("%s_%s_%s_%s", group, co, t, buffer), driver="ESRI Shapefile")
    
  }
    
}