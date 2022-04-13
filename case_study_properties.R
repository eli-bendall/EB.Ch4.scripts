# Hamish C 2022.02.22
# Script to pull out four bioclim variables, 
# for three veg formations, in case study area

# merge with existing script

library(raster)
library(rgdal)
library(rgeos)

epsg_num_gda94 <- 4283
epsg_num_lam <- 3308

# load case studies
shp_diri <- "C:/Users/hamishc/backup/working/temp/"
regnam <- c("dsf","gw","wsf")


# *** NEEDS TO BE REPLACED WITH BIOCLIM DATA ***
# load climate
clim_diri <- "C:/Users/hamishc/backup/working/temp/"
clim_fili <- c("BIO1.tif","BIO5.tif","BIO6.tif","BIO12.tif")

bio1 <- raster(paste0(clim_diri,clim_fili[1]))
bio5 <- raster(paste0(clim_diri,clim_fili[2]))
bio6 <- raster(paste0(clim_diri,clim_fili[3]))
bio12 <- raster(paste0(clim_diri,clim_fili[4]))

# pre-allocate dataframe
props <- data.frame(veg = regnam, 
                    matmin=NA, matmean=NA, matmax=NA,
                    mapmin=NA, mapmean=NA, mapmax=NA,
                    maxtwarmmin=NA, maxtwarmmean=NA, maxtwarmmax=NA,
                    mintcoolmin=NA, mintcoolmean=NA, mintcoolmax=NA,
                    stringsAsFactors = FALSE)

getProps <- function(raster_in, shp) {
  r_crop <- crop(raster_in, extent(shp))
  r_x <- extract(r_crop, shp)
  
  rmin <- min(unlist(r_x), na.rm=TRUE)
  rmean <- mean(unlist(r_x), na.rm=TRUE)
  rmax <- max(unlist(r_x), na.rm=TRUE)
  rprops <- c(rmin, rmean, rmax)
  return (rprops)
}

for (rctr in 1:length(regnam)) {
  
  shp_fili <- paste0(regnam[rctr],"_bioreg.shp")
  print("loading shapefile...")
  shp_in <- readOGR(paste0(shp_diri,shp_fili))
  
  print("getting MAT...")
  bio1_props <- getProps(bio1, shp_in) # mat
  print("and now MAP...")
  bio5_props <- getProps(bio5, shp_in) # max t warm
  print("and now max temp of warmest month...")
  bio6_props <- getProps(bio6, shp_in) # min t cool
  print("followed by min temp of coolest month...")
  bio12_props <- getProps(bio12, shp_in) # map
  
  props[rctr,2:4] <- bio1_props
  props[rctr,5:7] <- bio12_props
  props[rctr,8:10] <- bio5_props
  props[rctr,11:13] <- bio6_props
  
  paste(" and now on to the next region...")
  rm(pr_props, tmax_props, tmin_props, shp_in, shp_fili)
}

write.csv(props, "C:/Users/hamishc/backup/working/temp/climate_values.csv")
