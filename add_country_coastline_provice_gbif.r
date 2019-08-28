library("raster")
setwd("/Volumes/Disk2/Experiments/IUCN_FIX/Script/iucn_fix")


if (F){
  df<-readRDS("/Volumes/Disk2/Experiments/Huijie/Data/occ_without_NA_coordinate/GBIF/Aves.RData")
  colnames(df)[4]<-'order'
  df<-df[which((!is.na(df$decimalLongitude))&(!is.na(df$decimalLatitude))),]
  head(df[which(is.na(df$decimalLongitude)),])
  points<-SpatialPointsDataFrame(df[, c("decimalLongitude", "decimalLatitude")], df, 
                                 proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  
  points_eck4<-spTransform(points, CRS="+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  df_eck4<-data.frame(points_eck4)
  colnames(df_eck4)[9:10]<-c("lon_eck4", "lat_eck4")
  saveRDS(df_eck4, "Aves_with_eck4.RData")
  
}

df<-readRDS("../../Data/occ_without_NA_coordinate/Reptilia_with_eck4.RData")
country<-raster("../../Raster/country_boundaries_eck4.tif")
coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
province<-raster("../../Raster/province_eck4.tif")
bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
realm<-raster("../../Raster/Biogeographic_realms_clip_eck4.tif")

species<-unique(df$species)
sp<-species[1]

target<-"../../Data/GBIF_More_Data/Reptiles/%s.rda"
i=1
for (i in c(1:length(species))){
  sp<-species[i]
  print(paste(sp, i, length(species), sep="/"))
  
  file<-sprintf(target, gsub(" ", "_", sp))
  if (file.exists(file)){
    next()
  }
  saveRDS(NA, file=file)
  item<-df[which(df$species==sp),]
  item$country<-extract(country, item[, c("lon_eck4", "lat_eck4")])
  item$coastline<-extract(coastline, item[, c("lon_eck4", "lat_eck4")])
  item$province<-extract(province, item[, c("lon_eck4", "lat_eck4")])
  item$bio1<-extract(bio1, item[, c("lon_eck4", "lat_eck4")])
  item$realm<-extract(realm, item[, c("lon_eck4", "lat_eck4")])
  
  saveRDS(item, file=file)
}
