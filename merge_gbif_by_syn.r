setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")

get_result<-function(syn_list, name){
  if (is.null(dim(syn_list))){
    syn_list<-gsub(".rda", "", syn_list)
    syn_list<-gsub("_", " ", syn_list)
    syn_list<-toupper(syn_list)
    syn_list<-data.frame(a1=syn_list, a2=syn_list)
  }
  colnames(syn_list)<-c("realname", "synonym")
  syn_list$realname_upper<-toupper(trimws(syn_list$realname, which="both"))
  syn_list$synonym_upper<-toupper(trimws(syn_list$synonym, which="both"))
  
  name<-gsub(".rda", "", name)
  name<-gsub("_", " ", name)
  name<-toupper(name)
  
  item<-syn_list[which(syn_list$realname_upper==name),]
  return(item)
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

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])

#for (i in c(1:length(groups))){
  
  syn_list<-read.table(syn_lists[i], head=T, sep=",", stringsAsFactors = F)
  IUCN_List<-list.files(IUCN_Lists[i])
  GBIF_List<-list.files(GBIF_Lists[i])
  realm_list<-read.table(realm_lists[i], head=T, sep=",", stringsAsFactors = F)
  j=1
  
  for (j in c(1:length(IUCN_List))){
    print(paste(groups[i], IUCN_List[j], j, length(IUCN_List), sep="/"))
    item<-get_result(syn_list, IUCN_List[j])
    target<-sprintf("../../Data/merged_gbif_occ/%s/%s", groups[i], IUCN_List[j])
    gbif_source<-sprintf("%s/%s", GBIF_Lists[i], IUCN_List[j])
    if (file.exists(target)){
      next()
    }
    saveRDS(NA, target)
    
    if (nrow(item)==0){
      if (file.exists(gbif_source)){
        file.copy(gbif_source, target, overwrite = T)
      }
      
      next()
    }
    
    if (file.exists(gbif_source)){
      df<-readRDS(gbif_source)
    }else{
      df<-data.frame()
    }
    syn<-item$synonym[1]
    item$syn_exist<-F
    for (syn in item$synonym){
      if (syn==item[1, "realname"]){
        next()
      }  
      gbif_source<-sprintf("%s/%s", GBIF_Lists[i], sprintf("%s.rda", gsub(" ", "_", syn)))
      if (file.exists(gbif_source)){
        df_item<-readRDS(gbif_source)
        item[which(item$synonym==syn), "syn_exist"]<-T
        if (nrow(df)==0){
          df<-df_item
        }else{
          df<-rbind(df, df_item)
        }
      }
    }
    item$have_data<-F
    if (nrow(df)>0){
      saveRDS(df, target)
      item$have_data<-T
    }
    item$group<-groups[i]
    #print(colnames(item))
    if (nrow(result)==0){
      result<-item
    }else{
      result<-rbind(result, item)
    }
  }
#}


write.table(result, sprintf("../../Tables/%s_syn_merge_list.csv", groups[i]), row.names=F, sep=",")

