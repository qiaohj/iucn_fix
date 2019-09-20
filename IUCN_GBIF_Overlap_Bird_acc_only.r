library(raster)
library(rgdal)
library(rgeos)
library(plyr)
library(dplyr)


setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")



group<-"Birds"

sp_df<-readOGR("../../Shape/iucn_species_Ranges/Birds", "BIRD_eck4") 
folder<-"../../Data/IUCN_Distribution_Lines/Birds_With_Boundary"
GBIF_Folder<-"../../Data/GBIF_More_Data/Bird"
IUCN_List<-list.files(folder)
realm_ids<-read.table("../../Tables/Realm/Realm_IDs.csv", head=T, sep=",", stringsAsFactors = F)
realms<-read.table("../../Tables/Realm/Bird_realm.csv", head=T, sep=",", stringsAsFactors = F)


for (i in c(1:nrow(realms))){
  print(i)
  item<-realms[i,]
  rrr<-strsplit(item$realm, "\\|")[[1]]
  for (r in rrr){
    if (!(r %in% realm_ids$Realm)){
      print(item)
      print(asdfasdf)
    }
  }
}
f<-"Salamandra_corsica.rda"
result<-data.frame()
i=1
for (i in c(1:length(IUCN_List))){
  print(paste(group, i, length(IUCN_List), sep=","))
  
  f<-IUCN_List[i]
  name<-gsub("\\.rda", "", f)
  name<-gsub("_", " ", name)
  item<-data.frame(group=group, name=name, n=0, n_ocean=0, n_continent=0,
                   n_in=0, n_out=0, n_correct_realm=0,
                   n_incorrect_realm=0, n_in_realm=0, n_out_realm=0)
  
  rda_f<-sprintf("%s/%s", GBIF_Folder, f)
  if (!file.exists(rda_f)){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  df<-readRDS(rda_f)
  
  if (class(df)=="logical"){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  if (nrow(df)==0){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  item$n<-nrow(df)
  item$n_ocean<-nrow(df[which(is.na(df$bio1)),])
  df<-df[which(!is.na(df$bio1)),]
  if (nrow(df)==0){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  item$n_continent<-nrow(df)
  
  
  
  feather<-sp_df[which(sp_df$SCINAME==name),]
  if (length(feather)==0){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  #print(asdfasdf)
  df_remove_dup<-df[, c("lon_eck4", "lat_eck4", "realm")]
  df_remove_dup$lon_eck4<-round(df$lon_eck4/100)*100
  df_remove_dup$lat_eck4<-round(df$lat_eck4/100)*100
  df_remove_dup<-plyr::count(df_remove_dup)
  print(paste(Sys.time(), nrow(df_remove_dup), nrow(df), sep="/"))
  occ<-SpatialPointsDataFrame(df_remove_dup[, c("lon_eck4", "lat_eck4")], df_remove_dup, proj4string = crs(sp_df))
  #occ<-SpatialPointsDataFrame(df[, c("lon_eck4", "lat_eck4")], df, proj4string = crs(sp_df))
  
  over_items<-over(feather, occ, returnList=T)
  
  df_temp<-bind_rows(over_items, .id = "column_label")
  
  df_temp<-unique(df_temp[, c("lon_eck4", "lat_eck4", "freq", "realm")])
  
  item$n_in<-sum(df_temp$freq)
  
  item$n_out<-item$n_continent - item$n_in
  
  
  realm<-realms[which(realms$scientificName==name),]
  if (nrow(realm)==0){
    item$n_correct_realm<-0
    item$n_incorrect_realm<-item$n-item$n_correct_realm
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  realm<-strsplit(realm$realm, "\\|")[[1]]
  
  realm_id<-realm_ids[which(realm_ids$Realm %in% realm), "Realm_ID"]
  
  item$n_incorrect_realm<-nrow(df[which(!(df$realm %in% realm_id)),])
  item$n_correct_realm<-nrow(df[which(df$realm %in% realm_id),])
  
  item$n_in_realm<-sum(df_temp[which(df_temp$realm %in% realm_id), "freq"])
  item$n_out_realm<-item$n_correct_realm - item$n_in_realm
  
  #over_items_sp<-SpatialPointsDataFrame(over_items[[1]][, c("lon_eck4", "lat_eck4")], over_items[[1]], proj4string = crs(sp_df))
  #writeOGR(occ, "~/temp/", "occ", driver="ESRI Shapefile")
  #writeOGR(feather, "~/temp/", "feather", driver="ESRI Shapefile")
  #writeOGR(over_items_sp, "~/temp/", "over_items_sp", driver="ESRI Shapefile")
  
  if (nrow(result)==0){
    result<-item
  }else{
    result<-rbind(result, item)
  }
  
}

write.table(result, sprintf("../../Tables/realm_GBIF_OBIS_Overlap_acc_only/%s.csv", group), row.names = F, sep=",")
