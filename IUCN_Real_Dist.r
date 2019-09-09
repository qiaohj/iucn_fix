setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")
base<-"../../Data/IUCN_Distribution_Lines"
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
boundarys<-c("Amphibians_With_Boundary", "Birds_With_Boundary", "MAMMALS_With_Boundary", 
             "Odonata_With_Boundary", "Reptiles_With_Boundary")
realms<-read.table("../../Tables/Realm/Realm_IDs.csv", head=T, sep=",", stringsAsFactors = F)
realm_sp<-c("Amphibians_realm.csv", "Bird_realm.csv", "Mammals_realm.csv", 
            "Odonata_realm.csv", "Reptile_realm.csv")

args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])

#i=1
j=100
result<-data.frame()

#for (i in c(1:length(groups))){
print(paste(groups[i]))
sp<-list.files(sprintf("%s/%s", base, boundarys[i]))
df_realm_sp<-read.table(sprintf("../../Tables/Realm/%s", realm_sp[i]), head=T, sep=",", stringsAsFactors = F)

for (j in c(1:length(sp))){
  print(paste(groups[i], sp[j], j, length(sp), sep=" / "))
  f<-sp[j]
  name<-gsub(".rda", "", f)
  name<-gsub("_", " ", name)
  df<-readRDS(sprintf("%s/%s/%s", base, boundarys[i], f))
  
  
  df<-merge(df, realms, by.x="realm", by.y="Realm_ID", all.x=T, all.y=F)
  if (nrow(df[which(is.na(df$Realm)),])>0){
    df[which(is.na(df$Realm)), "Realm"]<-"Not Available"
  }
  
  realm_table<-data.frame(table(df$Realm))
  #if (nrow(realm_table)>0){
    
    colnames(realm_table)<-c("Realm", "Freq")
    realm_table$name<-name
    realm_table$is_in_list<-F
    realm_table$Realm<-as.character(realm_table$Realm)
  #}else{
  #  realm_table<-data.frame(Realm="Not Available", Freq=nrow(df), name=name, is_in_list=F)
  #}
  
  realm_item<-df_realm_sp[which(df_realm_sp$scientificName==name),]
  if (nrow(realm_item)>0){
    realm_item_ids<-strsplit(realm_item$realm, "\\|")[[1]]
    realm_table[which(realm_table$Realm %in% realm_item_ids), "is_in_list"]<-T
    for (re in realm_item_ids[which(!(realm_item_ids %in% realm_table$Realm))]){
      item<-data.frame(Realm=re, Freq=0, name=name, is_in_list=T)
      realm_table<-rbind(realm_table, item)
    }
  }
  if (nrow(result)==0){
    result<-realm_table
  }else{
    result<-rbind(realm_table, result)
  }
  
}
write.table(result, sprintf("../../Tables/IUCN_Realm/%s.csv", groups[i]), row.names=F, sep=",")
#}