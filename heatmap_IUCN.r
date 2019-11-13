library(raster)
library(rgdal)
library(rgeos)
library(sf)
library(fasterize)
library(gdalUtils)

setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")


args = commandArgs(trailingOnly=TRUE)
i<-as.numeric(args[1])

groups<-c("Amphibians", "Birds", "Mammals", "Odonata", "Reptiles")


dsn<-c("../../Shape/iucn_species_Ranges/AMPHIBIANS",
       "../../Shape/iucn_species_Ranges/Birds",
       "../../Shape/iucn_species_Ranges/MAMMALS1",
       "../../Shape/iucn_species_Ranges/Odonata",
       "../../Shape/iucn_species_Ranges/Reptiles")
#layer<-c("AMPHIBIANS_eck4", "BIRD_eck4", "MAMMALS_eck4", "Odonata_eck4", "Reptiles_eck4")
layer<-c("AMPHIBIANS", "All_Species", "MAMMALS", "data_0", "modeled_reptiles")

field_name<-c("binomial", "SCINAME", "binomial", "BINOMIAL", "Binomial")
#mask<-raster("../../Raster/mask_1k.tif")

#separate the IUCN Range species by species
if (F){
  sp_df<-readOGR(dsn[i], layer[i]) 
  sp_list<-unique(sp_df@data[, field_name[i]])
  for (j in c(1:length(sp_list))){
    sp<-sp_list[j]
    
    target<-sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s/%s.shp", groups[i], gsub(" ", "_", sp))
    if (file.exists(target)){
      next()
    } 
    print(paste(sp, groups[i], j, length(sp_list)))
    dir.create(sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s", groups[i]), showWarnings = F)
    saveRDS(NA, target)
    
    item<-sp_df[which(sp_df@data[, field_name[i]]==sp),]
    delfiles <- dir(path=sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s", groups[i]),
                    pattern=sprintf("%s.*", gsub(" ", "_", sp)))
    file.remove(file.path(sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s", groups[i]),
                          delfiles))
    
    writeOGR(obj=item, 
             dsn=sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s", groups[i]),
             layer=gsub(" ", "_", sp), driver="ESRI Shapefile")
  }
  
}
# convert IUCN range to raster species by species
if(F){
  fs<-list.files(sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s", groups[i]), pattern = "\\.shp$")
  f<-fs[1]
  mask_bak<-raster("../../Raster/province.tif")
  for (f in fs){
    target<-sprintf("../../Raster/IUCN_Range_By_Species/%s/%s", groups[i], gsub("\\.shp", "\\.tif", f))
    if (file.exists(target)){
      next()
    }
    dir.create(sprintf("../../Raster/IUCN_Range_By_Species/%s", groups[i]), showWarnings = F)
    mask<-mask_bak
    print(f)
    sp_eck <- st_read(sprintf("../../Shape/polygon/IUCN_Range_By_Species/%s/%s", groups[i], f))
    extent(mask)<-extent(sp_eck)
    res(mask)<-c(0.008, 0.008)
    rp <- fasterize(sp_eck, mask)
    writeRaster(rp, target, overwrite=T)
  }
  
}

#merge species to genus
if (F){
  print(dirname(rasterTmpFile()) )
  #for (i in c(1, 2, 3, 4, 5)){
  fs<-list.files(sprintf("../../Raster/IUCN_Range_By_Species/%s", groups[i]), pattern = "\\.tif$")
  genus_list<-c()
  f<-fs[1]
  for (f in fs){
    items<-strsplit(gsub("\\.tif", "", f), "_")[[1]]
    genus_list<-c(genus_list, items[1])
  }
  genus_list<-unique(genus_list)
  genus<-genus_list[1]
  for (genus in genus_list){
    target<-sprintf("../../Raster/heatmap_IUCN/Genus/%s/%s.tif", groups[i], genus)
    if (file.exists(target)){
      next()
    }
    print(paste(groups[i], genus))
    dir.create(sprintf("../../Raster/heatmap_IUCN/Genus/%s", groups[i]), showWarnings = F)
    saveRDS(NA, target)
    r<-NA
    tag<-NA
    for (f in fs){
      items<-strsplit(gsub("\\.tif", "", f), "_")[[1]]
      #
      if (genus != items[1]){
        next()
      }
      print(paste(items[1], f, groups[i]))
      r1<-raster(sprintf("../../Raster/IUCN_Range_By_Species/%s/%s", groups[i], f))
      origin(r1)<-c(0, 0)
      if (is.na(tag)){
        r<-r1
        tag<-1
      }else{
        r<-mosaic(r, r1, fun=sum)
      }
    }
    
    writeRaster(r, sprintf("%s.temp.tif", target), overwrite=F)
    file.remove(target)
    file.rename(sprintf("%s.temp.tif", target), target)
  }
  #}
}


#merge genus to group
if (T){
  fs<-list.files(sprintf("../../Raster/heatmap_IUCN/Genus/%s", groups[i]), pattern = "\\.tif$")
  
  r<-NA
  tag<-NA
  f<-fs[1]
  for (f in fs){
    print(paste(groups[i], f))
    r1<-raster(sprintf("../../Raster/heatmap_IUCN/Genus/%s/%s", groups[i], f))
    origin(r1)<-c(0, 0)
    if (is.na(tag)){
      r<-r1
      tag<-1
    }else{
      print("merging")
      r<-mosaic(r, r1, fun=sum, filename="")
    }
  }
  target<-sprintf("../../Raster/heatmap_IUCN/Groups/%s.tif", groups[i])
  writeRaster(r, target, overwrite=T)
  
}

library(foreign)
family<-c("family", "family", "family", NA, "Group")
genus<-c("genus", "genus", "genus", NA, "genus")
#merge genus to family
if (F){
  
  df<-read.dbf(sprintf("%s/%s.dbf", dsn[i], layer[i]))
  
  families<-unique(df[, family[i]])
  fam<-families[2]
  for (fam in families){
    folder<-sprintf("../../Raster/heatmap_IUCN/Family/%s", groups[i])
    dir.create(folder, showWarnings = F)
    target<-sprintf("%s/%s.tif", folder, fam)
    if (file.exists(target)){
      next()
    }
    saveRDS(NA, target)
    genus_list<-unique(df[which(df[, family[i]]==fam), genus[i]])
    
    r<-NA
    tag<-NA
    f<-genus_list[1]
    for (f in genus_list){
      print(paste("group:", groups[i], "family:", fam, "genus:", f))
      r1<-raster(sprintf("../../Raster/heatmap_IUCN/Genus/%s/%s.tif", groups[i], f))
      origin(r1)<-c(0, 0)
      if (is.na(tag)){
        r<-r1
        tag<-1
      }else{
        r<-mosaic(r, r1, fun=sum)
      }
    }
    
    writeRaster(r, sprintf("%s.temp.tif", target), overwrite=F)
    file.remove(target)
    file.rename(sprintf("%s.temp.tif", target), target)
  }
}

#merge family to order

order<-c("order_", "order_", "order_", "order_", "order_")
if (F){
  
  df<-read.dbf(sprintf("%s/%s.dbf", dsn[i], layer[i]))
  
  orders<-unique(df[, order[i]])
  ord<-orders[1]
  for (ord in orders){
    folder<-sprintf("../../Raster/heatmap_IUCN/Order/%s", groups[i])
    dir.create(folder, showWarnings = F)
    target<-sprintf("%s/%s.tif", folder, ord)
    if (file.exists(target)){
      next()
    }
    saveRDS(NA, target)
    family_list<-unique(df[which(df[, order[i]]==ord), family[i]])
    
    r<-NA
    tag<-NA
    f<-family_list[1]
    for (f in family_list){
      print(paste("group:", groups[i], "order:", ord, "family:", f))
      r1<-raster(sprintf("../../Raster/heatmap_IUCN/Family/%s/%s.tif", groups[i], f))
      origin(r1)<-c(0, 0)
      if (is.na(tag)){
        r<-r1
        tag<-1
      }else{
        r<-mosaic(r, r1, fun=sum)
      }
    }
    
    writeRaster(r, sprintf("%s.temp.tif", target), overwrite=F)
    file.remove(target)
    file.rename(sprintf("%s.temp.tif", target), target)
  }
}
print(warnings())
