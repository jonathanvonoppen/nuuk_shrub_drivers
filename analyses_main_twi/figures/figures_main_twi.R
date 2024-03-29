# Temperature variability and biotic interactions drive shrub species abundance along a coastal-inland gradient in arctic Greenland

# von Oppen, J. et al. 2020

# Figure code for main (TWI) analyses

# Jonathan von Oppen, Aarhus University, Sept 2020 - Jan 2021

# contact: jonathan.vonoppen@bio.au.dk



rm(list = ls())

# Dependencies ####
if (!require('pacman')) install.packages('pacman', repos="https://cloud.r-project.org")
pacman::p_load(tidyverse,
               tidylog,
               patchwork,
               cowplot)

# Colour scheme ####
theme_red <- "#E64447FF"
theme_darkblue <- "#1D5799"
theme_darkgreen <- "#13944D"
theme_lightpurple <- "#b774e8"
theme_purple <- "#8757B3"

# ________________________________________ ----

# Main manuscript figures ----
# ________________________________________ ----


# Fig. 1) Tundra species traits PCA scores ----
# scores extracted by Anne D. Bjorkman from Thomas et al. 2020 Nature Communications, https://doi.org/10.1038/s41467-020-15014-4

# >> load cleaned data ----
traits_scores_nuuk <- read.csv(file = file.path("data", "processed", "nuuk_traits_PCAscores_cleaned.csv"),
                               header = T) %>% 
  
  # adjust species labels
  mutate(species = recode(species,
                          "Betula nana" = "italic('Betula nana')",
                          "Cassiope tetragona" = "italic('Cassiope tetragona')",
                          "Empetrum nigrum" = "italic('Empetrum nigrum')",
                          "Phyllodoce caerulea" = "italic('Phyllodoce caerulea')",
                          "Rhododendron sp." = "italic('Rhododendron')~sp.",
                          "Salix sp." = "italic('Salix')~sp.",
                          "Vaccinium uliginosum" = "italic('Vaccinium uliginosum')",
                          "graminoids mean" = "graminoids~mean"))


# >> compile plot ----
# create labels for x axis
library(grid)
text_right <- textGrob("acquisitive", gp = gpar(fontsize = 13, fontface = "bold"))
text_left <- textGrob("conservative", gp = gpar(fontsize = 13, fontface = "bold"))


# plot PC1 scores
(traits_scores_plot <- ggplot(data = traits_scores_nuuk,
                              aes(x = PC1,
                                  y = 0,
                                  colour = fgroup)) +
    
    # # add gradient rectangle - not working yet!
    # geom_rect(aes(fill = PC1,
    #               xmin = -3.7, xmax = -0.3,
    #               ymin = 0, ymax = 0.1),
    #           colour = "grey70") +
    # 
    # scale_fill_gradientn(colours = c(theme_red, theme_pink, theme_darkblue)) +
    
    # plot scores
    geom_point(aes(colour = PC1),
               shape = 18,
               size = 4) +
    
    scale_colour_gradientn(colours = c(theme_red, rep(theme_lightpurple, 3), theme_darkblue)) +
    
    # add species names
    geom_text(aes(label = species,
                  angle = 90,
                  y = .1),
              hjust = 0,
              vjust = ifelse(traits_scores_nuuk$species == "italic('Rhododendron')~sp.", 0.8, 0.375),
              colour = "grey30",
              parse = TRUE) +
    
    # add traits labels
    annotation_custom(text_right, 
                      xmin = -0.4, xmax = -0.4, ymin = -0.4, ymax = -0.4) + 
    annotation_custom(text_left,
                      xmin = -3.55, xmax = -3.55, ymin = -0.4, ymax = -0.4) +
    
    # set appearance
    theme_classic() +
    
    coord_cartesian(xlim = c(-3.7, -0.3), 
                    ylim = c(0, 1.2), 
                    clip = "off") +
    
    theme(axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          legend.position = "none",
          plot.margin = unit(c(0, 0.5, 1, 0.5), "cm"))
  
)


# >> save plot ----
save_plot(file.path("analyses_main_twi", "figures", "Fig1_species_PCA_scores.png"),
          traits_scores_plot, base_height = 3, base_aspect_ratio = 2.5, dpi = 600)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ ----



