library("raster")
setwd("/Volumes/Disk2/Experiments/IUCN_FIX/Script/iucn_fix")

if (F){
  r<-raster("../../Raster/Odonata_Basin/obonata_basin.tif")
  mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
  print("reproject")
  rr<-projectRaster(r, crs=crs(mask), res=res(mask), method="ngb")
  res(rr)
  extent(rr)
  print("write reproject")
  writeRaster(rr, "../../Raster/Odonata_basin_overlap_eck4.tif", overwrite=T)
  
  print("buffer")
  rr_buffer<-buffer(rr, width=500)
  
  print("write buffer")
  writeRaster(rr_buffer, "../../Raster/Odonata_basin_overlap_eck4_500_buffer.tif", overwrite=T)
}
library("rgdal")
#country_boundaries
sp_df<-readOGR("../../raw_from_Alice/ob", "od_boundary")
mask<-raster("../../Raster/Bioclim2.0/500m/bio01.tif")
sp_df_eck4<-spTransform(sp_df, CRS=crs(mask))
writeOGR(obj=sp_df_eck4, dsn="../../Shape/polygon", layer="od_boundary_buffer_eck4", driver="ESRI Shapefile")

extent(mask)<-extent(sp_df_eck4)
rp <- rasterize(sp_df_eck4, mask)
writeRaster(rp, "../../Raster/od_boundary_buffer_eck4.tif", overwrite=T)