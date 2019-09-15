library("raster")
library("rgdal")


if (F){
  sp_df_basic <- readOGR("../../raw_from_Alice/unbuff_polygon", "basin_edge1") 
  mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  sp_df<-spTransform(sp_df_basic, CRS=crs(mask))
  writeOGR(sp_df, dsn="../../Shape/Odonata_basin_overlap", layer=sprintf("%s_eck4", "Odonata_basin_overlap"), overwrite_layer=T, driver="ESRI Shapefile")
  
  extent(mask)<-extent(sp_df)
  rp <- rasterize(sp_df, mask)
  writeRaster(rp, "../../Raster/Odonata_basin_overlap_eck4.tif", overwrite=T)
  
}


folder<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary_old"
target<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary"
files <- list.files(folder, pattern = "\\.rda$")

Odonata_basin_overlap<-raster("../../Raster/Odonata_basin_overlap_eck4.tif")

f<-files[1000]

for (i in c(1:length(files))){
  f<-files[i]
  print(paste(i, length(files), f, "IUCN", sep=" / "))
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  
  df$basin<-extract(Odonata_basin_overlap, df[, c("x", "y")])
  
  saveRDS(df, file=sprintf("%s/%s", target, f))
}


folder<-"../../Data/GBIF_More_Data/Odonata_old"
target<-"../../Data/GBIF_More_Data/Odonata"
files <- list.files(folder, pattern = "\\.rda$")

Odonata_basin_overlap<-raster("../../Raster/Odonata_basin_overlap_eck4.tif")

f<-files[1000]
for (i in c(1:length(files))){
  f<-files[i]
  print(paste(i, length(files), f, "IUCN", sep=" / "))
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  
  df$basin<-extract(Odonata_basin_overlap, df[, c("lon_eck4", "lat_eck4")])
  
  saveRDS(df, file=sprintf("%s/%s", target, f))
}

