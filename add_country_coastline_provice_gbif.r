library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")


if (F){
  df<-readRDS("../../Data/occ_without_NA_coordinate/Aves.RData")
  colnames(df)[4]<-'order'
  df<-df[which((!is.na(df$decimalLongitude))&(!is.na(df$decimalLatitude))),]
  head(df[which(is.na(df$decimalLongitude)),])
  points<-SpatialPointsDataFrame(df[, c("decimalLongitude", "decimalLatitude")], df, 
                                 proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  
  points_eck4<-spTransform(points, CRS="+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  df_eck4<-data.frame(points_eck4)
  colnames(df_eck4)[9:10]<-c("lon_eck4", "lat_eck4")
  saveRDS(df_eck4, "../../Data/occ_without_NA_coordinate/Aves_with_eck4.RData")
  
}
country<-raster("../../Raster/country_boundaries_eck4.tif")
coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
province<-raster("../../Raster/province_b1_eck4.tif")
bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
f<-files[1]
for (f in files){
  print(f)
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  df$country<-extract(country, df[, c("x", "y")])
  df$coastline<-extract(coastline, df[, c("x", "y")])
  df$province<-extract(province, df[, c("x", "y")])
  
  df$bio1<-extract(bio1, df[, c("x", "y")])
  saveRDS(df, file=sprintf("%s/%s", target, f))
}
