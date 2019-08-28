library("raster")
library("dplyr")

#convert lonlat to eck4 projection.
if (F){
  df<-readRDS("/Volumes/Disk2/Experiments/Huijie/Data/occ_without_NA_coordinate/GBIF/Aves.RData")
  colnames(df)[4]<-'order'
  df<-df[which((!is.na(df$decimalLongitude))&(!is.na(df$decimalLatitude))),]
  df<-df[which(between(df$decimalLongitude, -180, 180)),]
  df<-df[which(between(df$decimalLatitude, -90, 90)),]
  
  head(df[which(is.na(df$decimalLongitude)),])
  
  
  species<-unique(df$species)
  length(species)
  sp<-species[1]
  for (sp in species){
    print(paste(sp, i, length(species), sep="/"))
    file<-sprintf("/Volumes/Disk2/Experiments/Huijie/Data/aves_eck4_species_by_species/%s.rda", gsub(" ", "_", sp))
    if (file.exists(file)){
      next()
    }
    saveRDS(NA, file)
    item<-df[which(df$species==sp),]
    
    
    
    points<-SpatialPointsDataFrame(item[, c("decimalLongitude", "decimalLatitude")], item, 
                                   proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
    
    points_eck4<-spTransform(points, CRS="+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
    df_eck4<-data.frame(points_eck4)
    colnames(df_eck4)[9:10]<-c("lon_eck4", "lat_eck4")
    saveRDS(df_eck4, file)
    item<-NA
    points<-NA
    points_eck4<-NA
    df_eck4<-NA
    gc()
  }
  
}




setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
folder<-"../../Data/occ_without_NA_coordinate/aves_eck4_species_by_species"
target<-"../../Data/GBIF_More_Data/Bird"
files <- list.files(folder, pattern = "\\.rda$")
country<-raster("../../Raster/country_boundaries_eck4.tif")
coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
province<-raster("../../Raster/province_eck4.tif")
bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
realm<-raster("../../Raster/Biogeographic_realms_clip_eck4.tif")

i=1
for (i in c(1:length(files))){
  f<-files[i]
  print(paste(f, i, length(files), sep="/"))
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  df$country<-extract(country, df[, c("lon_eck4", "lat_eck4")])
  df$coastline<-extract(coastline, df[, c("lon_eck4", "lat_eck4")])
  df$province<-extract(province, df[, c("lon_eck4", "lat_eck4")])
  df$bio1<-extract(bio1, df[, c("lon_eck4", "lat_eck4")])
  df$realm<-extract(realm, df[, c("lon_eck4", "lat_eck4")])
  saveRDS(df, file=sprintf("%s/%s", target, f))
  gc()
}
