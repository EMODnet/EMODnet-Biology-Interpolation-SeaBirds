#   🐢 Turtles sightings 🐢
#   ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
# 
#   This notebooks illustrates the computation of a heatmap using observation
#   locations.
# 
#   Dataset: Marine Turtles National Biodiversity Network Trust. Marine Turtles.
#   National Biodiversity Network Trust, Newark, UK.
#   https://doi.org/10.15468/fyt9hw,
#   https://portal.obis.org/dataset/1cfc4d23-9fcd-42b2-95bf-9c4ee9bc50f6

#   ––––––––––––––––––––––––––––––––––––––––––––––––––

library(logger)
library(ggplot2)
library(ggmap)
library(JuliaCall)

# julia_command("using DIVAnd")
julia_command("using PyPlot")
julia_command("using Statistics")
julia_command("using DelimitedFiles")
julia_command("using LinearAlgebra")
julia_command("using Random")

options(download.file.method="wget") # Necessary to download files

# Create directories
datadir <- "./data/"
figdir <- "./figures/"
resdir <- "./results/"

dir.create(datadir)
dir.create(figdir)
dir.create(resdir)

# Download the data file
# (hosted on ULiege OwnCloud instance)
turtlefile <- file.path(datadir, "turtles.dat")
doxbaseURL <- "https://dox.uliege.be/index.php/s/" 
dataurl <- paste(doxbaseURL,"IsWWlNxWeQDuarJ/download", sep = "")

if (!file.exists(turtlefile)){
    log_info("Downloading data file")
    download.file(url = dataurl, destfile = turtlefile)
}else{
    log_info("Data file already downloaded")
}

# Read the CSV file
AA = read.csv(turtlefile, header = FALSE, sep = "\t",  dec = ".",  comment.char = "")
log_info("{dim(AA)}")

lon=AA[,1]
lat=AA[,2]
log_info("Mean longitude: {mean(lon)}")
log_info("Mean latitude: {mean(lat)}")

# Make a simple plot
deltalon <- 1.
deltalat <- 1.
domain <- c(left = min(lon) - deltalon, bottom = min(lat) - deltalat, right = max(lon) + deltalon, top = max(lat) + deltalat)

log_info("Creating figure")
ggplot() +
  geom_point(aes(x = lon, y = lat), size = 1, colour="orange") +
  xlab("Longitude (°N)") +
  ylab("Latitude (°E)") +
  coord_cartesian(xlim =c(domain["left"], domain["right"]), ylim = c(domain["bottom"], domain["top"])) + 
  borders("world",fill="black",colour="black") + 
  ggtitle("Location of the observations") 

ggsave(file.path(figdir, "turtle_observations.png"))

#   A simple heatmap without land mask
#   ====================================

# Set domain of interest
lonmin <- -14.
latmin <- 47.
LX <- 18.
LY <- 15.
lonmax <- lonmin + LX
latmax <- latmin + LY

NX <- 300
NY <- 250

dx <- LX/NX
dy <- LY/NY

# Bounding box
# Defined in domain variable

xo <- lon
yo <- lat

# Eliminate points out of the box
sel <- (xo>lonmin) & (xo < lonmax) & (yo > latmin) & (yo < latmax)
xo <- xo[sel]
yo <- yo[sel]
inflation <- rep(1., length(xo))

#   Heatmap
#   –––––––––

seq(0, 1, length.out=npoints)

xg <- seq(lonmin + dx/2, lonmax, dx)
yg <- seq(latmin + dy/2, latmax, dy)
julia_assign("xg", xg)
julia_assign("yg", yg)

julia_command("mask, (pm,pn), (xi,yi) = DIVAnd.DIVAnd_rectdom(xg, yg);") 


# From here generic approach 
julia_assign("xo", xo)
julia_assign("yo", yo)
julia_assign("inflation", inflation)

julia_command("@time dens1,LHM,LCV,LSCV = DIVAnd.DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=1);")

# From Julia variable to R variable
dens1 = julia_eval("dens1")
LHM = julia_eval("LHM")
LCV = julia_eval("LCV")
LSCV = julia_eval("LSCV")

# Need to find a way to create a nice plot

#   Now prepare land mask
#   =======================

bathname <- file.path(datadir, "gebco_30sec_4.nc")
bathnameURL <- "https://dox.uliege.be/index.php/s/RSwm4HPHImdZoQP/download"

if (!file.exists(bathname)){
  log_info("Downloading bathymetry file")
  download.file(url = bathnameURL, destfile = bathname)
}else{
  log_info("Bathymetry file already downloaded")
}

# Extract the bathymetry
julia_assign("bathname", bathname)
julia_command("bx, by, b = load_bath(bathname,true,xg,yg);")

bx = julia_eval("bx")
by = julia_eval("by")
b = julia_eval("b")

# Add a plot showing the bathymetry

# RESTART HERE
# NEED TO DO NICE PLOTS
log_info((dim(b)));

for j = 1:size(b,2)
    for i = 1:size(b,1)
        mask[i,j] = b[i,j] >= 0
    end
end
pcolor(bx,by,Float64.(mask)')
xlabel("Longitude")
ylabel("Latitude")
title("Mask")

#   First heatmap with uniform and automatic bandwidth
#   ––––––––––––––––––––––––––––––––––––––––––––––––––––

@time dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=0)

figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
#scatter(xo,yo,s=1,c="white")
title("Density (log)")
@show LCV,LSCV,mean(LHM[1]),mean(LHM[2])

#   Now with adapted bandwidth
#   ============================

@time dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=1)

figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
#scatter(xo,yo,s=1,c="white")
title("Density (log)")


@show LCV,LSCV,mean(LHM[1]),mean(LHM[2])

#   But how much iterations ? Cross validation indicators can help
#   ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=0)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=1)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=2)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=3)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=4)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=5)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

#   4 iterations yield highest likelyhood and lowest rms
#   ======================================================

dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=4)
figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("$(mean(LHM[1])),$LCV,$LSCV")

pcolor(xip,yip,log.(LHM[1].*LHM[2])),colorbar()
xlabel("Longitude")
ylabel("Latitude")
title("Surface of bandwidth (log)")

#   Important note
#   ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
# 
#   There is no information used on the effort of looking for turtles. Obviously
#   more are seen close to coastlines because of easier spotting.