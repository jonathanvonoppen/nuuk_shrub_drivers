# Variograms for predictor rasters 
# Jakob Assmann j.assmann@bio.au.dk 16 September 2020

# Dependencies
library(raster)
library(gstat)
library(parallel)
library(cowplot)
library(ggplot2)
library(sf)
library(dplyr)

# set global raster options with process bar
rasterOptions(progress = "text")

# 
# JJA (June, July, August) 
# insolation ('insol.asc')
# JJA precip ('jjaprecip')
# MAM (March, April, May) precip ('mamprecip.asc')
# JJA maximum temps ('tempjja.asc')
# yearly max temp ('tempmax.asc')
# yearly min temp ('tempmin.asc')
# temperature continentality (diff. between yearly max and min temps) ('tempcont.asc')
# 
# These are located in the following folder:
#   'Nat_Ecoinformatics/C_Write/_User/NathalieChardon_au653181/input_data/pred_rasters/'

## Load rasters 
raster_path <- "O:/Nat_Ecoinformatics/C_Write/_User/NathalieChardon_au653181/input_data/pred_rasters/"
predictor_paths <- c(
  "insol.asc",
  "jjaprecip.asc",
  "mamprecip.asc",
  "tempjja.asc",
  "tempmax.asc",
  "tempmin.asc",
  "tempcont.asc")
# template with projection
projection_temp <- raster("O:/Nat_Ecoinformatics/C_Write/_User/NathalieChardon_au653181/input_data/processed/main_ras.tif")

# load rasters and assign projection
raster_list <- lapply(
  predictor_paths,
  function(predictor_raster){
    predictor_raster <- raster(
      paste0(raster_path,
             predictor_raster))
    crs(predictor_raster) <- crs(projection_temp)
    return(predictor_raster)
  }
)

# add TRI to raster to list
raster_list <- append(
   raster_list,
   setNames(
     raster("D:/Jakob/ArcticDEM/jonathan_wet/GIMP_MEaSUREs_30m/tri/nuuk_fjord_ArcticDEM_mosaic_2m_tri.tif"),
     "tri"))
# add tcw raster to list
raster_list <- append(
  raster_list,
  setNames(raster("D:/Jakob/ArcticDEM/nathalie_nuuk/landsatTCwet_NUUK_UTM22.tif"),
           "TCwet"))
# add Kopecky_TWI to list
raster_list <- append(
  raster_list,
  setNames(raster("D:/Jakob/ArcticDEM/jonathan_wet/GIMP_MEaSUREs_30m/twi/nuuk_fjord_GIMP_MEaSUREs_30m_DEM_flow_mfd_twi.tif"),
           "kopecky_twi"))
study_area_extent <- as(extent(raster_list[[10]]), "SpatialPolygons")
crs(study_area_extent) <- crs(raster_list[[10]])
study_area_extent <- spTransform(study_area_extent, crs(raster_list[[9]]))
raster_list[[9]] <- crop(raster_list[[9]],study_area_extent )
raster_list[[9]] <- mask(raster_list[[9]],study_area_extent )

# # Crop TRI raster to same extent as other rasters
# raster_list[[8]] <- crop(raster_list[[8]], raster_list[[1]])

### Define functions to calculate and fit variograms ----

# Define function to calculuate a variogram 
sample_variogram <- function(predictor_raster, thin = 10, bin_width = 90) { 

  # Check whether the TRI raster is plotted if yes increase the thinning massively
  if(names(predictor_raster) == "tri") thin <- 2000
  
  # Convert raster to spdf
  predictor_spdf <- as(predictor_raster, "SpatialPixelsDataFrame" ) 
  
  # Square out spdf (needed due to a bug in gstat)
  predictor_spdf@grid@cellsize[1] <- as.numeric(formatC(predictor_spdf@grid@cellsize[1], 
                                             format = "d"))
  predictor_spdf@grid@cellsize[2] <- as.numeric(formatC(predictor_spdf@grid@cellsize[2], 
                                                        format = "d"))
  # Set variogram forumla 
  vario_forumla <- as.formula(paste0(names(predictor_raster),
                                           " ~ 1"))
  # Sample the variogram (this can take ages)
  vario <- variogram(vario_forumla, 
                     predictor_spdf[sample(nrow(predictor_spdf) / thin),],
                     width = bin_width,
                     verbose = T) 
  
  # Change id colum
  vario$id <- names(predictor_raster)
  
  # save variogram
  save(vario, file = paste0("data/variograms/", names(predictor_raster), ".Rda"))
  
  # clean memory
  gc()
  
  # Return variogram
  return(vario)
}

# Prep parallel envrionment
cl <- makeCluster(12)
clusterEvalQ(cl, {
  library(gstat)
  library(raster)
  })

# Sample variograms
vario_list <- parLapply(cl, raster_list, sample_variogram)
save(vario_list, file = "scripts/jakob/vario_list.Rda")
#load("scripts/jakob/vario_list.Rda")
stopCluster(cl)

