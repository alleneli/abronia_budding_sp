###Create input/data folders###
#dir.create(path = "Data")
#dir.create(path = "Output")

###Install packages###
#install.packages("terra")
#install.packages("geodata") ### SEE BELOW ###
#install.packages("predicts")
#install.packages("readr")
#install.packages("ggplot2")
#install.packages(("rworldmap"))


###Installing 'geodata' from github using 'remotes' because CRAN archived it###
###THIS MAY BE FIXED IN THE FUTURE, maybe it will work the normal/easy way again###
#install.packages("remotes")
#library(remotes)
#remotes::install_github("rspatial/geodata")

###Set Working Dir###
setwd("C:/Users/eja56/Documents/R_Abronia_Niche_Model")

###Library packages after installation###
library(terra)
library(geodata)
library(predicts)
library(readr)
library(rworldmap)


###Pull bioclimate variables### 

bioclim_data <- worldclim_global(var = "bio",
                                res = 0.5,
                                path = "data/")




#####################
###AURITA DATA SET###
#####################
###We will pull 19 climate varibales for aurita sepparaetly and then merge it with the villosa dataset later,
###this is because we want to reduce some sample bias in the villosa dataset,
###we can't do that with the aurita dataset as it is too small###


###Read in observational data for var. aurita###
###This used a combined dataset of GBIF and CCH2 occurrence data
###I had previously removed any erroneous occurrence data myself###
aur_data <- read.csv(file = "Data/A_vil_aur_combine.csv")

###Determine geographic extent of data###
max_lat <- ceiling(max(aur_data$decimalLatitude))
min_lat <- floor(min(aur_data$decimalLatitude))
max_lon <- ceiling(max(aur_data$decimalLongitude))
min_lon <- floor(min(aur_data$decimalLongitude))

# Store boundaries in a single extent object
aur_geographic_extent <- ext(x = c(min_lon, max_lon, min_lat, max_lat))


# Download data with geodata's world function to use for our base map

# Generate a world map with a resolution of 3 (low resolution)
world_map <- world(resolution = 3, path = "data/")


# Crop the map to our area of interest
aur_map <- crop(x = world_map, y = aur_geographic_extent)

# Plot the base map
plot(aur_map,
     axes = TRUE,
     col = "grey95")


# Add the points for individual observations
points(x = aur_data$decimalLongitude,
       y = aur_data$decimalLatitude,
       col = "olivedrab",
       pch = 20,
       cex = 0.75)


# Make an extent that is 25% larger
aur_sample_extent <- aur_geographic_extent * 1.25

# Crop bioclim data to desired extent
aur_bioclim_data <- crop(x = bioclim_data, y = sample_extent)

# Plot the first of the bioclim variables to check on cropping
plot(aur_bioclim_data[[1]])

#Look at climate data
head(aur_bioclim_data)

# Pull out coordinate columns, x (longitude) first, then y (latitude) from abronia data
aur_presence <- aur_data[, c("decimalLongitude", "decimalLatitude")]

# Add column indicating presence
aur_presence$pa <- 2

# Reality check on data
head(aur_presence)

# Add climate data
aur_bioclim_extract <- extract(x = aur_bioclim_data,
                           y = aur_presence[, c("decimalLongitude", "decimalLatitude")],
                           ID = FALSE) # No need for an ID column

# Add the point and climate datasets together
aur_points_climate <- cbind(aur_presence, aur_bioclim_extract)


# Remove rows with NA values
num_rows_before <- nrow(aur_points_climate)
points_climate <- na.omit(aur_points_climate)
num_rows_after <- nrow(aur_points_climate)

# Calculate the number of removed rows
num_removed_rows <- num_rows_before - num_rows_after

# List the number of removed rows
cat("Number of removed rows:", num_removed_rows, "\n")
cat("Number of removed rows:", num_rows_after, "\n")

###IMPORTANT###
# The number of remaining rows is important, this will be used in our niceOverPlot script later. 
# I like to keep track of them, but I found a way to do it a bit easier as you'll see later###

