library("raster")
df<-readRDS("/Volumes/Disk2/Experiments/Huijie/Data/occ_without_NA_coordinate/GBIF/Aves.RData")
colnames(df)[4]<-'order'
df<-df[which((!is.na(df$decimalLongitude))&(!is.na(df$decimalLatitude))),]
head(df[which(is.na(df$decimalLongitude)),])


species<-unique(df$species)
length(species)
sp<-species[1]
for (sp in species){
  print(sp)
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