# Load successful variogram fits in case one failed
if(!exists("vario_list")){
  if(exists("vario")) rm("vario")
  list_of_vario_files <- list.files("data/variograms/", 
                                    pattern = ".Rda",
                                    full.names = T)
  vario_list <- lapply(list_of_vario_files, function(x){
    load(x)
    return(vario)
  })
}

# Look up table for pretty names
lookup_table <- data.frame(
  raster_names = c(unlist(lapply(vario_list[-10], function(x) x$id[1]))),
  pretty_names = c("Insolation",
                  "Cumulative Summer (JJA) Precipitation *",
                  "Topographic Wetness Index (TWI-FD8) *",
                  "Cumulative Spring (MAM) Precipitation",
                  "Tasseled-cap Wetness Index (TCWS) *",
                  "Annual Temperature Variability *",
                  "Mean Summer (JJA) Temperature *",
                  "Annual Maximum Temperature",
                  "Annual Minimum Temperature" #,
                  #"Terrain Ruggedness Index (TRI)",
                  ),
  stringsAsFactors = F)


# Plot Variograms
plot_variogram <- function(vario){
  vario_plot <- ggplot(
    vario, 
    aes(x = dist / 1000, y = gamma)) + 
    # geom_vline(aes(xintercept = distances),
    #            data = data.frame(distances = distances),
    #            colour = "lightgrey",
    #            alpha = 0.5) + 
    geom_point() +
    labs(x = "Distance (km)", 
         y = "Semivariance",
         title = lookup_table$pretty_names[lookup_table$raster_names == unique(vario$id)]) +
    scale_x_continuous(limits = c(0,40),
                       breaks = seq(0,40,5)) +
    theme_cowplot(15)
  save_plot(paste0("figures/variograms/", unique(unique(vario$id)), ".png"),
            vario_plot,
            base_aspect_ratio = 1.3,
            base_height = 5)
}
lapply(vario_list, plot_variogram)

## Variogram for TRI
# This is needed seperately as the grain size for
# the raster is different to the others

# Load TRI raster
predictor_raster <-  raster_list[[8]]

# Sample raster
predictor_spdf <- sampleRandom(predictor_raster,
                               1400000,
                               sp = T)


# Sample the variogram (this can take ages)
vario <- variogram(tri ~  1, 
                   predictor_spdf,
                   width = 90,
                   verbose = T) 

# Change id colum
vario$id <- names(predictor_raster)

# Add row to lookup table
lookup_table <- bind_rows(lookup_table,
                          data.frame(raster_names = "tri", 
                                     pretty_names = "Terrain Ruggedness Index (TRI) *"))
                          
# Plot variogram using the variogram plotting function.
plot_variogram(vario) 
#plot_variogram(vario_list[[10]]) 

# Save variogram 
save(vario, file = "data/variograms/tri_vario.Rda")
#load("scripts/jakob/tri_vario.Rda")

## Variograms for SRI (a non-raster variable)
nuuk_plots <- read.csv("data/processed/nuuk_env_cover_plots_topo_variables.csv",
                       stringsAsFactors = F) %>%
  distinct(plot, lat, long, sri) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>%
  st_transform(crs = crs(projection_temp)) %>%
  as_Spatial()

sri_vario <- variogram(sri ~ 1, nuuk_plots,
          width = 90)

sri_vario_plot <- ggplot(
  sri_vario, 
  aes(x = dist / 1000, y = gamma)) + 
  geom_point() +
  labs(x = "Distance (km)", 
       y = "Semivariance",
       title = "Solar Radiation Index *") +
  scale_x_continuous(limits = c(0,40),
                     breaks = seq(0,40,5)) +
  theme_cowplot(15)

save_plot("figures/variograms/sri.png",
          sri_vario_plot,
          base_aspect_ratio = 1.3,
          base_height = 5)

# Get distances between plots
distances <- read.csv("data/processed/nuuk_env_cover_plots_topo_variables.csv",
                      stringsAsFactors = F) %>%
  distinct(plot, lat, long) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>%
  st_transform(crs = crs(projection_temp)) %>%
  st_distance(.,.) 
# remove duplicate values
distances[lower.tri(distances)] <- NA
# convert to vector
distances <- distances %>% as.vector %>% na.omit()

# Plot distance histogram
plot_distance_histogram <- ggplot(mapping = aes(x = distances / 1000)) +
  geom_histogram(binwidth = 0.5) +
  labs(x = "Distance between plot pairs (km)",
       y = "Count") +
  geom_vline(xintercept = 40) +
  scale_x_continuous(limits = c(0,100), breaks = seq(0,100,10)) +
  annotate("text", x = 42, y = 4000, hjust = 0, label = "max. distance in variogram analysis") +
  theme_cowplot(15)
save_plot("figures/variograms/plot_pair_dist_hist.png",
          plot_distance_histogram,
          base_aspect_ratio = 1.3,
          base_height = 5)
