library(raster)
library(rgdal)
library(rgeos)
library(sf)
library(fasterize)
library(gdalUtils)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

sp_df_eck4<-readOGR("../../Shape/polyline", "world_line_eck4") 
co<-unique(sp_df_eck4@data$GID_0)[1]
buff<-5000

args = commandArgs(trailingOnly=TRUE)
i<-args[1]
if (F){
  for (co in unique(sp_df_eck4@data$GID_0)){
    if (!startsWith(co, i)){
      next()
    }
    for (buff in c(500, 1000, 2500, 5000)){
      t_f<-sprintf("../../Raster/country_border_buffer/%s_%d.tif", co, buff)
      if (file.exists(t_f)){
        next()
      }
      saveRDS(NA, t_f)
      mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
      print(paste(co, buff, sep="/"))
      co_eck <- st_read("../../Shape/polyline/country_border_buffer", sprintf("%s_%d", co, buff))
      extent(mask)<-extent(co_eck)
      res(mask)<-500
      print(1)
      rp <- fasterize(co_eck, mask)
      print(2)
      writeRaster(rp, t_f, overwrite=T)
    }
  }
}

if (F){
  #merge
 
  buff<-500
  
  for (buff in c(500, 1000, 2500, 5000)){
    
    tamplate<-"/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer_by_country/%s_%d.tif"
    df<-data.frame(a="")
    for (co in unique(sp_df_eck4@data$GID_0)){
      df<-rbind(df, data.frame(a=sprintf(tamplate, co, buff)))
    }
    write.table(df, sprintf("/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer/list_%d.csv", buff),
                row.names=F)
  }
}
buff=500
for (buff in c(500, 1000, 2500, 5000)){
  gdalbuildvrt(input_file_list = sprintf("/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer/list_%d.csv", buff), 
             output.vrt = sprintf("/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer/buff_%d.vrt", buff))

  gdal_translate(src_dataset = sprintf("/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer/buff_%d.vrt", buff), 
                 dst_dataset = sprintf("/home/huijieqiao/Experiments/IUCN_FIX/Raster/country_border_buffer/buff_%d.tif", buff), 
                 output_Raster = TRUE, # returns the raster as Raster*Object
                 # if TRUE, you should consider to assign 
                 # the whole function to an object like dem <- gddal_tr..
                 options = c("BIGTIFF=YES", "COMPRESSION=LZW"))
}
  
  r<-raster("/home/huijieqiao/Experiments/IUCN_FIX/Raster/test/dem.tif")
  