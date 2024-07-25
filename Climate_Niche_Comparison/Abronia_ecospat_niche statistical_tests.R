###For ecospat we want a csv of lat/lon occurrence data, 19 climate variables for both species. I included a 'species' column as well were villosa is '1' and aurita is '2'###


#install.packages("ecospat")
#install.packages("FactoMineR")
#install.packages("factoextra")
#install.packages("missMDA")

setwd("C:/Users/eja56/Documents/R_Abronia_Niche_Model")


# Load necessary libraries
library(ecospat)
library(missMDA)
library(FactoMineR)
library(factoextra)

# Load the dataset
data <- read.csv("ecospat_vil_aur_climate_occ.csv")

# Separate the climate variables and species occurrence data
climate_data <- data[, 4:22]  # Assuming columns 4 to 22 are climate variables
species_data <- data$species  # Assuming the species column is named 'species'

# Run PCA on the climate variables
pca_result <- PCA(climate_data, graph = FALSE)

# Visualize PCA results
fviz_pca_ind(pca_result, geom.ind = "point", col.ind = as.factor(species_data), addEllipses = TRUE, legend.title = "Species")

# Extract the PCA scores for the first two principal components
scores <- pca_result$ind$coord[, 1:2]

# Create presence points for each species
presence_1 <- scores[species_data == 1, ]
presence_2 <- scores[species_data == 2, ]

# Create the background data (all points)
background <- scores

# Create niche objects for each species using ecospat.grid.clim.dyn
grid_clim_1 <- ecospat.grid.clim.dyn(glob = background, glob1 = presence_1, sp = presence_1, R = 100)
grid_clim_2 <- ecospat.grid.clim.dyn(glob = background, glob1 = presence_2, sp = presence_2, R = 100)

###IMPORTANT###
#Run the following two tests with rep = 10 when you are just testing your data,
#rep = 1000 is recommended for your final run but will take a very long time.

# Perform the niche equivalency test
eq_test <- ecospat.niche.equivalency.test(grid_clim_1, grid_clim_2, rep = 1000, overlap.alternative = "lower")

# Perform the niche similarity test
sim_test <- ecospat.niche.similarity.test(grid_clim_1, grid_clim_2, rep = 1000, rand.type=1)

# plot niches
ecospat.plot.niche(grid_clim_1, title = "Species 1 Niche")
ecospat.plot.niche(grid_clim_2, title = "Species 2 Niche")

# Calculate niche overlap
niche_overlap <- ecospat.niche.overlap(grid_clim_1, grid_clim_2, cor = FALSE)$D

# Print the results
print(eq_test)
print(sim_test)
###THIS IS YOUR 'D' STATISTIC###
print(niche_overlap)

# Visualize niche overlap for fun, we can see here why we use niceOverPlot instead
ecospat.plot.niche.dyn(grid_clim_1, grid_clim_2, quant = 0.25, interest = "dynamic", title = "Niche Overlap")

###YOU WANT THE P-VALUES FROM EACH OF THESE PLOTS###
ecospat.plot.overlap.test(eq_test, "D", "Equivalency")
ecospat.plot.overlap.test(sim_test, "D", "Similarity")


