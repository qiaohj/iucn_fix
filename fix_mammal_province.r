library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
folder<-"../../Data/IUCN_Distribution_Lines/MAMMALS_With_Boundary2"
target<-"../../Data/IUCN_Distribution_Lines/MAMMALS_With_Boundary"
files <- list.files(folder, pattern = "\\.rda$")

province<-raster("../../Raster/province_eck4.tif")

f<-files[1000]
for (f in files){
  print(f)
  if (file.exists(sprintf("%s/%s", target, f))){
    next()
  }
  saveRDS(NA, file=sprintf("%s/%s", target, f))
  df<-readRDS(sprintf("%s/%s", folder, f))
  
  df$province<-extract(province, df[, c("x", "y")])
  
  saveRDS(df, file=sprintf("%s/%s", target, f))
}
