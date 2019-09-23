library(raster)
library(rgdal)
library(rgeos)

#Birds, Mammals, Odonata, Reptiles

r<-raster("../../raw_from_Alice/quartiles/amp_ramp1b")
mask<-raster("../../Raster/mask_1k.tif")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Amphibians_top2.tif", overwrite=T)


r<-raster("../../raw_from_Alice/quartiles/amp_ramp12a")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Amphibians_top3.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/bird_ramp")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Birds_top2.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/bird_ramp12")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Birds_top3.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/mam_ramp")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Mammals_top2.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/mam_ramp12")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Mammals_top3.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/odo_ramp")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Odonata_top2.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/odo_ramp12")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Odonata_top3.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/rep_ramp")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Reptiles_top2.tif", overwrite=T)

r<-raster("../../raw_from_Alice/quartiles/rep_ramp12")
crs(r)<-crs(mask)
writeRaster(r, "../../Raster/Quantiles/Reptiles_top3.tif", overwrite=T)

