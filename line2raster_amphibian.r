library(raster)
library(rgdal)
library(rgeos)
setwd("/Volumes/Disk2/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  sp_df_basic <- readOGR("../../Shape/iucn_species_Ranges/AMPHIBIANS", "AMPHIBIANS") 
  mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  sp_df<-spTransform(sp_df_basic, CRS=crs(mask))
  writeOGR(sp_df, dsn="../../Shape/iucn_species_Ranges/AMPHIBIANS", layer=sprintf("%s_eck4", "AMPHIBIANS"), overwrite_layer=T, driver="ESRI Shapefile")
  
  
  sp_lines = as(sp_df_basic, "SpatialLinesDataFrame")
  writeOGR(sp_lines, dsn="../../Shape/polyline/iucn_species_Ranges/AMPHIBIANS", layer=sprintf("%s_line", "AMPHIBIANS"), overwrite_layer=T, driver="ESRI Shapefile")
  

  sp_lines_eck4<-spTransform(sp_lines, CRS=crs(mask))
  writeOGR(obj=sp_lines_eck4, dsn="../../Shape/polyline/iucn_species_Ranges/AMPHIBIANS", layer="AMPHIBIANS_line_eck4", driver="ESRI Shapefile")
}
sp_df<-readOGR("../../Shape/polyline/iucn_species_Ranges/AMPHIBIANS", "AMPHIBIANS_line_eck4") 
mask_bak<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")

unique <- unique(sp_df@data$binomial)
unique<-as.character(unique)



i=1
for (i in 1:length(unique)) {
  
  bi<-unique[i]
  print(paste(i, length(unique), bi))
  target<-sprintf("../../Data/IUCN_Distribution_Lines/Amphibians/%s.rda", gsub(" ", "_", bi))
  if (file.exists(target)){
    next()
  }
  saveRDS(NA, file=target)
  print(system.time({
    print("extracting the matched polylines")
    tmp <- sp_df[sp_df$binomial == bi, ] }))
  
  mask<-mask_bak
  print(system.time({
    print("rasterizing to raster")
    mask<-raster(extent(tmp), res=res(mask_bak), crs=crs(mask_bak))
    rp <- rasterize(tmp, mask)}))
  #
  #plot(sp_df)
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
          print(sprintf("../../Raster/IUCN_Distribution_Lines/Amphibians/%s.tif", gsub(" ", "_", bi)))
          writeRaster(rp, sprintf("../../Raster/IUCN_Distribution_Lines/Amphibians/%s.tif", gsub(" ", "_", bi)), overwrite=T)
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