# Fig. 1.1) Tundra species traits PCA scores - scaled & only shrub species ----
# scores extracted by Anne D. Bjorkman from Thomas et al. 2020 Nature Communications, https://doi.org/10.1038/s41467-020-15014-4

# >> load cleaned data ----
traits_scores_nuuk_shrubs_scaled <- read.csv(file = file.path("data", "processed", "nuuk_traits_PCAscores_cleaned.csv"),
                               header = T) %>% 
  
  # filter out graminoids
  filter(species != "graminoids mean") %>% 
  
  # scale acquisitiveness score (so far on the arbitrary scale from -3.6 to -0.9)
  mutate(acquis_scale = rescale(PC1, to = c(0, 1)))


# >> compile plot ----
# create labels for x axis
library(grid)
text_right <- textGrob("acquisitive", gp = gpar(fontsize = 13, fontface = "bold"))
text_left <- textGrob("conservative", gp = gpar(fontsize = 13, fontface = "bold"))


# plot PC1 scores
(traits_scores_plot <- ggplot(data = traits_scores_nuuk_shrubs_scaled,
                              aes(x = acquis_scale,
                                  y = 0,
                                  colour = fgroup)) +
    # plot scores
    geom_point(aes(colour = acquis_scale),
               shape = 18,
               size = 4) +
    
    scale_color_gradientn(colours = c(theme_red, theme_darkblue)) +
    
    # add species names
    geom_text(aes(label = species,
                  angle = 90,
                  y = .1),
              hjust = 0,
              vjust = ifelse(traits_scores_nuuk$species == "Rhododendron sp.", 0.8, 0.375),
              colour = "grey30",
              fontface = ifelse(traits_scores_nuuk$species == "graminoids mean", "plain", "italic")) +
    
    # add traits labels
    annotation_custom(text_right, 
                      xmin = 0.9, xmax = 0.9, ymin = -0.35, ymax = -0.35) + 
    annotation_custom(text_left,
                      xmin = 0.1, xmax = 0.1, ymin = -0.35, ymax = -0.35) +
    
    # specify axis label
    labs(x = "relative acquisitiveness (scaled)") +
    
    # set appearance
    theme_classic() +
    
    coord_cartesian(xlim = c(0, 1), 
                    ylim = c(0, 1.2), 
                    clip = "off") +
    
    theme(axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          legend.position = "none",
          plot.margin = unit(c(0, 0.5, 1.5, 0.5), "cm"))
  
)


# >> save plot ----
# save_plot(file.path("analyses_main_twi", "figures", "nuuk_shrub_drivers_species_PCA_scores_shrubs_scaled.pdf"),
#           traits_scores_plot, base_height = 3, base_aspect_ratio = 2.5)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨-----


# Fig. 4) Interaction plots temp X wetness (TWI) ----

# >> load function ----
source(file = file.path("scripts", "JvO", "plotting_functions", "interaction_plot_tempXwetness.R"))


# >> load data ----

# species
# load model output data
model_outputs_focal_species <- file.path("data", "processed", "model_outputs", "species_twi", list.files(path = file.path("data", "processed", "model_outputs", "species_twi"), pattern = "*2.Rdata"))
for (model_output in model_outputs_focal_species){
  load(model_output)
}
# load input data
load(file = file.path("data", "processed", "model_input_data_twi", "shrub_gradient_species.datasets.Rdata"))

# groups
# load model output data
model_outputs_groups <- file.path("data", "processed", "model_outputs", "groups_twi", list.files(path = file.path("data", "processed", "model_outputs", "groups_twi"), pattern = "*2.Rdata"))
for (model_output in model_outputs_groups){
  load(model_output)
}
# load input data
load(file = file.path("data", "processed", "model_input_data_twi", "shrub_gradient_group.datasets.Rdata"))


# >> plot graphs ----
(int_plot_AllShr <- interaction_plots_groups(fgroup = "all shrubs", wet.var = "TWI"))
(int_plot_AllEve <- interaction_plots_groups(fgroup = "evergreen shrubs", wet.var = "TWI"))
(int_plot_AllDec <- interaction_plots_groups(fgroup = "deciduous shrubs", wet.var = "TWI"))
(int_plot_BetNan <- interaction_plots_species(species = "Betula nana", wet.var = "TWI"))
(int_plot_EmpNig <- interaction_plots_species(species = "Empetrum nigrum", wet.var = "TWI"))
(int_plot_RhoGro <- interaction_plots_species(species = "Rhododendron groenlandicum", wet.var = "TWI"))
(int_plot_SalGla <- interaction_plots_species(species = "Salix glauca", wet.var = "TWI"))
(int_plot_VacUli <- interaction_plots_species(species = "Vaccinium uliginosum", wet.var = "TWI"))

