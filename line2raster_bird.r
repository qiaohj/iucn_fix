library(raster)
library(rgdal)
library(rgeos)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  
  bird <- sf::st_read(dsn = "/home/huijieqiao/Experiments/IUCN_FIX/raw_from_Alice/IUCN/iucn_species_Ranges/Birds/BOTW.gdb", layer = "All_Species")
  sf::st_write(bird, "../../Shape/iucn_species_Ranges/Birds/BIRD.shp")
  sp_df <- readOGR(dsn="../../Shape/iucn_species_Ranges/Birds", layer="BIRD_eck4") 
  
  sp_lines = as(sp_df, "SpatialLinesDataFrame")
  writeOGR(sp_lines, dsn="../../Shape/polyline/iucn_species_Ranges/Birds", layer=sprintf("%s_line_eck4", "Birds"), overwrite_layer=T, driver="ESRI Shapefile")
 
}
sp_lines<-readOGR("../../Shape/polyline/iucn_species_Ranges/Birds", "Birds_line_eck4") 
mask_bak<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")

unique <- unique(sp_lines@data$SCINAME)
unique<-as.character(unique)



i=1
for (i in 1:length(unique)) {
  
  bi<-unique[i]
  print(paste(i, length(unique), bi))
  target<-sprintf("../../Data/IUCN_Distribution_Lines/Birds/%s.rda", gsub(" ", "_", bi))
  if (file.exists(target)){
    next()
  }
  saveRDS(NA, file=target)
  print(system.time({
    print("extracting the matched polylines")
    tmp <- sp_lines[sp_lines$SCINAME == bi, ] }))
  
  mask<-mask_bak
  print(system.time({
    print("rasterizing to raster")
    mask<-raster(extent(tmp), res=res(mask_bak), crs=crs(mask_bak))
    rp <- rasterize(tmp, mask)}))
  #
  #plot(sp_lines)
  #plot(tmp, add=T)
  #plot(rp)
  print(system.time({
    print("saving result")
    no_na<-!is.na(values(rp))
    n_pixel<-length(values(rp)[no_na])
    if (n_pixel==0){
      mask<-raster(extent(tmp@bbox), res=res(mask_bak), crs=crs(mask_bak))
      rp <- rasterize(tmp@bbox, mask)
      no_na<-!is.na(values(rp))
      n_pixel<-length(values(rp)[no_na])
    }
    if (n_pixel>0){
      values(rp)[no_na]<-1
      ppp<-data.frame(rasterToPoints(rp))
      print(target)
      saveRDS(ppp, target)
      if (F){
        tryCatch({
          print(sprintf("../../Raster/IUCN_Distribution_Lines/Birds/%s.tif", gsub(" ", "_", bi)))
          writeRaster(rp, sprintf("../../Raster/IUCN_Distribution_Lines/Birds/%s.tif", gsub(" ", "_", bi)), overwrite=T)
        }, warning = function(w) {
          print("a warning")
        }, error = function(e) {
          print("an error")
        }, finally = {
          print("a final")
        })
      }
    }
  }))
  rp<-NA
  tmp<-NA
  gc()
}

