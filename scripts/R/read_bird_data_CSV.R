# Read the data prepared from the sea bird database 
# https://www.vliz.be/en/imis?module=dataset&dasid=3117
# using the Julia notebook `interp_birds.jl`

library(logger)
library(ggplot2)
library(ggmap)
library(JuliaCall)
library(oce)
# library(ncdf4)
library(ocedata)
library(stringr)

data("coastlineWorld")

julia_command("using DIVAnd")
julia_command("using PyPlot")
julia_command("using Statistics")
julia_command("using DelimitedFiles")
julia_command("using LinearAlgebra")
julia_command("using Random")

datadir <- "/home/ctroupin/Projects/EMODnet/EMODnet-Biology/EMODnet-Biology-PhaseV/data"
datafile <- file.path(datadir, "Larus_fuscus.csv")

df <- read.csv(datafile)

lon=df$decimalLongitude
lat=df$decimalLatitude
log_info(str_glue("Mean longitude: {mean(lon)}"))
log_info(str_glue("Mean latitude: {mean(lat)}"))

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


inflation <- rep(1., length(lon))

dx = 0.5
dy = 0.5

xg <- seq(min(lon) + dx/2, max(lon), dx)
yg <- seq(min(lat) + dy/2, max(lat), dy)
julia_assign("xg", xg)
julia_assign("yg", yg)

julia_command("mask, (pm,pn), (xi,yi) = DIVAnd.DIVAnd_rectdom(xg, yg);") 


col <- "lightgray"
p <- "+proj=merc"
mapPlot(coastlineWorld, projection=p, longitudelim=range(lonmin,lonmax), 
        latitudelim=range(latmin, latmax), col=col)
mtext("Land-sea mask", line=line, adj=1, col=pcol, font=font)

# Compute the density map 

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


# Add a plot showing the bathymetry
p <- "+proj=merc"
mapPlot(coastlineWorld, projection=p, longitudelim=c(-80,0), latitudelim=c(0,45), col=col)
mtext(p, line=line, adj=1, col=pcol, font=font)
# RESTART HERE
# NEED TO DO NICE PLOTS
#log_info((dim(b)))



#   First heatmap with uniform and automatic bandwidth
#   ––––––––––––––––––––––––––––––––––––––––––––––––––––

julia_assign("mask", mask)
julia_command("@time dens1, LHM, LCV, LSCV= DIVAnd_heatmap(mask, (pm,pn), (xi,yi), (xo,yo), inflation,0; Ladaptiveiterations=0)")

figure()
pcolor(xip,yip,log.(dens1)),colorbar()
xlabel("Longitude")
ylabel("Latitude")
#scatter(xo,yo,s=1,c="white")
title("Density (log)")
@show LCV,LSCV,mean(LHM[1]),mean(LHM[2])

#   Now with adapted bandwidth
#   ============================

julia_command("@time dens1,LHM,LCV,LSCV= DIVAnd_heatmap(mask,(pm,pn),(xi,yi),(xo,yo),inflation,0;Ladaptiveiterations=1)