# extract legend
legend_int_plot <- get_legend(int_plot_AllShr + 
                                theme(legend.box.margin = margin(t = 70, l = 70)))

# make x- and y-axis label
xlabel <- ggdraw() +
  draw_label("mean summer temperature [°C]",
             hjust = 0.5,
             size = 20,
             fontface = "bold")

ylabel <- ggdraw() +
  draw_label("relative abundance per plot group",
             vjust = 0,
             angle = 90,
             size = 20,
             fontface = "bold")

# combine plot and ylabel
(nuuk_interactions_row <- plot_grid(ylabel,
                                    plot_grid(int_plot_AllShr + theme(legend.position = "none"),
                                              int_plot_AllEve + theme(legend.position = "none"),
                                              int_plot_AllDec + theme(legend.position = "none"),
                                              int_plot_EmpNig, 
                                              int_plot_RhoGro, 
                                              int_plot_BetNan, 
                                              int_plot_VacUli,
                                              int_plot_SalGla,
                                              legend_int_plot,
                                              labels = c("a)", "b)", "c)", "d)", "e)", "f)", "g)", "h)"),
                                              label_size = 18,
                                              label_fontface = "bold",
                                              label_x = c(rep(0.02, 8)),
                                              ncol = 3,
                                              axis = "lt",
                                              align = "hv"),
                                    rel_widths = c(.03, 1)
))

# add xlabel
(nuuk_interaction_plot_grid_ver_twi <- plot_grid(nuuk_interactions_row,
                                                 xlabel,
                                                 ncol = 1,
                                                 rel_heights = c(1, 0.05)))

# # >> save plot ----
save_plot(file.path("analyses_main_twi", "figures", "Fig4_tempXwetness_twi.png"),
          nuuk_interaction_plot_grid_ver_twi, base_height = 15, base_aspect_ratio = 1, dpi = 600)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ ----


# Fig. 5) Interaction plots temp X community acquisitiveness ----

# >> load function ----
source(file = file.path("scripts", "JvO", "plotting_functions", "interaction_plot_tempXinteraction.R"))


# >> load data ----

# load model output data
model_outputs_tXi_focal_species <- file.path("data", "processed", "model_outputs", "species_twi", list.files(path = file.path("data", "processed", "model_outputs", "species_twi"), pattern = "*2.Rdata"))
for (model_output in model_outputs_tXi_focal_species){
  load(model_output)
}

# load input data
load(file = file.path("data", "processed", "model_input_data_twi", "shrub_gradient_species.datasets.Rdata"))


# >> plot graphs ----
(int_plot_tXi_BetNan <- tXi_interaction_plots(species = "Betula nana"))
(int_plot_tXi_EmpNig <- tXi_interaction_plots(species = "Empetrum nigrum"))
(int_plot_tXi_RhoGro <- tXi_interaction_plots(species = "Rhododendron groenlandicum"))
(int_plot_tXi_SalGla <- tXi_interaction_plots(species = "Salix glauca"))
(int_plot_tXi_VacUli <- tXi_interaction_plots(species = "Vaccinium uliginosum"))

# extract legend
legend_tempXint_plot <- get_legend(int_plot_tXi_BetNan + 
                                     theme(legend.box.margin = margin(t = 70, l = 70)))

# make x- and y-axis label
xlabel <- ggdraw() +
  draw_label("mean summer temperature [°C]",
             hjust = 0.5,
             size = 20,
             fontface = "bold")

ylabel <- ggdraw() +
  draw_label("relative abundance per plot group",
             vjust = 0,
             angle = 90,
             size = 20,
             fontface = "bold")

