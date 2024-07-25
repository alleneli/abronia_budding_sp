###INSTALL PACKAGES###
#install.packages("ecospat")
#install.packages("ggplot2")
#install.packages("grid")
#install.packages("gridextra")
#install.packages("stable")
#install.packages("RColorBrewer")
#install.packages("ade4")
#install.packages("corrplot")
#install.packages("ggbiplot")
#install.packages("reshape2")

###SET WORKING DIRECTORY###
setwd("C:/Users/eja56/Documents/R_Abronia_Niche_Model")

library(ade4)
library(terra)
library(ecospat)
library(ggplot2)
library(grid)
library(gridExtra)
library(gtable)
library(RColorBrewer) 
library(ggplot2)
library(gridExtra)
library(grid)
library(readr)
library(corrplot)  
library(ggbiplot)
library(reshape2)

###############
###IMPORTANT###
###############
#The code to to create the niceOverPlot function is at the end of this script.
#Run it first! It is just very long so I like leaving it out of the way.
#There are some notes there for manipulating the script to fit your needs - and making it pretty!

### TEST USING JAVI'S DATA ###
#This is using the test data from the authors of niceOverPlot, just to check that the function works
data.test = read.csv("data_Ph_Pl.csv")
pca_test = dudi.pca(df = na.omit(data.test, center = T, scale = T, scannf = F, nf = 2), scannf = FALSE, nf = 2)
niceOverPlot(pca_test, n1=1125 , n2= 44)

###################################################
### ABRONIA ALL 19 CLIMATE VARIABLES IN ONE PCA ###
###################################################
#If you want to just run this without first removing some of the 19 variables.
#It's nice to see this, but we should remove all of the variables that share high correlation coefficients 
#(some of the climate variables are going to be very similar and will therefore reduce the quality if our output figure)
data_Abronia <- read.csv("Vil_Aur_concat_pseudoabs_points_climate_final.csv", header = TRUE) 
pca_Abronia = dudi.pca(df = na.omit(data_Abronia, center = T, scale = T, scannf = F, nf = 2), scannf = FALSE, nf = 2)
niceOverPlot(pca_Abronia, n1=191 , n2= 528) 

##########################################################
###See which variables are represented by each pca axis###
##########################################################
# Perform PCA
pca_Abronia = dudi.pca(df = na.omit(data_Abronia), center = TRUE, scale = TRUE, scannf = FALSE, nf = 2)

# View a summary of the PCA result
summary(pca_Abronia)

# Extract the loadings (contributions of each variable to each PC)
loadings = pca_Abronia$c1

#Print the loadings, THIS IS THE OUTPUT YOU WANT
print(loadings)

# Alternatively, you can plot the loadings to visualize them
library(factoextra)
fviz_pca_var(pca_Abronia)





###OPTIONAL###
### FILTERING OUT VARIABLES WITH HIGH CORRELATION COEFFICIENTS ###
# Read your dataset into R (replace "your_dataset.csv" with the actual filename)
data_Abronia <- read.csv("Vil_Aur_Only_all_19.csv", header = TRUE) 
data_Abronia <- na.omit(data_Abronia)
# Calculate the correlation matrix
correlation_matrix <- cor(data_Abronia[, -1], use = "pairwise.complete.obs")  # Assuming the first column is not a variable

# Find highly correlated pairs
highly_correlated_pairs <- which(abs(correlation_matrix) > 0.7 & correlation_matrix != 1, arr.ind = TRUE)
head(correlation_matrix)
print(highly_correlated_pairs)
# Remove one variable from each highly correlated pair
variables_to_remove <- c()
for (i in 1:nrow(highly_correlated_pairs)) {
  var1 <- rownames(correlation_matrix)[highly_correlated_pairs[i, 1]]
  var2 <- colnames(correlation_matrix)[highly_correlated_pairs[i, 2]]
  # Choose which variable to remove based on some criteria (e.g., variability)
  # Here, we'll choose the variable with lower variability (standard deviation)
  if (sd(data_Abronia[[var1]]) > sd(data_Abronia[[var2]])) {
    variables_to_remove <- c(variables_to_remove, var2)
  } else {
    variables_to_remove <- c(variables_to_remove, var1)
  }
}

# Remove the identified variables from your dataset
data_Abronia_filtered <- data_Abronia[, !colnames(data_Abronia) %in% variables_to_remove]

# Proceed with your analysis using the remaining variables in your_dataset_filtered
head(data_Abronia_filtered)
pca_Abronia_filtered = dudi.pca(df = na.omit(data_Abronia_filtered, center = T, scale = T, scannf = F, nf = 2), scannf = FALSE, nf = 2)
niceOverPlot(pca_Abronia_filtered, n1= 528 , n2= 191) 

