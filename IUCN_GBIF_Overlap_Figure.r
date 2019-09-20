library(ggplot2)
groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")
ddd<-data.frame()
for (group in groups){
  if (group %in% c("Birds")){
    next()
  }
  print(group)
  df1<-read.table(sprintf("../../Tables/realm_GBIF_OBIS_Overlap_error/%s.csv", group), head=T, sep=",", stringsAsFactors = F)
  df2<-read.table(sprintf("../../Tables/realm_GBIF_OBIS_Overlap/%s.csv", group), head=T, sep=",", stringsAsFactors = F)
  
  df1$av<-df1$n_in/df1$n_continent
  df2$av<-df2$n_in/df2$n_continent
  
  threshold<-seq(from=0, to=50000, by=100)
  
  for (t in threshold){
    item<-data.frame(group=group,
                     threshold=t, 
                     mean1=mean(df1[which(df1$n>t),]$av, na.rm=T),
                     mean2=mean(df2[which(df2$n>t),]$av, na.rm=T),
                     sd1=sd(df1[which(df1$n>t),]$av, na.rm=T),
                     sd2=sd(df2[which(df2$n>t),]$av, na.rm=T)
    )
    
    if (nrow(ddd)==0){
      ddd<-item
    }else{
      ddd<-rbind(ddd, item)
    }
  }
 
  
 
}
ggplot(ddd)+geom_line(aes(x=threshold, y=mean1), color="red")+geom_line(aes(x=threshold, y=mean2), color="blue")
ggplot(ddd)+geom_line(aes(x=threshold, y=mean2, color=factor(group)))