###########################
##SAVE DATA FRAME AS CSV###
###########################
readr::write_csv(aur_points_climate, 'Aur_points_climate.csv')
data1 <- read.csv("Aur_points_climate.csv")




######################
###VILLOSA DATA SET###
######################
###We will now do the same thing, but account for sampling bias,
###and add 10,000 pseudo-absence points for an area encompassing the ranges of aurita and villosa###


###Read in observational data for var. villosa###
###This used a combined dataset of GBIF and CCH2 occurrence data
###I had previously removed any erroneous occurrence data myself###

vil_data <- read.csv(file = "Data/A_vil_vil_combine.csv")
obs_data <- vil_data

###if you need to remove NA's from lat/lon columns###
obs_data <- obs_data[!is.na(obs_data$decimalLatitude),]

### Remove duplicate observations ###
dups <- duplicated(obs_data[, c('decimalLatitude', 'decimalLongitude')])

# number of duplicates
cat("Number of duplicates before removal:", sum(dups), "\n")

# keep the records that are _not_ duplicated
obs_data <- obs_data[!dups,]

### Randomly remove points within 0.1 latitude or longitude of each other ###
library(sp)
library(raster)

# Create a spatial points object
points <- SpatialPoints(coords = obs_data[,c("decimalLongitude", "decimalLatitude")])

# Create a distance matrix
dist_matrix <- pointDistance(points, lonlat = TRUE)

# Threshold distance (in degrees) within which points will be considered "too close"
threshold_distance <- 0.1

# Get indices of points to remove
remove_indices <- which(dist_matrix < threshold_distance, arr.ind = TRUE)

# Remove one of the points from each pair of "too close" points
for (i in 1:nrow(remove_indices)) {
  row_to_remove <- remove_indices[i, 1]
  obs_data <- obs_data[-row_to_remove,]
}

# Output the number of removed points
cat("Number of points removed:", nrow(obs_data) - sum(dups), "\n")

# Output the number of remaining points
cat("Number of remaining points:", nrow(obs_data), "\n")

###IMPORTANT###
# The number of remaining rows is important, this will be used in our niceOverPlot script later. 
# I like to keep track of them, but I found a way to do it a bit easier as you'll see later###

# Save the cleaned data as a CSV file just for good measure
write.csv(obs_data, file = "Villosa_occurence_climate_pseudo.csv", row.names = FALSE)




###Determine geographic extent of data###
###You will have to customize this for your own data###
max_lat <- ceiling(max(37))
min_lat <- floor(min(32))
max_lon <- ceiling(max(-113))
min_lon <- floor(min(obs_data$decimalLongitude))

# Store boundaries in a single extent object
geographic_extent <- ext(x = c(min_lon, max_lon, min_lat, max_lat))


# Download data with geodata's world function to use for our base map

# Generate a world map with a resolution of 3 (low resolution)
world_map <- world(resolution = 3, path = "data/")


# Crop the map to our area of interest
my_map <- crop(x = world_map, y = geographic_extent)

# Plot the base map
plot(my_map,
     axes = TRUE,
     col = "grey95")


# Add the points for individual observations
points(x = obs_data$decimalLongitude,
       y = obs_data$decimalLatitude,
       col = "olivedrab",
       pch = 20,
       cex = 0.75)


# Make an extent that is 25% larger
sample_extent <- geographic_extent * 1.25

# Crop bioclim data to desired extent
bioclim_data <- crop(x = bioclim_data, y = sample_extent)

# Plot the first of the bioclim variables to check on cropping
plot(bioclim_data[[1]])

# Set the seed for the random-number generator to ensure results are similar
set.seed(20210707)

# Randomly sample points (same number as our observed points)
background <- spatSample(x = bioclim_data,
                         size = 10000, # generate 10,000 pseudo-absence points
                         values = FALSE, # don't need values
                         na.rm = TRUE, # don't sample from ocean
                         xy = TRUE) # just need coordinates

