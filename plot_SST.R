library(oce)
library(ncdf4)
library(ocedata)
data("coastlineWorld")

datadir = path.expand("~/data/global")
datafile = file.path(datadir, "AQUA_MODIS.20231201_20231231.L3m.MO.SST4.sst4.9km.nc")

# open netcdf file and extract variables
nc = nc_open(datafile)

# view netcf metadata
print(nc)

# extract data
lat = ncvar_get(nc, "lat")
lon = ncvar_get(nc, "lon")
sst = ncvar_get(nc, "sst4")

# close netcdf
nc_close(nc)

# configure colour scale for plotting
pal = oce.colorsTemperature()
zlim = range(sst, na.rm = TRUE)
c = colormap(sst, breaks=100, zclip = T, col = pal, zlim = zlim)

# define unit label
label = 'Sea surface tempetature (°C)'

# plot basemap
# List of projections: https://dankelley.github.io/r/2015/04/03/oce-proj.html
mapPlot(coastlineWorld, col = 'grey', projection = "+proj=eck3",
     longitudelim=range(lon), latitudelim=range(lat), drawBox=F)

# add sst layer
mapImage(lon, lat, sst, col=oceColorsTemperature)

# overlay coastline again
mapPolygon(coastlineWorld, col='grey')

# add variable label
mtext(paste0(label),side = 3, line = 0, adj = 0, cex = 0.7)

# add title
title("SST")

# add colour palette
drawPalette(c$zlim, col=c$col, breaks=c$breaks, zlab = '', fullpage = T)