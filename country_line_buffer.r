
library(raster)
library(rgdal)
library(rgeos)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

#country with country id
if (F){
  sp_df<-readOGR("../../raw_from_Alice/l", "line") 
  mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
  writeOGR(obj=sp_df_eck4, dsn="../../Shape/polyline", layer="world_line_eck4", driver="ESRI Shapefile")
}

if (F){
  f<-list.files("../../Shape/polyline/country_border_buffer", pattern = "\\.shp$")
  for (item in rev(f)){
    print(item)
    ff<-readOGR("../../Shape/polyline/country_border_buffer", gsub("\\.shp", "", item)) 
  }
}
sp_df_eck4<-readOGR("../../Shape/polyline", "world_line_eck4") 
co<-unique(sp_df_eck4@data$GID_0)[1]
args = commandArgs(trailingOnly=TRUE)
i<-args[1]

for (i in toupper(letters)){
  if (i %in% c("C")){
    #next()
  }
  for (co in rev(unique(sp_df_eck4@data$GID_0))){
    if (!startsWith(co, i)){
      next()
    }
    f<-sp_df_eck4[which(sp_df_eck4@data$GID_0==co),]
    for (buff_d in c(500, 1000, 2500, 5000)){
      print(paste(Sys.time(), co, buff_d))
      if (!(co %in% c("CHL", "CAN"))){
        #next()
      }
      if (file.exists(sprintf("../../Shape/polyline/country_border_buffer/%s_%d.shp", co, buff_d))){
        next()
      }
      dsn<-"../../Shape/polyline/country_border_buffer"
      if (!file.exists(sprintf("../../Shape/polyline/country_border_buffer/%s_%d.shp", co, 0))){
        writeOGR(obj=f, dsn=dsn, layer=sprintf("%s_0", co), driver="ESRI Shapefile")
      }
      
      buff<-buffer(f, buff_d)
      
      #plot(buff)
      #plot(f, col="red", add=T)
      
      x2 <- as(buff, "SpatialPolygonsDataFrame")
      
      writeOGR(obj=x2, dsn=dsn, layer=sprintf("%s_%d", co, buff_d), driver="ESRI Shapefile")
      
      x2<-NA
      buff<-NA
      gc()
    }
  }
}

