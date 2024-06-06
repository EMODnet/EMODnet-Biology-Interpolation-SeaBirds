library(ggplot2)

datadir <- "/home/ctroupin/data/EMODnet/Biology/dwca-esas-v1.3"

eventfile = file.path(datadir, "event200.csv")
occurfile = file.path(datadir, "occurrence200.csv")

file.exists(eventfile)
file.exists(occurfile)

# Read the event data
# we only need the time, coordinates and the event IDs 
eventdata <- read.csv(eventfile, sep="\t", header=TRUE)
eventID <- eventdata$eventID
lon <- eventdata$decimalLongitude
lat <- eventdata$decimalLatitude
dates <- eventdata$eventDate

# Basic plot showing the positions
ggplot(eventdata, aes(x=lon, y=lat) ) +
  geom_point()

# Read the occurrence data
occurdata <- read.csv(occurfile, sep="\t", header=TRUE)
scientificname <- occurdata$scientificName
individualcount <- occurdata$individualCount
eventIDoccur <- occurdata$eventID

scientificnameUnique = unique(scientificname)

# Find the event corresponding to the species selected
myspecies = "Larus fuscus"
speciesindex = (scientificname == myspecies)
nselec = sum(speciesindex)
speciesevent = eventIDoccur[speciesindex]


