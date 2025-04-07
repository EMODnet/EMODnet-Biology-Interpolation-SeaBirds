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
	using ZipFile
    using NCDatasets
    using DataStructures
    using OrderedCollections
    using HTTP
end

"""
## User parameters
You can set here:
- the domain of interest and the spatial resolution,
- the time periods to be compared,
- the analysis parameters of `DIVAnd` (`len` and `epsilon2`),
- the data directory path.
"""

datadir = "../../data/"
outputdir = "../../product/"
outputfile = joinpath(outputdir, "seabirds_interp.nc")
mkpath(datadir)

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

baseURL = "https://www.marinespecies.org/rest/AphiaIDByName/"

"""
## Data download
!!! info "Download the data files"
    They will be automatically downloaded from [https://www.vliz.be/en/imis?module=dataset&dasid=3117](https://www.vliz.be/en/imis?module=dataset&dasid=3117) and placed in the directory `../../data`.      
⚠️ If they are stored in another directory, you need to set that value in the variable 📁 `datadir`.

> Vanermen N, Stienen EWM, Fijn R, Markones N, Holdsworth N, Osypchuk A, Pinto C, Desmet P (2022): European Seabirds at Sea (ESAS). ICES, Copenhagen, Denmark. https://esas.ices.dk. https://doi.org/10.14284/601

Two files will be used for the processing:
1. `event.txt`: it gives the data set ID, the position and the date
2. `occurrence.txt`: it gives the count for different taxa, and relate them to the eventID read from the previous file. 
"""

const dataurl = "https://mda.vliz.be/download.php?file=VLIZ_00000772_6442460347bb7759971746"
datazip = joinpath(datadir, "birds_data.zip")
if isfile(datazip)
    @info("Data already downloaded")
else
    @info("Downloading data")
    download(dataurl, datazip)
end

@info("Extracting data archive")
r = ZipFile.Reader(datazip)
for f in r.files
    if isfile(joinpath(datadir, f.name))
        @info("File $(f.name) already extracted")
    else
        @info("Extracting file $(f.name)")
        open(joinpath(datadir, f.name), "w") do df
            write(df, read(f, String))
        end
    end
end
close(r)


## Load the mask for plotting
lont, latt, lsmask = GeoDatasets.landseamask(; resolution = 'c', grid = 5)

## Read data as dataframes
### Occurences
@time dataoccur, headeroccur = readdlm(datafileoccur, '\t', header = true)
occurences = DataFrame(dataoccur, vec(headeroccur))

## Generate list of species
specieslist = unique(occurences.scientificName)
@info("Number of species: $(length(specieslist))");

### Events
@time dataevents, headerevent = readdlm(datafileevent, '\t', header = true)
events = DataFrame(dataevents, vec(headerevent))
events = events[events.type.=="subSample", :]

function parse_date(xx::SubString{String},
    regexdate = r"\d{4}-\d{2}-\d{2}/\d{4}-\d{2}-\d{2}"::Regex,
)
    thedateformat = Dates.DateFormat("yyyy-mm-ddTHH:MM:SSZ") # example: 1993-08-14T07:54:00Z
    mm = match(regexdate, xx)
    if mm !== nothing
        datestring = mm.match[1:10]
    else
        datestring = xx
    end
    thedate = DateTime(datestring, thedateformat)
    return thedate::DateTime
end

if !(events.eventDate[1] isa DateTime)
    transform!(events, "eventDate" => ByRow(parse_date) => "eventDate")
end

function get_total_count(occurences::DataFrame)

    total_count = Dict{String,Int64}()
    for (eventID, count) in zip(occurences.id, occurences.individualCount)

        # If the key was already found in the Dict, add the index to the list
        if haskey(total_count, eventID)
            total_count[eventID] += count
        else
            total_count[eventID] = count
        end
    end

    return total_count::Dict
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
download("https://dox.uliege.be/index.php/s/RSwm4HPHImdZoQP/download", bathname)
xb, yb, maskbathy = DIVAnd.load_mask(bathname, true, lonr, latr, 0.0)

# Create the netCDF file that will store the results
include("./create_nc.jl")

# Loop on all the species
for (jjj, thespecies) in enumerate(specieslist)
    @info("Working on $(thespecies)")
    occurences_species = occurences[occurences.scientificName.==thespecies, :]

    ## Get the aphiaID from the species name
    resp = HTTP.request("GET", "$(baseURL)$(HTTP.escape(thespecies))?marine_only=false&extant_only=true");
    aphiaID = String(resp.body)
    @info(aphiaID);

    ### Create new dataframe with total number of obs. and the coordinates
    @time total_count = get_total_count(occurences_species)
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
            @time fi, s = DIVAndrun(
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
                ds["taxon_name"][jjj,1:length(thespecies)] = collect(thespecies)
                ds["taxon_lsid"][jjj,1:length(thespecies)] = collect(thespecies)
                ds["gridded_count"][:,:,jjj,iii] = fi
                ds["gridded_count_error"][:,:,jjj,iii] = cpme
            end
        else
            @info("Not enough observations to perform interpolation")
        end;

    end
end
