library(raster)
library(rgdal)
library(rgeos)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")


#country_boundaries
sp_df<-readOGR("../../raw_from_Alice/IUCN", "country_boundaries") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="country_boundaries_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/polygon", "country_boundaries_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/country_boundaries_eck4.tif", overwrite=T)


#coastal_boundaries
sp_df<-readOGR("../../raw_from_Alice/IUCN", "coastal_boundaries") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="coastal_boundaries_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/polygon", "coastal_boundaries_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/coastal_boundaries_eck4.tif", overwrite=T)



#province_boundaries

#sp_df<-readOGR("../../raw_from_Alice/IUCN/pshape", "province_b1") 
#extent(sp_df)
#mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
#sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
#writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="province_b1_eck4", driver="ESRI Shapefile")

library("sf")
tdwg4.laea = sf::read_sf("../../raw_from_Alice/IUCN/pshape/province_b1.shp")  # assumes in project root
tdwg4.laea2 = sf::st_transform(tdwg4.laea, crs(mask))
sf::write_sf(tdwg4.laea2, "../../Shape/polygon/province_b1_eck4.shp")
crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/polygon", "province_b1_eck4") 

ff<-sp_df_eck4[(sp_df_eck4$ID==5557),]
i=1
j=2
for (i in c(1:length(ff@polygons))){
  f1<-ff@polygons[[i]]@Polygons
  for (j in c(1:length(f1))){
    print(paste(i, j))
    f2<-f1[[j]]
    coord<-f2@coords
    n<-nrow(coord[which(coord[,1]<(-10000000)),])
    if (n>0){
      printf(asdf)
    }
  }
}



sp_df_eck4[(sp_df_eck4$ID==5557),]@polygons[[1]]@Polygons[[1]]@coords[which(coord[,1]<=(-12500000)), 1]<-12565000
sp_df_eck4[(sp_df_eck4$ID==5557),]@polygons[[1]]@Polygons[[1]]@coords[which(coord[,1]<(-12000000)), 1]<-12011000

ff<-sp_df_eck4[(sp_df_eck4$ID==5557),]
plot(ff)

extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/province_b1_eck4.tif", overwrite=T)


x <- new("GDALReadOnlyDataset", "../../raw_from_Alice/IUCN/prov_buffers")
getDriver(x)
getDriverLongName(getDriver(x))
xx<-asSGDF_GROD(x)
r <- raster(xx)
plot(r)
writeRaster(r, "../../Raster/province.tif", overwrite=T)

table(values(r))

mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
r_eck4 <- projectRaster(r, crs=crs(mask), res=res(mask), method="ngb")
writeRaster(r_eck4, "../../Raster/province_eck4.tif", overwrite=T)



#Biogeographic_realms_clip
sp_df<-readOGR("../../raw_from_Alice/IUCN", "Biogeographic_realms_clip") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="Biogeographic_realms_clip_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/polygon", "Biogeographic_realms_clip_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/Biogeographic_realms_clip_eck4.tif", overwrite=T)

