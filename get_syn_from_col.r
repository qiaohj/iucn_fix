library("taxize")

IUCN_Lists<-c("../../Data/IUCN_Distribution_Lines/Amphibians_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Birds_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/MAMMALS_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Reptiles_With_Boundary")

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])

IUCN_List<-list.files(IUCN_Lists[i])
IUCN_List<-gsub(".rda", "", IUCN_List)
IUCN_List<-gsub("_", " ", IUCN_List)

syn<-synonyms(IUCN_List, db="col")    

saveRDS(syn, "../../Data/syn_%s.rda", groups[i])
