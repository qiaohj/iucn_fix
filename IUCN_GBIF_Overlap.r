library(raster)
library(rgdal)
library(rgeos)

setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")



group<-"Odonata"

sp_df<-readOGR("../../Shape/iucn_species_Ranges/Odonata", "Odonata_eck4") 
folder<-"../../Data/merged_gbif_occ/Odonata"
IUCN_List<-list.files(folder)
realm_ids<-read.table("../../Tables/Realm/Realm_IDs.csv", head=T, sep=",", stringsAsFactors = F)
realms<-read.table("../../Tables/Realm/Odonata_realm.csv", head=T, sep=",", stringsAsFactors = F)
realms[which(realms$scientificName=="Salamandra corsica"),]
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
  df<-readRDS(sprintf("%s/%s", folder, f))
  name<-gsub(".rda", "", f)
  name<-gsub("_", " ", name)
  item<-data.frame(group=group, name=name, n=0, n_ocean=0, n_continent=0,
                   n_in=0, n_out=0, n_correct_realm=0,
                   n_incorrect_realm=0, n_in_realm=0, n_out_realm=0)
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
  
  
  
  feather<-sp_df[which(sp_df$BINOMIAL==name),]
  if (length(feather)==0){
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
    next()
  }
  occ<-SpatialPointsDataFrame(df[, c("lon_eck4", "lat_eck4")], df, proj4string = crs(sp_df))
  
  over_items<-over(feather, occ, returnList=T)
  item$n_in<-nrow(over_items[[1]])
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
  
  
  item$n_in_realm<-nrow(over_items[[1]][which(over_items[[1]]$realm %in% realm_id),])
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

write.table(result, sprintf("../../Tables/realm_GBIF_OBIS_Overlap/%s.csv", group), row.names = F, sep=",")
  