# combine plot and ylabel
(nuuk_tempXinteraction_row <- plot_grid(ylabel,
                                        plot_grid(int_plot_tXi_EmpNig + theme(legend.position = "none"),
                                                  int_plot_tXi_RhoGro + theme(legend.position = "none"),
                                                  int_plot_tXi_BetNan + theme(legend.position = "none"),
                                                  int_plot_tXi_VacUli + theme(legend.position = "none"),
                                                  int_plot_tXi_SalGla + theme(legend.position = "none"),
                                                  legend_tempXint_plot,
                                                  labels = c("a)", "b)", "c)", "d)", "e)"),
                                                  label_size = 18,
                                                  label_fontface = "bold",
                                                  label_x = c(rep(0.02, 8)),
                                                  ncol = 3,
                                                  axis = "lt",
                                                  align = "hv"),
                                        rel_widths = c(.03, 1)
))

# add xlabel
(nuuk_tempXint_plot <- plot_grid(nuuk_tempXinteraction_row,
                                 xlabel,
                                 ncol = 1,
                                 rel_heights = c(1, 0.05)))

# # >> save plot ----
save_plot(file.path("analyses_main_twi", "figures", "Fig5_tempXdCWA.png"),
          nuuk_tempXint_plot, base_height = 11, base_aspect_ratio = 1.5, dpi = 600)


# ________________________________________ ----

### Supplementary figures ----
# ________________________________________ ----


# Fig. S2) Predictor patterns along the gradient ----

# >> load data ----

env_cov_bio <- read.csv(file.path("data", "processed", "nuuk_env_cover_plots.csv"), 
                        header = T)

# >> data compilation ----
predictors_set <- env_cov_bio %>% 
  select(ends_with("_ts_30"),   # CHELSA predictors averaged over 10-year period prior to study year
         inclin_down, sri, tri, twi_fd8, tcws,      # environmental data
         shrub_cover,
         graminoid_cover) %>% 
  names()

preds_plot_data <- env_cov_bio %>% 
  
  # convert site, isocline & plotgroup to factors
  mutate(site = as.factor(site)) %>% 
  mutate(site_alt_id = factor(site_alt_id, levels = c(paste(rep(1, 3), c("20", "100", "200"), sep = "_"),
                                                      paste(rep(2, 3), c("20", "100", "200"), sep = "_"),
                                                      paste(rep(3, 5), c("20", "100", "200", "300", "400"), sep = "_"),
                                                      paste(rep(4, 6), c("20", "100", "200", "300", "400", "500"), sep = "_"),
                                                      paste(rep(5, 6), c("20", "100", "200", "300", "400", "500"), sep = "_")))) %>% 
  mutate(plotgroup = as.factor(plotgroup)) %>% 
  
  select(site, site_alt_id, predictors_set) %>% 
  
  # pivot to long format
  pivot_longer(cols = predictors_set,
               names_to = "predictor",
               values_to = "value") %>% 
  
  # convert predictor col to factor
  mutate(predictor = as.factor(predictor)) %>% 
  
  # rename predictors
  mutate(predictor = fct_recode(predictor,
                                "mean\nsummer\ntemperature [°C]" = "tempjja_ts_30",
                                "maximum\nsummer\ntemperature [°C]" = "tempmax_ts_30",
                                "minimum\nwinter\ntemperature [°C]" = "tempmin_ts_30",
                                "annual\ntemperature\nvariability [°C]" = "tempcont_ts_30",
                                "cumulative\nsummer\nprecipitation [mm]" = "precipjja_ts_30",
                                "cumulative\nwinter-spring\nprecipitation [mm]" = "precipjfmam_ts_30",
                                "cumulative\nspring\nprecipitation [mm]" = "precipmam_ts_30",
                                "slope angle [°]" = "inclin_down",
                                "Solar\nRadiation\nIndex" = "sri",
                                "Terrain\nRuggedness\nIndex" = "tri",
                                "Topographic\nWetness\nIndex" = "twi_fd8",
                                "Tasseled-cap\nWetness\nIndex" = "tcws",
                                "total\nshrub cover" = "shrub_cover",
                                "graminoid\ncover" = "graminoid_cover"),
         predictor = fct_relevel(predictor,
                                 "mean\nsummer\ntemperature [°C]",
                                 "maximum\nsummer\ntemperature [°C]",
                                 "minimum\nwinter\ntemperature [°C]",
                                 "annual\ntemperature\nvariability [°C]",
                                 "cumulative\nsummer\nprecipitation [mm]",
                                 "cumulative\nwinter-spring\nprecipitation [mm]",
                                 "cumulative\nspring\nprecipitation [mm]",
                                 "slope angle [°]",
                                 "Solar\nRadiation\nIndex",
                                 "Terrain\nRuggedness\nIndex",
                                 "Topographic\nWetness\nIndex",
                                 "Tasseled-cap\nWetness\nIndex",
                                 "total\nshrub cover",
                                 "graminoid\ncover")) %>% 
  
  # group by site & isocline 
  group_by(site, site_alt_id)


