library("raster")
library("rgdal")

setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
if (F){
  sp_df_basic <- readOGR("../../raw_from_Alice/unbuff_polygon", "basin_edge1") 
  mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  sp_df<-spTransform(sp_df_basic, CRS=crs(mask))
  writeOGR(sp_df, dsn="../../Shape/Odonata_basin_overlap", layer=sprintf("%s_eck4", "Odonata_basin_overlap"), overwrite_layer=T, driver="ESRI Shapefile")
  
  extent(mask)<-extent(sp_df)
  rp <- rasterize(sp_df, mask)
  writeRaster(rp, "../../Raster/Odonata_basin_overlap_eck4.tif", overwrite=T)
  
}

if (F){
  folder<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary_old"
  target<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary"
  files <- list.files(folder, pattern = "\\.rda$")
  
  od_boundary<-raster("../../Raster/od_boundary_eck4.tif")
  od_boundary_buffer<-raster("../../Raster/od_boundary_buffer_eck4.tif")
  
  
  f<-files[1000]
  
  for (i in c(1:length(files))){
    f<-files[i]
    print(paste(i, length(files), f, "IUCN", sep=" / "))
    if (file.exists(sprintf("%s/%s", target, f))){
      next()
    }
    saveRDS(NA, file=sprintf("%s/%s", target, f))
    df<-readRDS(sprintf("%s/%s", folder, f))
    
    df$od_boundary<-extract(od_boundary, df[, c("x", "y")])
    df$od_boundary_buffer<-extract(od_boundary_buffer, df[, c("x", "y")])
    
    saveRDS(df, file=sprintf("%s/%s", target, f))
  }
  
  
  folder<-"../../Data/GBIF_More_Data/Odonata_old"
  target<-"../../Data/GBIF_More_Data/Odonata"
  files <- list.files(folder, pattern = "\\.rda$")
  
  
  i=1
  for (i in c(1:length(files))){
    f<-files[i]
    print(paste(i, length(files), f, "GBIF", sep=" / "))
    if (file.exists(sprintf("%s/%s", target, f))){
      next()
    }
    saveRDS(NA, file=sprintf("%s/%s", target, f))
    df<-readRDS(sprintf("%s/%s", folder, f))
    
    df$od_boundary<-extract(od_boundary, df[, c("lon_eck4", "lat_eck4")])
    df$od_boundary_buffer<-extract(od_boundary_buffer, df[, c("lon_eck4", "lat_eck4")])
    
    saveRDS(df, file=sprintf("%s/%s", target, f))
  }
  
}

iucn_folder<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary"
gbif_folder<-"../../Data/GBIF_More_Data/Odonata"
files <- list.files(iucn_folder, pattern = "\\.rda$")
i=1
result<-data.frame()
for (i in c(1:length(files))){
  f<-files[i]
  print(paste(i, length(files), f, "IUCN", sep=" / "))
  df<-readRDS(sprintf("%s/%s", iucn_folder, f))
  sp<-gsub(".rda", "", gsub("_", " ", f))
  df<-df[which(!is.na(df$bio1)),]
  if (nrow(df)>0){
    iucn<-nrow(df)
    iucn_basin<-nrow(df[which(!is.na(df$od_boundary)),])
    iucn_basin_buffer<-nrow(df[which(!is.na(df$od_boundary_buffer)),])
  }else{
    iucn<-0
    iucn_basin<-0
    iucn_basin_buffer<-0
  }
  
  if (file.exists(sprintf("%s/%s", gbif_folder, f))){
    df_gbif<-readRDS(sprintf("%s/%s", gbif_folder, f))  
    gbif<-nrow(df_gbif)
    gbif_basin<-nrow(df_gbif[which(!is.na(df_gbif$od_boundary)),])
    gbif_basin_buffer<-nrow(df_gbif[which(!is.na(df_gbif$od_boundary_buffer)),])
  }else{
    gbif<-0
    gbif_basin<-0
    gbif_basin_buffer<-0
  }
  item<-data.frame(sciname=sp, 
                   iucn=iucn, iucn_basin=iucn_basin, iucn_basin_buffer=iucn_basin_buffer,
                   gbif=gbif, gbif_basin=gbif_basin, gbif_basin_buffer=gbif_basin_buffer)
  if (nrow(result)==0){
    result<-item
  }else{
    result<-rbind(result, item)
  }
}
write.table(result, "../../Tables/Odonata_basin_overlap.csv", row.names = F, sep=",")