### OPTIONAL FOR FILTERED DATA###
###See which variables are represented by each pca axis###

# Perform PCA
pca_Abronia_filtered = dudi.pca(df = na.omit(data_Abronia_filtered, center = T, scale = T, scannf = F, nf = 2), scannf = FALSE, nf = 2)

# View a summary of the PCA result
summary(pca_Abronia_filtered)

# Extract the loadings (contributions of each variable to each PC)
loadings = pca_Abronia_filtered$c1
print(loadings)

# Alternatively, you can plot the loadings to visualize them
library(factoextra)
fviz_pca_var(pca_Abronia_filtered)







###########################
###niceOverPlot FUNCTION###
###########################
###RUN THIS FIRST!

###IMPORTANT###
###If you want to play around with how the output environmental space looks, change the bandwidth (bw) and bins (b) in the first line of the of the function
#they are set to NULL by default, but I used bw = 2 and b = 14

###COLORS AND UPDATE FROM ORIGINAL FUNCTION###
# The original script used this color palette "" scale_fill_brewer(palette = "Set1") "", I changed it to specific colors, feel free to change them as you see fit
# i.e. "" scale_fill_manual(values = c("#ab82ff", "#00ffff")) "" to match the color scheme of my other figures. 
# This may cause problems if you use more than 2 species, if that is the case you can try the original niceOverPlot function:
#https://www.r-bloggers.com/2017/05/niceoverplot-or-when-the-number-of-dimensions-does-matter/
#If you do this you will have to update his script to work with more recent versions of R
#the biug change I made was changing the second 'if' from this:
#if (class(sc1)==c("pca","dudi") && class(sc2)==c("pca","dudi")) {
#to this:
# if (inherits(sc1, c("pca", "dudi")) && inherits(sc2, c("pca", "dudi"))) {





