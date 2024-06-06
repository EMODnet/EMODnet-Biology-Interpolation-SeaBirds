datadir <- "/home/ctroupin/data/EMODnet/Biology/dwca-esas-v1.3"

eventfile = file.path(datadir, "event200.csv")
occurfile = file.path(datadir, "occurrence200.csv")

file.exists(eventfile)
file.exists(occurfile)


eventdata <- read.csv(eventfile, sep="\t", header=TRUE)
evenID <- eventdata$eventID