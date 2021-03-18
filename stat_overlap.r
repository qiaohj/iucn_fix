library("raster")
setwd("/media/huijieqiao/WD12T/Experiments/IUCN_FIX/Script/iucn_fix")
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])
group<-groups[i]
folder<-sprintf("../../Data/IUCN_Distribution_Lines/%s_With_Boundary", group)

files <- list.files(folder, pattern = "\\.rda$")

f<-files[2]
df_result<-data.frame()
f<-"Acanthaeschna_victoria.rda"
for (f in files){
  print(paste(group, f))

  df<-readRDS(sprintf("%s/%s", folder, f))
  n_all<-nrow(df)
  n_ocean<-nrow(df[which(is.na(df$bio1)),])
  n_continent<-nrow(df[which(!is.na(df$bio1)),])
  n_coastline<-nrow(df[which(!is.na(df$coastline)),])
  
  #remove coastline and ocean
  df<-df[which((!is.na(df$bio1))&(is.na(df$coastline))),]
  
  #overlap with country boundary
  n_country<-nrow(df[which(!is.na(df$country)),])
  n_country_500<-nrow(df[which(!is.na(df$country_500)),])
  n_country_1000<-nrow(df[which(!is.na(df$country_1000)),])
  n_country_2500<-nrow(df[which(!is.na(df$country_2500)),])
  n_country_5000<-nrow(df[which(!is.na(df$country_5000)),])
  
  n_province<-nrow(df[which(!is.na(df$province)),])
  n_no_coastline<-nrow(df)
  item<-data.frame(species=gsub(".rda", "", f), 
                   n_all=n_all, 
                   n_ocean=n_ocean,
                   n_continent=n_continent,
                   n_coastline=n_coastline,
                   n_no_coastline=n_no_coastline,
                   n_country=n_country, 
                   n_country_500=n_country_500, 
                   n_country_1000=n_country_1000, 
                   n_country_2500=n_country_2500, 
                   n_country_5000=n_country_5000, 
                   n_province=n_province)
  if (nrow(df_result)==0){
    df_result<-item
  }else{
    df_result<-rbind(df_result, item)
  }
}
write.table(df_result, sprintf("../../Tables/%s_overlap.csv", group), row.names=F, sep=",")

if (F){
  groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
  group<-groups[5]
  df_result<-read.table(sprintf("../../Tables/%s_overlap.csv", group), head=T, sep=",", stringsAsFactors = F)
  N1<-nrow(df_result[which(df_result$n_country_500>0),])
  N1/nrow(df_result)
  
  N1<-nrow(df_result[which(df_result$n_province>0),])
  N1/nrow(df_result)
  
  sum(df_result$n_country_500)/sum(df_result$n_continent-df_result$n_coastline)
  
  sum(df_result$n_country_500)/sum(df_result$n_no_coastline)
  
  df_result$n_country_500/
  hist(df_result$n_country/df_result$n_all)
  hist(df_result$n_province/df_result$n_all)
}
