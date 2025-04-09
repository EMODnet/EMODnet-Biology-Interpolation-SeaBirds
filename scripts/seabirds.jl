using ZipFile
using Downloads
using Dates
using DataFrames
using NCDatasets
using Downloads
using HTTP

function get_data_files(datadir::AbstractString)
    dataurl = "https://mda.vliz.be/download.php?file=VLIZ_00000772_6442460347bb7759971746"
    datazip = joinpath(datadir, "birds_data.zip")
    if isfile(datazip)
        @info("Data already downloaded")
    else
        @info("Downloading data")
        Downloads.download(dataurl, datazip)
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
    return nothing
end

function get_aphiaid(thespecies::AbstractString)
    baseURL = "https://www.marinespecies.org/rest/AphiaIDByName/"
    resp = HTTP.request("GET", "$(baseURL)$(HTTP.escape(thespecies))?marine_only=false&extant_only=true");
    if resp.status == 200
        aphiaID = String(resp.body)
        @info(aphiaID);
    else
        aphiaID = "000000"
    end
    return aphiaID::AbstractString
end


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

function create_nc(outputfile::AbstractString)

    # Global attributes
    globalattrib = OrderedDict(
        "title" => "Count maps of sea birds in the Europeans Seas",
        "summary" => "The project aims to produce comprehensive data products of the sea birds." ,
        "keywords" => "Marine/Coastal, Marine, Sea Birds" ,
        "Conventions" => "CF-1.8" ,
        "naming_authority" => "https://emodnet.ec.europa.eu/en/biology" ,
        "history" => "https://github.com/EMODnet/EMODnet-Biology-Interpolation-SeaBirds",
        "source" => "https://github.com/EMODnet/EMODnet-Biology-Interpolation-SeaBirds",
        "license" => "CC-BY" ,
        "standard_name_vocabulary" => "CF Standard Name Table 1.12" ,
        "date_created" => Dates.format(Dates.today(), "yyyy-mm-dd") ,
        "creator_name" => "Charles Troupin" ,
        "creator_email" => "ctroupin@uliege.be" ,
        "creator_url" => "https://www.gher.uliege.be" ,
        "institution" => "University of Liège (ULiège)" ,
        "project" => "EMODnet-Biology" ,
        "publisher_name" => "EMODnet Biology Data Management Team" ,
        "publisher_email" => "bio@emodnet.eu" ,
        "publisher_url" => "https://emodnet.ec.europa.eu/en/biology" ,
        "geospatial_lat_min" => domain[3],
        "geospatial_lat_max" => domain[4],
        "geospatial_lon_min" => domain[1],
        "geospatial_lon_max" => domain[2],
        "sea_name" => "Baltic Sea" ,
        "creator_institution" => "University of Liège (ULiège)" ,
        "publisher_institution" => "Flanders Marine Institute (VLIZ)" ,
        "geospatial_lat_units" => "degrees_north" ,
        "geospatial_lon_units" => "degrees_east" ,
        "date_modified" => Dates.format(Dates.today(), "yyyy-mm-dd") ,
        "date_issued" => Dates.format(Dates.today(), "yyyy-mm-dd") ,
        "date_metadata_modified" => Dates.format(Dates.today(), "yyyy-mm-dd") ,
        "product_version" => "1" ,
        "metadata_link" => "https://marineinfo.org/imis?module=dataset&dasid=6618" ,
        "comment" => "Uses attributes recommended by http://cfconventions.org",
        "citation" => "Charles Troupin (2025). Abundance maps of Sea Birds in the European Sea. Integrated data products created under the European Marine Observation Data Network (EMODnet) Biology project CINEA/EMFAF/2022/3.5.2/SI2.895681, funded by the by the European Union under Regulation (EU) No 508/2014 of the European Parliament and of the Council of 15 May 2014 on the European Maritime and Fisheries Fund",
        "acknowledgement" => "European Marine Observation Data Network (EMODnet) Biology project CINEA/EMFAF/2022/3.5.2/SI2.895681, funded by the European Union under Regulation (EU) No 508/2014 of the European Parliament and of the Council of 15 May 2014 on the European Maritime and Fisheries Fund" 
    )

    isfile(outputfile) ? rm(outputfile) : @debug("ok")
    ds = NCDataset(outputfile, "c", attrib = globalattrib)

    # Dimensions
    ds.dim["aphiaid"] = Inf
    ds.dim["lon"] = length(lonr)
    ds.dim["lat"] = length(latr)
    ds.dim["nv"] = 2
    ds.dim["time"] = length(TS1) # unlimited dimension
    ds.dim["string80"] = 80

    # Declare variables

    defVar(ds, "lon", lonr, ("lon",), attrib = OrderedDict(
        "units"                     => "degrees_east",
        "long_name"                 => "Longitude",
        "standard_name"             => "longitude",
        "reference_datum"           => "geographical coordinates, WGS84 projection",
        "axis"                      => "X",
        "valid_min"                 => -180.0,
        "valid_max"                 => 180.0 
    ))

    defVar(ds, "lat", latr, ("lat",), attrib = OrderedDict(
        "units"                     => "degrees_north",
        "long_name"                 => "Latitude",
        "standard_name"             => "latitude",
        "reference_datum"           => "geographical coordinates, WGS84 projection",
        "axis"                      => "Y",
        "valid_min"                 => -90.0,
        "valid_max"                 => 90.0
    ))

    defVar(ds, "aphiaid", Int32,  ("aphiaid",), attrib = OrderedDict(
        "long_name"                 => "Life Science Identifier - World Register of Marine Species",
        "units"                     => "level"
    ))

    defVar(ds, "taxon_name", Char, ("aphiaid", "string80"), attrib = OrderedDict(
        "long_name" => "Scientific name of the taxa",
        "standard_name" => "biological_taxon_name"
    ))
        
    defVar(ds, "taxon_lsid", Char, ("aphiaid", "string80"), attrib = OrderedDict(
        "standard_name" => "biological_taxon_lsid",
        "long_name" => "Life Science Identifier - World Register of Marine Species"
    ))

    nctime = defVar(ds, "time", Int64, ("time",), attrib = OrderedDict(
        "units"                     => "days since 1970-01-01 00:00:00.0",
        "calendar"                  => "gregorian",
        "standard_name"             => "time",
        "long_name"                 => "time",
        "climatology"               => "climatology_bounds"
    ))

    ncclimatology_bounds = defVar(ds,"climatology_bounds", Float64, ("nv", "time"), attrib = OrderedDict(
        "units"                     => "days since 1970-01-01 00:00:00",
    ))

    defVar(ds,"gridded_count", Float64, ("lon", "lat", "time", "aphiaid"), attrib = OrderedDict(
        "units"                     => "1",
        "long_name"                 => "Number of observations",
        "valid_min"                 => Float64(0.0),
        "valid_max"                 => Float64(100.),
        "_FillValue"                => Float64(-999.),
        "missing_value"             => Float64(-999.)
    ))

    defVar(ds,"gridded_count_error", Float64, ("lon", "lat", "time", "aphiaid"), attrib = OrderedDict(
        "units"                     => "1",
        "long_name"                 => "Relative error",
        "valid_min"                 => Float64(0.0),
        "valid_max"                 => Float64(1.0),
        "_FillValue"                => Float64(-999.),
        "missing_value"             => Float64(-999.),
    ))



    dateref = Dates.Date(1970, 1, 1)
    for (iii, dd) in enumerate(TS1.yearlists)
        datestart = Dates.Date(dd[1], 1, 1)
        dateend = Dates.Date(dd[end], 12, 31)
        ncclimatology_bounds[1, iii] = Dates.value(datestart - dateref)
        ncclimatology_bounds[2, iii] = Dates.value(dateend - dateref)
        nctime[iii] = Dates.value(Dates.Date(dd[1] + 5, 1, 1) - dateref)
    end

    close(ds)
end