# >> plot (climatic predictors) ----
predictors_set_clim_long <- c("mean\nsummer\ntemperature [°C]",
                              "maximum\nsummer\ntemperature [°C]",
                              "minimum\nwinter\ntemperature [°C]",
                              "annual\ntemperature\nvariability [°C]",
                              "cumulative\nsummer\nprecipitation [mm]",
                              "cumulative\nwinter-spring\nprecipitation [mm]",
                              "cumulative\nspring\nprecipitation [mm]")

(nuuk_preds_clim_gradient_plot <- ggplot(preds_plot_data %>% 
                                           filter(predictor %in% predictors_set_clim_long),
                                         
                                         aes(x = site_alt_id, 
                                             y = value, 
                                             fill = site)) + 
    
    # draw boxplots of values
    geom_boxplot() + 
    
    # split by taxon
    facet_grid(rows = vars(predictor), scales = "free_y") +
    
    # scale_fill_manual() +
    theme_bw() +
    xlab("site / isocline") +
    theme(strip.text.y = element_text(face = "italic",
                                      size = 14),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.2)),
          axis.text.y = element_text(size = 12),
          axis.title = element_text(size = rel(1.5),
                                    face = "bold"),
          legend.title = element_text(size = 15),
          legend.text = element_text(size = 14)))

# ¨¨ save plot ----
# save_plot(file.path("analyses_main_twi", "figures", "nuuk_shrub_drivers_gradient", "nuuk_shrub_drivers_preds_clim_gradient.png"),
#           nuuk_preds_clim_gradient_plot, base_height = 15, base_aspect_ratio = 0.8)


# >> plot (environmental predictors) ----
predictors_set_env_long <- c("slope angle [°]",
                             "Solar\nRadiation\nIndex",
                             "Terrain\nRuggedness\nIndex",
                             "Topographic\nWetness\nIndex",
                             "Tasseled-cap\nWetness\nIndex",
                             "total\nshrub cover",
                             "graminoid\ncover")

(nuuk_preds_env_gradient_plot <- ggplot(preds_plot_data %>% 
                                          filter(predictor %in% predictors_set_env_long),
                                        
                                        aes(x = site_alt_id, 
                                            y = value, 
                                            fill = site)) + 
    
    # draw boxplots of values
    geom_boxplot() + 
    
    # split by taxon
    facet_grid(rows = vars(predictor), scales = "free_y") +
    
    # scale_fill_manual() +
    theme_bw() +
    xlab("site / isocline") +
    theme(strip.text.y = element_text(face = "italic",
                                      size = 14),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.2)),
          axis.text.y = element_text(size = 12),
          axis.title = element_text(size = rel(1.5),
                                    face = "bold"),
          legend.title = element_text(size = 15),
          legend.text = element_text(size = 14)))

# ¨¨ save plot ----
# save_plot(file.path("analyses_main_twi", "figures", "nuuk_shrub_drivers_gradient", "nuuk_shrub_drivers_preds_env_gradient.pdf"),
#           nuuk_preds_env_gradient_plot, base_height = 15, base_aspect_ratio = 0.8)


# >> plot (final set of predictors) ----
predictors_set_final_long <- c("mean\nsummer\ntemperature [°C]",
                               "annual\ntemperature\nvariability [°C]",
                               "cumulative\nsummer\nprecipitation [mm]",
                               "Solar\nRadiation\nIndex",
                               "Terrain\nRuggedness\nIndex",
                               "Topographic\nWetness\nIndex",
                               "Tasseled-cap\nWetness\nIndex",
                               "total\nshrub cover",
                               "graminoid\ncover")

