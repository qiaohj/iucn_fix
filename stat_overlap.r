library("raster")
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

group<-"MAMMALS"
folder<-sprintf("../../Data/IUCN_Distribution_Lines/%s_With_Boundary", group)

files <- list.files(folder, pattern = "\\.rda$")

f<-files[2]
df_result<-data.frame()

for (f in files){
  print(f)

  df<-readRDS(sprintf("%s/%s", folder, f))
  n_all<-nrow(df)
  n_ocean<-nrow(df[which(is.na(df$bio1)),])
  n_continent<-nrow(df[which(!is.na(df$bio1)),])
  n_coastline<-nrow(df[which(!is.na(df$coastline)),])
  
  #remove coastline and ocean
  df<-df[which((!is.na(df$bio1))&(is.na(df$coastline))),]
  
  #overlap with country boundary
  n_country<-nrow(df[which(!is.na(df$country)),])
  n_province<-nrow(df[which(!is.na(df$province)),])
  n_no_coastline<-nrow(df)
  item<-data.frame(species=gsub(".rda", "", f), 
                   n_all=n_all, 
                   n_ocean=n_ocean,
                   n_continent=n_continent,
                   n_coastline=n_coastline,
                   n_no_coastline=n_no_coastline,
                   n_country=n_country, 
                   n_province=n_province)
  if (nrow(df_result)==0){
    df_result<-item
  }else{
    df_result<-rbind(df_result, item)
  }
}
write.table(df_result, sprintf("../../Tables/%s_overlap.csv", group), row.names=F, sep=",")

if (F){
  df_result<-read.table(sprintf("../../Tables/%s_overlap.csv", group), head=T, sep=",", stringsAsFactors = F)
  hist(df_result$n_country/df_result$n)
  hist(df_result$n_province/df_result$n)
}
