## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- eval = F-----------------------------------------------------------
## getwd()
## #setwd("D:/whatever")

## ----Library,message=FALSE,warning=FALSE---------------------------------
#install.packages("packagename")
library(sp)
library(rgdal)
library(adehabitatHR)
library(proj4)
#library(rgeos)

## ----Read----------------------------------------------------------------
deer10.sp <- readOGR(dsn=getwd(), layer="pts10")

## ----Class---------------------------------------------------------------
class(deer10.sp)

## ----Names---------------------------------------------------------------
names(deer10.sp)

## ----Head----------------------------------------------------------------
head(deer10.sp)

## ----Summarize-----------------------------------------------------------
summary(deer10.sp)

## ----Structure-----------------------------------------------------------
str(deer10.sp)

## ----Factor--------------------------------------------------------------
deer10.sp$Animal_ID <- as.factor(deer10.sp$Animal_ID)
str(deer10.sp)

## ----Visualize-----------------------------------------------------------
plot(deer10.sp)

## ----TwoDeer-------------------------------------------------------------
# Read the ascii file
deer.all <- read.csv("deer_all.csv")
# Check its class
class(deer.all)
# Set the coordinates
coordinates(deer.all) <- c("x","y")
# Define the projection
proj4string(deer.all) <- CRS("+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
# Now check the class again
class(deer.all)
deer.all$Animal_ID <- as.factor(deer.all$Animal_ID)
# Plot data points for the two deer
plot(deer.all, col=deer.all$Animal_ID)

## ----MCP-----------------------------------------------------------------
deer.all.mcp <- mcp(deer.all, percent = 100)
plot(deer.all.mcp, col=3:4)
# Overlay the points
plot(deer.all, col= deer.all$Animal_ID, add = TRUE)

## ----MCP90---------------------------------------------------------------
deer.all.mcp90 <- mcp(deer.all, percent = 90)
# Look at the MCP areas
deer.all.area <-mcp.area(deer.all, percent = seq(20,100, by = 5), unin = "m", unout = "km2") 
plot(deer.all.mcp90, col=NA, border=unique(deer.all$Animal_ID))
plot(deer.all, col=deer.all$Animal_ID, add=TRUE)

## ----MCPSummary----------------------------------------------------------
deer.all.mcp
deer.all.mcp90

## ----MCPExport-----------------------------------------------------------
writeOGR(deer.all.mcp, dsn=getwd(), "deerallmcp", driver='ESRI Shapefile', overwrite_layer=TRUE)
writeOGR(deer.all.mcp90, dsn=getwd(), "deerallmcp90", driver='ESRI Shapefile', overwrite_layer=TRUE)

## ----Kernel--------------------------------------------------------------
kud_deer1 <- kernelUD(deer.all)

## ----KernelPlot----------------------------------------------------------
# Use Image instead of please, since the result of kernelUD is a raster.  
image(kud_deer1)

## ----Checkh--------------------------------------------------------------
# Note that results are saved in a list, which means you have to use a different syntax to view the data (`[[#]]`)
kud_deer1[[1]]@h
kud_deer1[[2]]@h

## ----KernelManual--------------------------------------------------------
kud_deer2 <- kernelUD(deer.all, h = 40)
image(kud_deer2)

# Or, use a larger h
kud_deer3 <- kernelUD(deer.all, h = 65)
image(kud_deer3)

## ----LSCV----------------------------------------------------------------
kud_deer4 <- kernelUD(deer.all, h="LSCV")
image(kud_deer4)

## ----Grid----------------------------------------------------------------
kud_deer5 <- kernelUD(deer.all, grid=10)
image(kud_deer5)

kud_deer6 <- kernelUD(deer.all, grid=100)
image(kud_deer6)

kud_deer6 <- kernelUD(deer.all, grid=500)
image(kud_deer6)

## ----BaseGrid------------------------------------------------------------
# Load the 'area.shp' file, which is simply a shapefile which has 4 points at each corner to define the extent.
# Then use the ascgen function (see help(ascgen) to create a 10-meter grid over the study area. 
# Describe the grid by using the gridparameters function.
study_area <- readOGR(dsn=getwd(), layer="area")
base.grd <- ascgen(study_area, cellsize=10)
gridparameters(base.grd)
# Draw the image if you'd like: image(base.grd)

## ----BaseGrid2-----------------------------------------------------------
# Specify the base.grid which will be used in all calculations, standardizing result.
kud_deer <- kernelUD(deer.all, h="LSCV", grid=base.grd)
image(kud_deer)

# Determine your h values generated by the LSCV method
kud_deer[[1]]@h
kud_deer[[2]]@h

# Determine if the LSCV converged
# The output from this command shows you the iterations R runs through to determine the best value for h.  You can plot this to see how it approaches h.
plotLSCV(kud_deer)

## ----KHR-----------------------------------------------------------------
hr.areas <- kernel.area(kud_deer, percent = seq(10, 95, by = 5))
hr.areas
plot(hr.areas)

## ----KContour------------------------------------------------------------
# Get the contour volumes
deer.all.vud <- getvolumeUD(kud_deer)
image(deer.all.vud[[1]])
title("Home Range Grid for Deer #10")
hrmap.no10<- as.image.SpatialGridDataFrame(deer.all.vud[[1]]) 
contour(hrmap.no10, add=TRUE) 

## ----KVertices-----------------------------------------------------------
deer.all.hr95 <- getverticeshr(kud_deer, percent=95)
deer.all.hr75 <- getverticeshr(kud_deer, percent=75)
deer.all.hr50 <- getverticeshr(kud_deer, percent=50)

## ----KPlot---------------------------------------------------------------
plot(deer.all.hr50, col=3:4)
plot(deer.all, col=deer.all$Animal_ID, add=TRUE)

## ----KWrite--------------------------------------------------------------
writeOGR(deer.all.hr95, dsn= getwd(), "deerallhr95", driver = "ESRI Shapefile",overwrite_layer=TRUE)
writeOGR(deer.all.hr75, dsn= getwd(), "deerallhr75", driver = "ESRI Shapefile",overwrite_layer=TRUE)
writeOGR(deer.all.hr50, dsn= getwd(), "deerallhr50", driver = "ESRI Shapefile",overwrite_layer=TRUE)

## ----KGrid---------------------------------------------------------------
deer.grd.raw<-estUDm2spixdf(kud_deer)
deer.grd.perc<-estUDm2spixdf(getvolumeUD(kud_deer))

# Export to a Geotiff
writeGDAL(deer.grd.raw, fname = "deerhrraw.tif", drivername = "GTiff", type = "Float32")
writeGDAL(deer.grd.perc, fname = "deerhrperc.tif", drivername = "GTiff", type = "Float32")

## ----LoCoH.Sequence------------------------------------------------------
deer.LoCoH.area <- LoCoH.k.area(deer.all, krange = seq(11,20), percent = 100)
deer.LoCoH.area

## ----LoCoH.Home----------------------------------------------------------
deer.LoCoH <- LoCoH.k(deer.all, 16)
plot(deer.LoCoH)

## ----LoCoH.Export--------------------------------------------------------
# Animal 1
no10.LoCoH <- deer.LoCoH[[1]]
plot(no10.LoCoH)
writeOGR(no10.LoCoH, dsn= getwd(), "no10.LoCoH", driver = "ESRI Shapefile",overwrite_layer=TRUE)

# Animal 2
no11.LoCoH <- deer.LoCoH[[2]]
plot(no11.LoCoH)
writeOGR(no11.LoCoH, dsn= getwd(), "no11.LoCoH", driver = "ESRI Shapefile",overwrite_layer=TRUE)

