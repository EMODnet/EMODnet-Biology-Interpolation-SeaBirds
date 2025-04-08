# Apply `DIVAnd` gridding on sea bird data

"""
Perform an interpolation of sea bird observations (positions + counts) using `DIVAnd`.      

The dataset is prepared according to the selected species (see drop-down list).
A CSV file is also written, so it can be read by other tools.

## 📦📦 Packages

The packages will be automatically downloaded the first time the notebook is exectuted.         

!!! warning "⚠️"
	This operation can take some tome to be completed, especially if you run the notebook for the first time.
"""

begin
    using CSV
	using Dates
	using DelimitedFiles
	using DataFrames
	using DIVAnd
    using NCDatasets
    using DataStructures
    using Downloads
    using OrderedCollections
end
include("./seabirds.jl")

"""
## User parameters
You can set here:
- the domain of interest and the spatial resolution,
- the time periods to be compared,
- the analysis parameters of `DIVAnd` (`len` and `epsilon2`),
- the data directory path.
"""

datadir = "../data/raw_data/"
outputdir = "../product/netcdf/"
outputfile = joinpath(outputdir, "seabirds_interp.nc")
mkpath(datadir)
mkpath(outputdir)

domain = (-55, 21, 14.0, 72.0)
deltalon = 0.5
deltalat = 0.5

# Correlation length and noise-to-signal ratio
len = 5.0
epsilon2 = 10.0

yearlist = [y:y+9 for y = 1970:10:2011]
monthlists = [1:12];
TS1 = DIVAnd.TimeSelectorYearListMonthList(yearlist, monthlists);
@info("Number of time periods: $(length(TS1))");

# Data files to be downloaded 
datafileevent = joinpath(datadir, "event.txt")
datafileoccur = joinpath(datadir, "occurrence.txt")

# Data download
# Two files will be used for the processing:
# 1. `event.txt`: it gives the data set ID, the position and the date
# 2. `occurrence.txt`: it gives the count for different taxa, and relate them to the eventID read from the previous file. 

get_data_files(datadir)

## Read data as dataframes
### Occurences
@time dataoccur, headeroccur = readdlm(datafileoccur, '\t', header = true)
occurences = DataFrame(dataoccur, vec(headeroccur))

## Generate list of species
specieslist = unique(occurences.scientificName)
nspecies = length(specieslist)
@info("Number of species: $(nspecies)");

### Events
@time dataevents, headerevent = readdlm(datafileevent, '\t', header = true)
events = DataFrame(dataevents, vec(headerevent))
events = events[events.type.=="subSample", :]

if !(events.eventDate[1] isa DateTime)
    transform!(events, "eventDate" => ByRow(parse_date) => "eventDate")
end

"""
## Prepare DIVAnd analysis
(before starting the loop)
### Compute grid from the user parameters
"""
lonr = domain[1]:deltalon:domain[2]
latr = domain[3]:deltalat:domain[4]
mask, (pm, pn), (xi, yi) = DIVAnd.DIVAnd_rectdom(lonr, latr)

"""
### Create mask from bathymetry
"""
bathname = joinpath(datadir, "gebco_30sec_4.nc")
isfile(bathname) ? @info("Bathymetry file already downloaded") :
Downloads.download("https://dox.uliege.be/index.php/s/RSwm4HPHImdZoQP/download", bathname)
xb, yb, maskbathy = DIVAnd.load_mask(bathname, true, lonr, latr, 0.0)

# Create the netCDF file that will store the results
create_nc(outputfile)

# Loop on all the species
speciesindex = 0

for (jjj, thespecies) in enumerate(specieslist)
    @info("Working on $(thespecies) ($(jjj)/$(nspecies))")
    occurences_species = occurences[occurences.scientificName.==thespecies, :]

    if occursin("/", thespecies)
        @warn("Symbol '/' in the scientific name")
    end
    thespecies = replace(thespecies, "/ " => "", "." => "")

    ## Get the aphiaID from the species name
    aphiaID = get_aphiaid(thespecies)

    ### Create new dataframe with total number of obs. and the coordinates
    total_count = get_total_count(occurences_species)
    total_count_df = DataFrame(
        eventID = collect(keys(total_count)),
        total_count = collect(values(total_count)),
    )

    total_count_coordinates = innerjoin(total_count_df, events, on = :eventID)
    select!(
        total_count_coordinates,
        :decimalLongitude,
        :decimalLatitude,
        :eventDate,
        :total_count,
    )
    npoints = size(total_count_coordinates)[1]
    @info("Number of data points: $(npoints)");

    if npoints > 10
        global speciesindex += 1
        @info(speciesindex);
        """
        #### Write into a CSV file
        The file can then be used in other languages (namely: `R`) or for other purposes.
        """
        myspecies_ = replace(thespecies, " " => "_")
        fname = joinpath(datadir, "$(myspecies_).csv")
        CSV.write(fname, total_count_coordinates)

        # Loop on time periods
        for iii = 1:length(TS1)

            ## Subset data
            dataselection = DIVAnd.select(TS1, iii, total_count_coordinates.eventDate)

            if npoints > 5
                """
                ## Perform DIVAnd heatmap computation
                # ## Perform computation
                """
                fi, s = DIVAndrun(
                    maskbathy,
                    (pm, pn),
                    (xi, yi),
                    (total_count_coordinates.decimalLongitude[dataselection], 
                    total_count_coordinates.decimalLatitude[dataselection]),
                    Float64.(total_count_coordinates.total_count[dataselection]),
                    len,
                    epsilon2,
                )

                """
                ### Compute error field
                This error field will be used to mask regions without measurements (hence where the error is higher).
                """
                cpme = DIVAnd_cpme(maskbathy, (pm, pn), (xi, yi), (total_count_coordinates.decimalLongitude[dataselection], total_count_coordinates.decimalLatitude[dataselection]) ,Float64.(total_count_coordinates.total_count[dataselection]), len, epsilon2);

                ### Write in the netCDF
                NCDataset(outputfile, "a") do ds
                    ds["aphiaid"][jjj] = parse(Int32, aphiaID)
                    ds["taxon_name"][speciesindex,1:length(thespecies)] = collect(thespecies)
                    ds["taxon_lsid"][speciesindex,1:length(thespecies)] = collect(thespecies)
                    ds["gridded_count"][:,:,iii,speciesindex] = fi
                    ds["gridded_count_error"][:,:,iii,speciesindex] = cpme
                end
            else
                @info("Not enough observations to perform interpolation")
            end;

        end
    end
end
