setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  df<-read.csv("../../raw_from_Alice/odonata_GBIF/Qiao_Downloaded/0004816-190813142620410.csv", head=T, sep="\t", stringsAsFactors = F, quote = "")
  dim(df)
  head(df)
  
  df<-df[, c("species", "phylum", "class",  "order",  "family", "genus",  "decimalLatitude", "decimalLongitude")]
  df<-df[which((!is.na(df$decimalLatitude))&(!is.na(df$decimalLongitude))),]
  library(dplyr)
  df<-df[which(between(df$decimalLongitude, -180, 180)),]
  df<-df[which(between(df$decimalLatitude, -90, 90)),]
  dim(df)
  points<-SpatialPointsDataFrame(df[, c("decimalLongitude", "decimalLatitude")], df, 
                                 proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  
  points_eck4<-spTransform(points, CRS="+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  df_eck4<-data.frame(points_eck4)
  colnames(df_eck4)[9:10]<-c("lon_eck4", "lat_eck4")
  saveRDS(df_eck4, "../../Data/occ_without_NA_coordinate/Odonata_with_eck4.RData")
}
library("raster")
df_eck4<-readRDS("../../Data/occ_without_NA_coordinate/Odonata_with_eck4.RData")
country<-raster("../../Raster/country_boundaries_eck4.tif")
coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
province<-raster("../../Raster/province_eck4.tif")
bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
realm<-raster("../../Raster/Biogeographic_realms_clip_eck4.tif")
df<-df_eck4
species<-unique(df$species)
sp<-species[1]

target<-"../../Data/GBIF_More_Data/Odonata/%s.rda"
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
