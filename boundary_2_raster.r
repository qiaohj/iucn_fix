library(raster)
library(rgdal)
library(rgeos)
setwd("~/Experiments/IUCN_FIX/Script/iucn_fix")


#country_boundaries
sp_df<-readOGR("../../raw_from_Alice/IUCN", "country_boundaries") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/ploygon", layer="country_boundaries_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/ploygon", "country_boundaries_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/country_boundaries_eck4.tif", overwrite=T)


#coastal_boundaries
sp_df<-readOGR("../../raw_from_Alice/IUCN", "coastal_boundaries") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/ploygon", layer="coastal_boundaries_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/ploygon", "coastal_boundaries_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/coastal_boundaries_eck4.tif", overwrite=T)



#coastal_boundaries
sp_df<-readOGR("../../raw_from_Alice/IUCN", "coastal_boundaries") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/ploygon", layer="coastal_boundaries_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/ploygon", "coastal_boundaries_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/coastal_boundaries_eck4.tif", overwrite=T)



#province_boundaries

sp_df<-readOGR("../../raw_from_Alice/IUCN/pshape", "province_b1") 
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/ploygon", layer="province_b1_eck4", driver="ESRI Shapefile")

crs(sp_df_eck4)

sp_df_eck4<-readOGR("../../Shape/ploygon", "province_b1_eck4") 
extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/province_b1_eck4_eck4.tif", overwrite=T)