(nuuk_preds_final_gradient_plot <- ggplot(preds_plot_data %>% 
                                            filter(predictor %in% predictors_set_final_long),
                                          
                                          aes(x = site_alt_id, 
                                              y = value, 
                                              fill = site)) + 
    
    # draw boxplots of values
    geom_boxplot() + 
    
    # split by taxon
    facet_grid(rows = vars(predictor), scales = "free_y") +
    
    # scale_fill_manual() +
    theme_bw() +
    xlab("site / isocline") +
    theme(strip.text.y = element_text(face = "italic",
                                      size = 14),
          axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.2)),
          axis.text.y = element_text(size = 12),
          axis.title = element_text(size = rel(1.5),
                                    face = "bold"),
          legend.title = element_text(size = 15),
          legend.text = element_text(size = 14)))

# ¨¨ save plot ----
# save_plot(file.path("analyses_main_twi", "figures", "nuuk_shrub_drivers_gradient", "nuuk_shrub_drivers_preds_final_gradient.pdf"),
#           nuuk_preds_final_gradient_plot, base_height = 16, base_aspect_ratio = 0.8)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨-----


# Fig. S3) Species abundance along the gradient ----

# >> load data ----

env_cov_bio <- read.csv(file.path("data", "processed", "nuuk_env_cover_plots.csv"), 
                        header = T)

# >> compile plot ----

(nuuk_spec_abundance_plot <- ggplot(env_cov_bio %>% 
                                      
                                      # make site a factor
                                      mutate(site = as.factor(site)) %>% 
                                      mutate(site_alt_id = factor(site_alt_id, 
                                                                  levels = c(paste(rep(1, 3), c("20", "100", "200"), 
                                                                                   sep = "_"),
                                                                             paste(rep(2, 3), c("20", "100", "200"), 
                                                                                   sep = "_"),
                                                                             paste(rep(3, 5), c("20", "100", "200", "300", "400"), 
                                                                                   sep = "_"),
                                                                             paste(rep(4, 6), c("20", "100", "200", "300", "400", "500"), 
                                                                                   sep = "_"),
                                                                             paste(rep(5, 6), c("20", "100", "200", "300", "400", "500"), 
                                                                                   sep = "_")))) %>% 
                                      # group by site and isocline
                                      group_by(site, site_alt_id), 
                                    
                                    aes(x = site_alt_id, 
                                        y = cover, 
                                        fill = site)) + 
   
   # draw boxplots of cover
   geom_boxplot() + 
   
   # split by taxon
   facet_grid(rows = vars(taxon)) +
   
   # scale_fill_manual() +
   theme_bw() +
   xlab("site / isocline") +
   theme(strip.text.y = element_text(face = "italic"),
         axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = rel(1.2)),
         axis.title = element_text(size = rel(1.2))))

# >> save plot ----
# save_plot(file.path("analyses_main_twi", "figures", "nuuk_shrub_drivers_species_abundance_gradient.png"),
#           nuuk_spec_abundance_plot, base_height = 18, base_aspect_ratio = 0.8)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ ----


# Fig. S6.1) Effect size plots (TWI) ----

# >> load function ----
source(file = file.path("scripts", "JvO", "plotting_functions", "effectsize_plot.R"))


# >> load data ----

# species
# load model output data
model_outputs_focal_species <- file.path("data", "processed", "model_outputs", "species_twi", list.files(path = file.path("data", "processed", "model_outputs", "species_twi"), pattern = "*2.Rdata"))
for (model_output in model_outputs_focal_species){
  load(model_output)
}

# groups
# load model output data
model_outputs_groups <- file.path("data", "processed", "model_outputs", "groups_twi", list.files(path = file.path("data", "processed", "model_outputs", "groups_twi"), pattern = "*2.Rdata"))
for (model_output in model_outputs_groups){
  load(model_output)
}