# Look at first few rows of background
head(background)

# Plot the base map
plot(my_map,
     axes = TRUE,
     col = "grey95")

# Add the background points
points(background,
       col = "grey30",
       pch = 1,
       cex = 0.75)

# Add the points for individual observations
points(x = obs_data$decimalLongitude,
       y = obs_data$decimalLatitude,
       col = "olivedrab",
       pch = 20,
       cex = 0.75)

# Pull out coordinate columns, x (longitude) first, then y (latitude) from abronia data
presence <- obs_data[, c("decimalLongitude", "decimalLatitude")]

# Add column indicating presence
presence$pa <- 1

# Convert background data to a data frame
absence <- as.data.frame(background)

# Update column names so they match presence points
colnames(absence) <- c("decimalLongitude", "decimalLatitude")

# Add column indicating absence
absence$pa <- 0

# Join data into single data frame
all_points <- rbind(presence, absence)

# Reality check on data
head(all_points)

# Add climate data
bioclim_extract <- extract(x = bioclim_data,
                           y = all_points[, c("decimalLongitude", "decimalLatitude")],
                           ID = FALSE) # No need for an ID column

# Add the point and climate datasets together
points_climate <- cbind(all_points, bioclim_extract)


# Remove rows with NA values
num_rows_before <- nrow(points_climate)
points_climate <- na.omit(points_climate)
num_rows_after <- nrow(points_climate)

# Calculate the number of removed rows
num_removed_rows <- num_rows_before - num_rows_after

# List the number of removed rows
cat("Number of removed rows:", num_removed_rows, "\n")
cat("Number of removed rows:", num_rows_after, "\n")


###########################
##SAVE DATA FRAME AS CSV###
###########################
readr::write_csv(points_climate, 'Vil_PseudoAbs_points_climate_SAMPLE_BIAS.csv')
data2 <- read.csv("Vil_PseudoAbs_points_climate_SAMPLE_BIAS.csv")

###############################################
##MERGE THE TWO CSV's FOR AURITA AND VILLOSA###
###############################################

# Concatenate the datasets
combined_data <- rbind(data1, data2)

# Write the combined data to a new CSV file
write.csv(combined_data, "Vil_Aur_concat_pseudoabs_points_climate_final.csv", row.names = FALSE)

###############
###IMPORTANT###
###############
#niceOverPlot and ecospat need to know the exact number of samples of each species, and they need to be in a specific order.
#with this script I used the pa column to keep track of everything, 2 = aurita, 1 = villosa, and 0 = pseudo-abscence.
#You will want to manually organize your datasheet in excel using the filter tool so that the pa column is from highest to lowest,
#that way aurita (2) will be first, villosa will be second (1), and pseudo-abscence last (0).
#Once it is in this order you will want to count how many samples you have of each species,
#For example: to do this for aurita highlight all the 2's in the pa column and it will tell you the 'count' at the bottom of the screen
#Here we have 191 for aurita, 528 for villosa and of course 10,000 pseudo-absence.
#Keep track of these numbers and their order! It is needed for niceOverPlot and ecospat!

#Tis is the dataset that we will use for ecospat, so save it! 
#But for niceOverPlot we need to modify it some more, so make a copy and then do the following...

#Now that we've kept track of all the pa column numbers and ensured that the species/pseudo-abscence points are in the proper order,
#we are going to delete the pa column, and the decimalLatitude and Longitude columns, and add a new column that is an ascending 'count' for each row, 
#so starting with row 2 (right after the headers) the count will be 1, for row 3 it will be 2, row 4 will be 3 and so on...
#Our total count for this dataset spans from 1 to 10,719.
#this is easy to do by filling the first couple rows in the column, and then just highlighting them and draging the corner
#of the highlighted box all the way to the bottom.
#Now the data is ready for niceOverPlot!
#if you are confused see: https://www.r-bloggers.com/2017/05/niceoverplot-or-when-the-number-of-dimensions-does-matter/



