library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])

folder<-sprintf("../../Data/IUCN_Distribution_Lines/%s_With_Boundary_3", groups[i])
target<-sprintf("../../Data/IUCN_Distribution_Lines/%s_With_Boundary", groups[i])
files <- list.files(folder, pattern = "\\.rda$")
country_500<-raster("../../Raster/country_border_buffer/buff_500.tif")
country_1000<-raster("../../Raster/country_border_buffer/buff_1000.tif")
country_2500<-raster("../../Raster/country_border_buffer/buff_2500.tif")
country_5000<-raster("../../Raster/country_border_buffer/buff_5000.tif")

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
  df$country_500<-extract(country_500, df[, c("x", "y")])
  df$country_1000<-extract(country_1000, df[, c("x", "y")])
  df$country_2500<-extract(country_2500, df[, c("x", "y")])
  df$country_5000<-extract(country_5000, df[, c("x", "y")])
  saveRDS(df, file=sprintf("%s/%s", target, f))
  gc()
}


df<-readRDS("../../Data/IUCN_Distribution_Lines/Amphibians_With_Boundary/Acanthixalus_spinosus.rda")
