library(raster)
library(rgdal)
library(rgeos)
require(geosphere)

setwd("/Volumes/Disk2/Experiments/IUCN_FIX/Script/iucn_fix")

polygon_distribution<-c("../../Shape/iucn_species_Ranges/AMPHIBIANS",
                        "../../Shape/iucn_species_Ranges/Birds",
                        "../../Shape/iucn_species_Ranges/MAMMALS1",
                        "../../Shape/iucn_species_Ranges/Odonata",
                        "../../Shape/iucn_species_Ranges/Reptiles")
layers_distribution<-c("AMPHIBIANS", "All_Species", "MAMMALS", "data_0", "modeled_reptiles")
sp_labels<-c("binomial", "SCINAME", "binomial", "BINOMIAL", "Binomial")
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])
#i=1

realm<-readOGR("../../raw_from_Alice/IUCN", "Biogeographic_realms_clip")


sp_df_basic <- readOGR(polygon_distribution[i], layers_distribution[i]) 

all_species<-unique(sp_df_basic@data[, sp_labels[i]])
j=1
dir.create(sprintf("../../Data/IUCN_Realm_Polygon/Temp_Tables/%s", groups[i]), showWarnings = F)
for (j in c(length(all_species):1)){
  print(paste(groups[i], j, length(all_species), sep=","))
  
  f<-sprintf("../../Data/IUCN_Realm_Polygon/Temp_Tables/%s/%s.rda", groups[i], gsub(" ", "_", all_species[j]))
  if (file.exists(f)){
    next()
  }
  saveRDS(NA, f)
  
  sp_polygon<-sp_df_basic[which(sp_df_basic@data[, sp_labels[i]]==all_species[j]),]
  realm_i = realm@data$REALM[1]
  items_all<-data.frame()
  for (realm_i in unique(realm@data$REALM)){
    realm_f<-realm[which(realm@data$REALM==realm_i),]
    
    tryCatch(
      {
        overlap<-gIntersection(sp_polygon, realm_f)
      },
      error=function(cond) {
        print("Error")
      },
      warning=function(cond) {
        print("Warning")
        warnings()
      },
      finally={
        print("Finally Done!")
      }
    )
    if (is.null(overlap)){
      item<-data.frame(realm=realm_i, area=NA, group=groups[i], sciname=all_species[j])
    }else{
      item<-data.frame(realm=realm_i, area=area(overlap), group=groups[i], sciname=all_species[j])
    }
    
    if (nrow(items_all)==0){
      items_all<-item
    }else{
      items_all<-rbind(items_all, item)
    }
  }
  saveRDS(items_all, f)
}
