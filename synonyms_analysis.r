setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

get_result<-function(syn_list, name_list, group, name_list1, name_list2){
  if (is.null(dim(syn_list))){
    syn_list<-gsub(".rda", "", syn_list)
    syn_list<-gsub("_", " ", syn_list)
    syn_list<-toupper(syn_list)
    syn_list<-data.frame(a1=syn_list, a2=syn_list)
  }
  colnames(syn_list)<-c("realname", "synonym")
  syn_list$realname<-toupper(trimws(syn_list$realname, which="both"))
  syn_list$synonym<-toupper(trimws(syn_list$synonym, which="both"))
  
  name_list<-gsub(".rda", "", name_list)
  name_list<-gsub("_", " ", name_list)
  name_list<-toupper(name_list)
  
  in_realname<-name_list[which(name_list %in% syn_list$realname)]
  in_synonym<-name_list[which(name_list %in% syn_list$synonym)]
  in_both<- name_list[which((name_list %in% syn_list$synonym)&(name_list %in% syn_list$realname))]
  in_nothing<-name_list[which((!(name_list %in% syn_list$synonym))&(!(name_list %in% syn_list$realname)))]
  item<-data.frame(group=group, 
                   in_realname=length(in_realname),
                   in_synonym=length(in_synonym),
                   in_both=length(in_both),
                   in_nothing=length(in_nothing),
                   name_list1=name_list1,
                   name_list2=name_list2
  )
  result<-list(in_realname=in_realname,
               in_synonym=in_synonym,
               in_both=in_both,
               in_nothing=in_nothing,
               info=item)
  return(result)
}

syn_lists<-c("../../raw_from_Alice/IUCN/synonyms/amphibian_synonyms.csv",
             "../../raw_from_Alice/IUCN/synonyms/bird_synonyms.csv",
             "../../raw_from_Alice/IUCN/synonyms/mammal_synonyms.csv",
             "../../raw_from_Alice/IUCN/synonyms/odonata_synonyms.csv",
             "../../raw_from_Alice/IUCN/synonyms/reptile_synonyms.csv"
)
IUCN_Lists<-c("../../Data/IUCN_Distribution_Lines/Amphibians_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Birds_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/MAMMALS_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Odonata_With_Boundary",
              "../../Data/IUCN_Distribution_Lines/Reptiles_With_Boundary")

GBIF_Lists<-c("../../Data/GBIF_More_Data/Amphibians",
              "../../Data/GBIF_More_Data/Bird",
              "../../Data/GBIF_More_Data/Mammals",
              "../../Data/GBIF_More_Data/Odonata",
              "../../Data/GBIF_More_Data/Reptiles")

realm_lists<-c("../../Tables/Realm/Amphibians_realm.csv",
               "../../Tables/Realm/Bird_realm.csv",
               "../../Tables/Realm/Mammals_realm.csv",
               "../../Tables/Realm/Odonata_realm.csv",
               "../../Tables/Realm/Reptile_realm.csv")

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")

result<-data.frame()
i=1
for (i in c(1:length(groups))){
  print(groups[i])
  syn_list<-read.table(syn_lists[i], head=T, sep=",", stringsAsFactors = F)
  IUCN_List<-list.files(IUCN_Lists[i])
  GBIF_List<-list.files(GBIF_Lists[i])
  realm_list<-read.table(realm_lists[i], head=T, sep=",", stringsAsFactors = F)
  
  syn_iucn<-get_result(syn_list, IUCN_List, groups[i], "SYNONYMS", "IUCN")
  syn_gbif<-get_result(syn_list, GBIF_List, groups[i], "SYNONYMS", "GBIF")
  syn_realm<-get_result(syn_list, realm_list$scientificName, groups[i], "SYNONYMS", "REALM")
  realm_iucn<-get_result(realm_list$scientificName, IUCN_List, groups[i], "REALM", "IUCN")
  realm_gbif<-get_result(realm_list$scientificName, GBIF_List, groups[i], "REALM", "GBIF")
  iucn_gbif<-get_result(IUCN_List, GBIF_List, groups[i], "IUCN", "GBIF")
  gbif_iucn<-get_result(GBIF_List, IUCN_List, groups[i], "GBIF", "IUCN")
  
  item<-rbind(syn_iucn$info,
              syn_gbif$info,
              syn_realm$info,
              realm_iucn$info,
              realm_gbif$info,
              iucn_gbif$info,
              gbif_iucn$info)
  
  if (nrow(result)==0){
    result<-item
  }else{
    result<-rbind(result, item)
  }
}

write.table(result, "../../Tables/syn_stat.csv", row.names=F, sep=",")

