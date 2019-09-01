library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
folder<-"../../Data/IUCN_Distribution_Lines/Odonata"
target<-"../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary"
files <- list.files(folder, pattern = "\\.rda$")
country<-raster("../../Raster/country_boundaries_eck4.tif")
coastline<-raster("../../Raster/coastal_boundaries_eck4.tif")
province<-raster("../../Raster/province_eck4.tif")
bio1<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
realm<-raster("../../Raster/Biogeographic_realms_clip_eck4.tif")
f<-files[1]
i=1
for (i in c(1:length(files))){
  f<-files[i]
  print(paste(f, i, length(files), sep="/"))
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  df$country<-extract(country, df[, c("x", "y")])
  df$coastline<-extract(coastline, df[, c("x", "y")])
  df$province<-extract(province, df[, c("x", "y")])
  df$bio1<-extract(bio1, df[, c("x", "y")])
  df$realm<-extract(realm, df[, c("x", "y")])
  saveRDS(df, file=sprintf("%s/%s", target, f))
  gc()
}
