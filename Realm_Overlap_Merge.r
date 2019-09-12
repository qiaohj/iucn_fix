setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
library(raster)
library(rgdal)
library(rgeos)

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

realm_file<-c("../../Tables/Realm/Amphibians_realm_split.csv",
              "../../Tables/Realm/Bird_realm_split.csv",
              "../../Tables/Realm/Mammals_realm_split.csv",
              "../../Tables/Realm/Odonata_realm_split.csv",
              "../../Tables/Realm/Reptile_realm_split.csv")

polygon_distribution<-c("../../Shape/iucn_species_Ranges/AMPHIBIANS",
                        "../../Shape/iucn_species_Ranges/Birds",
                        "../../Shape/iucn_species_Ranges/MAMMALS1",
                        "../../Shape/iucn_species_Ranges/Odonata",
                        "../../Shape/iucn_species_Ranges/Reptiles")

layers_distribution<-c("AMPHIBIANS", "All_Species", "MAMMALS", "data_0", "modeled_reptiles")
sp_labels<-c("binomial", "SCINAME", "binomial", "BINOMIAL", "Binomial")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])
#i=5

sp_df_basic <- readOGR(polygon_distribution[i], layers_distribution[i]) 

all_species<-unique(sp_df_basic@data[, sp_labels[i]])
j=1


if (F){
  i=5
  realm_iucn<-read.table(gsub("_split", "", realm_file[i]), head=T, sep=",", stringsAsFactors = F)
  realm_iucn_list<-data.frame()
  for (j in c(1:nrow(realm_iucn))){
    print(paste(j, nrow(realm_iucn), sep="/"))
    realm_iucn_item<-realm_iucn[j,]
    realm<-strsplit(realm_iucn_item$realm, "\\|")[[1]]
    for (r in realm){
      item<-data.frame(sciname=realm_iucn_item[1, "scientificName"], realm=r)
      if (nrow(realm_iucn_list)==0){
        realm_iucn_list<-item
      }else{
        realm_iucn_list<-rbind(realm_iucn_list, item)
      }
    }
  }
  realm_iucn_list$realm<-as.character(realm_iucn_list$realm)
  unique(realm_iucn_list$realm)
  write.table(realm_iucn_list, realm_file[i], row.names=F, sep=",")
}

realm_iucn<-read.table(realm_file[i], head=T, sep=",", stringsAsFactors = F)

realm_df_all<-data.frame()
for (j in c(1:length(all_species))){
  print(paste(groups[i], j, length(all_species), sep=","))
  
  f<-sprintf("../../Data/IUCN_Realm_Polygon/Temp_Tables/%s/%s.rda", groups[i], gsub(" ", "_", all_species[j]))
  if (!file.exists(f)){
    next()
  }
  realm_df<-readRDS(f)
  if (class(realm_df)=="logical"){
    realm_df<-data.frame()
  }
  if (nrow(realm_df)!=0){
    realm_df<-realm_df[which(!is.na(realm_df$area)),]
  }
  sp_polygon<-sp_df_basic[which(sp_df_basic@data[, sp_labels[i]]==all_species[j]),]
  realm_area<-sum(area(sp_polygon))
  realm_iucn_item<-realm_iucn[which(realm_iucn$sciname==all_species[j]),]
  
  
  if (nrow(realm_df)==0){
    realm_df<-realm_iucn_item
    if (nrow(realm_iucn_item)==0){
      realm_df<-data.frame(realm="ERROR", area=realm_area, group=groups[i], sciname=all_species[j])
    }else{
      realm_df$area<--1
      realm_df$group<-groups[i]
      realm_df<-realm_df[, c("realm", "area", "group", "sciname")]
    }
    
  }else{
    realm_df$realm<-as.character(realm_df$realm)
    realm_df[which(realm_df$realm=="Indo-Malay"), "realm"]<-"Indomalayan"
    realm_df[which(realm_df$realm=="Oceanic"), "realm"]<-"Oceanian"
  }
  
  if (nrow(realm_iucn_item)!=0){
    realm_df<-merge(realm_df, realm_iucn_item, by=c("sciname", "realm"), all=T)
  }
  realm_df$all_area<-realm_area
  if (nrow(realm_df_all)==0){
    realm_df_all<-realm_df
  }else{
    realm_df_all<-rbind(realm_df_all, realm_df)
  }
}
write.table(realm_df_all, sprintf("../../Tables/Realm/Merged_Realm/%s.csv", groups[i]), row.names=F, sep=",")