# >> plot graphs ----
(es_plot_AllShr <- effectsize_plot_twi(species = "all shrubs", plot_width = 10.5))
(es_plot_AllEve <- effectsize_plot_twi(species = "evergreen shrubs", plot_width = 10.5))
(es_plot_AllDec <- effectsize_plot_twi(species = "deciduous shrubs", plot_width = 9.5))
(es_plot_BetNan <- effectsize_plot_twi(species = "Betula nana", plot_width = 11.5))
(es_plot_EmpNig <- effectsize_plot_twi(species = "Empetrum nigrum", plot_width = 11.5))
(es_plot_RhoGro <- effectsize_plot_twi(species = "Rhododendron groenlandicum", plot_width = 14.5))
(es_plot_SalGla <- effectsize_plot_twi(species = "Salix glauca", plot_width = 11.5))
(es_plot_VacUli <- effectsize_plot_twi(species = "Vaccinium uliginosum", plot_width = 11.5))

# make y label
ylabel_es <- ggdraw() +
  draw_label("Effect size (scaled)",
             vjust = 0,
             angle = 90,
             size = 20,
             fontface = "bold")

# draw extra plot to extract legend from
xplot <- ggplot(data = data.frame(x = c(1:6),
                                  y = c(1:6),
                                  z = c(rep("significant     ",2), rep("marginal     ",2),rep("n.s.",2))) %>% 
                  mutate(z = ordered(z, levels = c("significant     ", "marginal     ", "n.s."))),
                aes(group = z)) +
  geom_line(aes(x = x,
                y = y,
                colour = z),
            size = 1) +
  geom_ribbon(aes(x = x,
                  ymin = y-.5,
                  ymax = y+.5,
                  fill = z),
              alpha = .2) +
  scale_colour_manual(values = c(theme_darkgreen, theme_purple, "black")) +
  scale_fill_manual(values = c(theme_darkgreen, theme_purple, "black")) +
  labs(colour = "significance level     ",
       fill = "significance level     ") +
  guides(colour = guide_legend(nrow = 1)) +
  theme(legend.position = "bottom",
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 17))

# extract legend
legend_hor <- get_legend(xplot)


# >> save plot ----
# # ¨¨¨¨4x2 grid (vertical layout) ----
# (nuuk_effect_size_plot_grid_ver_twi <- plot_grid(es_plot_AllShr + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()),
#                                                  es_plot_AllEve + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()),
#                                                  es_plot_AllDec + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()),
#                                                  es_plot_EmpNig + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()), 
#                                                  es_plot_RhoGro + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()), 
#                                                  es_plot_BetNan + theme(legend.position = "none", 
#                                                                         axis.title = element_blank()), 
#                                                  es_plot_VacUli + theme(legend.position = "none",
#                                                                         axis.title = element_blank()),
#                                                  es_plot_SalGla + theme(legend.position = "none",
#                                                                         axis.title = element_blank()),
#                                                  labels = c("a)", "b)", "c)", "d)", "e)", "f)", "g)", "h)"),
#                                                  label_size = 20,
#                                                  label_fontface = "plain",
#                                                  label_x = c(.05, .05, .05, .05, .05, .05, .05, .05),
#                                                  ncol = 2,
#                                                  axis = "lt",
#                                                  align = "hv"))
# 
# # save plot
# # save_plot(file.path("figures", "nuuk_shrub_drivers_effect_size_panels_vert_prettylabels_twi.png"),
# #           nuuk_effect_size_plot_grid_ver_twi, base_height = 22, base_aspect_ratio = .6)


# ¨¨¨¨3x3 grid (horizontal layout) ----
(es_plots_row_twi <- plot_grid(ylabel_es,
                               plot_grid(es_plot_AllShr,
                                         es_plot_AllEve,
                                         es_plot_AllDec,
                                         es_plot_EmpNig, 
                                         es_plot_RhoGro, 
                                         es_plot_BetNan, 
                                         es_plot_VacUli,
                                         es_plot_SalGla,
                                         labels = c("a)", "b)", "c)", "d)", "e)", "f)", "g)", "h)"),
                                         label_size = 20,
                                         label_fontface = "bold",
                                         label_x = c(rep(.02, 8)),
                                         ncol = 3,
                                         axis = "lt",
                                         align = "hv"),
                               rel_widths = c(0.03, 1)))

# combine with legend
(nuuk_effect_size_plot_grid_hor_twi <- plot_grid(es_plots_row_twi,
                                                 legend_hor,
                                                 ncol = 1,
                                                 rel_heights = c(1, 0.07)))

# save plot
save_plot(file.path("analyses_main_twi", "figures", "FigS6.1_effect_sizes_twi.png"),
          nuuk_effect_size_plot_grid_hor_twi, base_height = 18, base_aspect_ratio = 1.3)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨-----


