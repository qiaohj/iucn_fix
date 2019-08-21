library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
folder<-"../../Data/IUCN_Distribution_Lines/MAMMALS"
target<-"../../Data/IUCN_Distribution_Lines/MAMMALS_With_Boundary"
files <- list.files(folder, pattern = "\\.rda$")
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