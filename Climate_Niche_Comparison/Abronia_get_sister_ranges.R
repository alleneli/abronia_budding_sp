# Sister pair range overlaps and range size asymmetry
# modified from May 23, 2020 Dena Grossenbacher for Vargas et al. 2020 running title: Ecogeographic speciation in Costus
#For Abronia Budding Speciation. Make sure to run the function at the end of the script first!

#install.packages('raster')
#install.packages('fields')

library(raster)
library(fields)

setwd("/Users/allen/Documents/R/R_Abronia_Niche_Model/Abronia")



#import sister pairs
sis=read.csv(file ="sister.pairs.abr.csv" , as.is=TRUE, sep=",")
sis <- subset(sis, !b.geo=="") #drop rows without geographic data

# import occurrence data
df.occur = read.csv(file = "A_vil_both_var_combine.csv", as.is=TRUE, sep=",")

#####################################################
#Range overlap and size asymmetry across spatial scales 
#####################################################

#had to change occurrence data column name from scientificName to acceptedScientificName
#commit functionion get.ranges (at bottom of script) to memory first
my0.1 <- get.ranges(resolution = 0.1)
my0.05 <- get.ranges(resolution = 0.05)


for (i in 1:nrow(sis)) {
  #Range overlap: area overlap/taxon with min range area 
  sis$rangeoverlap0.1[i] <- round(my0.1$total.overlap[i] / min(my0.1$A.range[i],my0.1$B.range[i]),digits=3)
  sis$rangeoverlap0.05[i] <- round(my0.05$total.overlap[i] / min(my0.05$A.range[i],my0.05$B.range[i]),digits=3) 
  #Range size asymmetry: area of the larger range divided by the area of the smaller ranged species (Fitzpatrick and Turrelli 2006)
  sis$rangeasymmetry0.1[i] <- round(max(my0.1$A.range[i],my0.1$B.range[i]) / min(my0.1$A.range[i],my0.1$B.range[i]),digits=3)
  sis$rangeasymmetry0.05[i] <- round(max(my0.05$A.range[i],my0.05$B.range[i]) / min(my0.05$A.range[i],my0.05$B.range[i]) ,digits=3)
}

write.csv(sis, "output/sister.pairs.ranges.csv")

#####################
#Function: get.ranges 
#####################
get.ranges <- function(resolution){
  
  rx <- raster()		#create a raster layer
  res(rx) <- resolution	#set desired resolution: 1, 0.5, 0.1, 0.05
  
  # Get the area of cells occupied by each species and jointly occupied by both species for all species combinations
  sp.area = do.call(c, lapply(unique(df.occur$acceptedScientificName),function(sp){ 
    my.xy=df.occur[df.occur$acceptedScientificName == sp,c("decimalLongitude","decimalLatitude")] #get lat longs for species
    my.r <- rasterize(my.xy, rx, field=1) #set raster cells where species present = 1
    my.r.area=raster::area(my.r,na.rm=TRUE) #makes a raster with area values for cells occupied by sp
    sum(as.matrix(my.r.area),na.rm=TRUE) #get area sum of cells occupied by sp	
  }))
  names(sp.area) = unique(df.occur$acceptedScientificName)
  
  genus.occupancy = lapply(unique(df.occur$acceptedScientificName),function(sp){  
    unique(cellFromXY(rx,df.occur[df.occur$acceptedScientificName == sp,c("decimalLongitude","decimalLatitude")]))})
  names(genus.occupancy) = unique(df.occur$acceptedScientificName)
  
  A.range=c()
  B.range=c()
  total.overlap=c()
  net.area=c()
  
  for (i in 1:nrow(sis)) {
    print(sis$a.geo[i])
    print(sis$b.geo[i])
    A.area = sp.area[[sis$a.geo[i]]]
    B.area= sp.area[[sis$b.geo[i]]]
    A.geo = genus.occupancy[[sis$a.geo[i]]] #cells with spA
    B.geo = genus.occupancy[[sis$b.geo[i]]] #cells with spB   
    overlap = intersect (A.geo, B.geo) #cells with both species
    net.geo = unique(append(A.geo,B.geo)) #cells with spA, spB, or both
    A.coords = subset(df.occur, acceptedScientificName==sis$a.geo[i])
    B.coords = subset(df.occur, acceptedScientificName==sis$b.geo[i])
    
    my.xy=xyFromCell(rx, overlap) #get lat longs for overlap
    if (nrow(my.xy)<1) {
      my.total.overlap=0
    } else {
      my.r <- rasterize(my.xy, rx, field=1) #set raster cells where species present = 1
      my.r.area=raster::area(my.r,na.rm=TRUE) #makes a raster with area values for cells occupied by both species
      my.total.overlap=sum(as.matrix(my.r.area),na.rm=TRUE) #get area sum of cells occupied by both species
    }
    
    net.xy=xyFromCell(rx, net.geo) #get lat longs for net area
    if (nrow(net.xy)<1) {
      my.net.area=0
    } else {
      net.r <- rasterize(net.xy, rx, field=1) #set raster cells where species present = 1
      net.r.area=raster::area(net.r,na.rm=TRUE) #makes a raster with area values for cells occupied by both species
      my.net.area=sum(as.matrix(net.r.area),na.rm=TRUE) #get area sum of cells occupied by both species
    }
    
    require(fields)
    distMatrix <- rdist.earth(A.coords[,c('decimalLongitude','decimalLatitude')], B.coords[,c('decimalLongitude','decimalLatitude')], miles = TRUE)
    min.dist = min(distMatrix)
    
    A.range = c(A.range, A.area)
    B.range=c(B.range,B.area)
    total.overlap=c(total.overlap,my.total.overlap)
    net.area=c(net.area, my.net.area)
  }
  list(A.range=A.range, B.range=B.range,total.overlap=total.overlap,net.area=net.area)
}