# Fig. S6.2ff) Groups: cover and predictions for all predictors ----

# >> load function ----
source(file = file.path("scripts", "JvO", "plotting_functions", "prediction_plot_twi.R"))


# >> load data ----
model_outputs_groups <- file.path("data", "processed", "model_outputs", "groups_twi", list.files(path = file.path("data", "processed", "model_outputs", "groups"), 
                                                                                             pattern = "*.Rdata"))
for (model_output in model_outputs_groups){
  load(model_output)
}
# load input data
load(file = file.path("data", "processed", "model_input_data_twi", "shrub_gradient_group.datasets.Rdata"))


# >> plot graphs ----
(nuuk_prediction_plot_AllShr <- prediction_plots_groups(fgroup = "all shrubs"))
(nuuk_prediction_plot_AllEve <- prediction_plots_groups(fgroup = "evergreen shrubs"))
(nuuk_prediction_plot_AllDec <- prediction_plots_groups(fgroup = "deciduous shrubs"))

# >> save plots ----
prediction_plots_path <- file.path("analyses_main_twi", "figures", "prediction_plots_twi")
save_plot(file.path(prediction_plots_path, "prediction_plot_AllShr.png"),
          nuuk_prediction_plot_AllShr, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_AllEve.png"),
          nuuk_prediction_plot_AllEve, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_AllDec.png"),
          nuuk_prediction_plot_AllDec, base_height = 15, base_aspect_ratio = 1)


# ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ ----


# Fig. S6.5ff) Species: cover and predictions for all predictors (TWI) ----

# >> load function ----
source(file = file.path("scripts", "JvO", "plotting_functions", "prediction_plot_twi.R"))


# >> load data ----
# load model outputs
model_outputs_species <- file.path("data", "processed", "model_outputs", "species_twi", list.files(path = file.path("data", "processed", "model_outputs", "species_twi"), pattern = "*.Rdata"))
for (model_output in model_outputs_species){
  load(model_output)
}
# load input data
load(file = file.path("data", "processed", "model_input_data_twi", "shrub_gradient_species.datasets.Rdata"))


# >> plot graphs ----
(nuuk_prediction_plot_BetNan <- prediction_plots_species(species = "Betula nana"))
(nuuk_prediction_plot_CasTet <- prediction_plots_species(species = "Cassiope tetragona"))
(nuuk_prediction_plot_EmpNig <- prediction_plots_species(species = "Empetrum nigrum"))
(nuuk_prediction_plot_PhyCae <- prediction_plots_species(species = "Phyllodoce caerulea"))
(nuuk_prediction_plot_RhoGro <- prediction_plots_species(species = "Rhododendron groenlandicum"))
(nuuk_prediction_plot_RhoTom <- prediction_plots_species(species = "Rhododendron tomentosum"))     
(nuuk_prediction_plot_SalArc <- prediction_plots_species(species = "Salix arctophila"))
(nuuk_prediction_plot_SalGla <- prediction_plots_species(species = "Salix glauca"))
(nuuk_prediction_plot_VacUli <- prediction_plots_species(species = "Vaccinium uliginosum"))

# >> save plots ----
prediction_plots_path <- file.path("analyses_main_twi", "figures", "prediction_plots_twi")
save_plot(file.path(prediction_plots_path, "prediction_plot_BetNan.png"),
          nuuk_prediction_plot_BetNan, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_CasTet.png"),
          nuuk_prediction_plot_CasTet, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_EmpNig.png"),
          nuuk_prediction_plot_EmpNig, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_PhyCae.png"),
          nuuk_prediction_plot_PhyCae, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_RhoGro.png"),
          nuuk_prediction_plot_RhoGro, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_RhoTom.png"),
          nuuk_prediction_plot_RhoTom, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_SalArc.png"),
          nuuk_prediction_plot_SalArc, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_SalGla.png"),
          nuuk_prediction_plot_SalGla, base_height = 15, base_aspect_ratio = 1)
save_plot(file.path(prediction_plots_path, "prediction_plot_VacUli.png"),
          nuuk_prediction_plot_VacUli, base_height = 15, base_aspect_ratio = 1)



# ________________________________________ ----
# ________________________________________ ----