niceOverPlot <- function(sc1, sc2 = NULL, n1 = NULL, n2 = NULL, plot.axis = TRUE, bw = NULL, b = NULL, a1cont = NULL, a2cont = NULL, contour_colors = c("#a175ff", "#00bfc4")) {
  
  # Prepare the data, depending on the type of input ("pca"/"dudi" object or raw scores)
  if (is.null(sc2)) {
    sc_1 <- sc1
    sc_2 <- sc1
    sc1 <- sc_1$li[1:n1, ]
    sc2 <- sc_1$li[(n1 + 1):(n1 + n2), ]
  }
  
  if (inherits(sc1, c("pca", "dudi")) && inherits(sc2, c("pca", "dudi"))) {
    sc_1 <- sc1
    sc_2 <- sc2
    sc1 <- sc1$li
    sc2 <- sc2$li
  }
  
  # Recognize both species
  scores <- rbind(sc1, sc2)
  g <- factor(c(rep(0, nrow(sc1)), rep(1, nrow(sc2))))
  df <- data.frame(x = scores$Axis1, y = scores$Axis2, g = g)
  
  # Establish an empty plot to be placed at top-right corner (X)
  empty <- ggplot() +
    geom_point(aes(1, 1), colour = "white") +
    theme_void()
  
  # sp1
  p1 <- ggplot(data = df, aes(x, y)) +
    stat_density_2d(aes(fill = ..level.., color = factor(g)), alpha = 0.2, bins = b, geom = "polygon", h = c(bw, bw)) +
    scale_fill_gradient(low = "#bd9dff", high = "#bc9cff", space = "Lab", name = "sp1") +
    scale_color_manual(values = contour_colors) +
    theme(legend.position = "none")
  
  # sp2
  p2 <- ggplot(data = df, aes(x, y)) +
    stat_density_2d(aes(fill = ..level.., color = factor(g)), alpha = 0.2, bins = b, geom = "polygon", h = c(bw, bw)) +
    scale_fill_gradient(low = "#67d8ff", high = "#00ffff", space = "Lab", name = "sp2") +
    scale_color_manual(values = contour_colors) +
    theme(legend.position = "none")
  
  pp1 <- ggplot_build(p1)
  ppp1 <- ggplot_build(
    p1 + aes(alpha = 0.15) + 
      theme_classic() + 
      theme(legend.position = "none", text = element_text(size = 15)) + 
      xlab("axis1") + 
      ylab("axis2") + 
      xlim(c(min(pp1$data[[1]]$x) - 1, max(pp1$data[[1]]$x) + 1)) + 
      ylim(c(min(pp1$data[[1]]$y) - 1, max(pp1$data[[1]]$y) + 1))
  )
  pp2 <- ggplot_build(
    p2 + aes(alpha = 0.15) + 
      theme_classic() + 
      theme(legend.position = "none") + 
      xlab("axis1") + 
      ylab("axis2") + 
      xlim(c(min(pp1$data[[1]]$x) - 1, max(pp1$data[[1]]$x) + 1)) + 
      ylim(c(min(pp1$data[[1]]$y) - 1, max(pp1$data[[1]]$y) + 1))
  )$data[[1]]
  
  ppp1$data[[1]]$fill[grep(pattern = "^2", pp2$group)] <- pp2$fill[grep(pattern = "^2", pp2$group)]
  
  grob1 <- ggplot_gtable(ppp1)
  grob2 <- ggplotGrob(p2)
  grid.newpage()
  grid.draw(grob1)
  
  # Marginal density of x - plot on top
  if (inherits(sc_1, c("pca", "dudi")) && inherits(sc_2, c("pca", "dudi"))) {
    plot_top <- ggplot(df, aes(x, y = ..scaled.., fill = g)) + 
      geom_density(position = "identity", alpha = 0.5) +
      scale_x_continuous(name = paste("Contribution ", round((sc_1$eig[1] * 100) / sum(sc_1$eig), 2), "%", sep = ""), limits = c(min(pp1$data[[1]]$x) - 0.5, max(pp1$data[[1]]$x) + 0.5)) +
      scale_fill_manual(values = c("#ab82ff", "#00ffff")) + 
      theme_classic() + 
      theme(legend.position = "none")
  } else {
    if (is.null(a1cont)) {
      plot_top <- ggplot(df, aes(x, y = ..scaled.., fill = g)) + 
        geom_density(position = "identity", alpha = 0.5) +
        scale_x_continuous(name = "axis1", limits = c(min(pp1$data[[1]]$x) - 0.5, max(pp1$data[[1]]$x) + 0.5)) +
        scale_fill_manual(values = c("#ab82ff", "#00ffff")) + 
        theme_classic() + 
        theme(legend.position = "none")
    } else {
      plot_top <- ggplot(df, aes(x, y = ..scaled.., fill = g)) + 
        geom_density(position = "identity", alpha = 0.5) +
        scale_x_continuous(name = paste("Contribution ", a1cont, "%", sep = ""), limits = c(min(pp1$data[[1]]$x) - 0.5, max(pp1$data[[1]]$x) + 0.5)) +
        scale_fill_manual(values = c("#ab82ff", "#00ffff")) +
        theme_classic() + 
        theme(legend.position = "none")
    }
  }
  
  # Marginal density of y - plot on the right
  if (inherits(sc_1, c("pca", "dudi")) && inherits(sc_2, c("pca", "dudi"))) {
    plot_right <- ggplot(df, aes(y, y = ..scaled.., fill = g)) + 
      geom_density(position = "identity", alpha = 0.5) + 
      scale_x_continuous(name = paste("Contribution ", round((sc_1$eig[2] * 100) / sum(sc_1$eig), 2), "%", sep = ""), limits = c(min(pp1$data[[1]]$y) - 0.5, max(pp1$data[[1]]$y) + 0.5)) +
      coord_flip() + 
      scale_fill_manual(values = c("#ab82ff", "#00ffff")) + 
      theme_classic() + 
      theme(legend.position = "none")
  } else {
    if (is.null(a2cont)) {
      plot_right <- ggplot(df, aes(y, y = ..scaled.., fill = g)) + 
        geom_density(position = "identity", alpha = 0.5) + 
        scale_x_continuous(name = "axis2", limits = c(min(pp1$data[[1]]$y) - 0.5, max(pp1$data[[1]]$y) + 0.5)) +
        coord_flip() + 
        scale_fill_manual(values = c("#ab82ff", "#00ffff")) + 
        theme_classic() + 
        theme(legend.position = "none")
    } else {
      plot_right <- ggplot(df, aes(y, y = ..scaled.., fill = g)) + 
        geom_density(position = "identity", alpha = 0.5) + 
        scale_x_continuous(name = paste("Contribution ", a2cont, "%", sep = ""), limits = c(min(pp1$data[[1]]$y) - 0.5, max(pp1$data[[1]]$y) + 0.5)) +
        coord_flip() + 
        scale_fill_manual(values = c("#ab82ff", "#00ffff")) +
        theme_classic() + 
        theme(legend.position = "none")
    }
  }
  
  if (plot.axis == TRUE) {
    grid.arrange(plot_top, empty, grob1, plot_right, ncol = 2, nrow = 2, widths = c(4, 1), heights = c(1, 4))
  } else {
    grid.arrange(empty, grob1, ncol = 2, nrow = 2, widths = c(0.01, 10), heights = c(0.01, 10))
  }
}
