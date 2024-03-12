
## CURL_4 not found

### Error 

```R
julia_command("using DIVAnd")
Error: Error happens in Julia.
InitError: could not load library "/home/ctroupin/.julia/artifacts/2829a1f6a9ca59e5b9b53f52fa6519da9c9fd7d3/lib/libhdf5.so"
/usr/lib/x86_64-linux-gnu/libcurl.so.4: version `CURL_4' not found (required by /home/ctroupin/.julia/artifacts/2829a1f6a9ca59e5b9b53f52fa6519da9c9fd7d3/lib/libhdf5.so)
Stacktrace:
  [1] dlopen(s::String, flags::UInt32; throw_error::Bool)
    @ Base.Libc.Libdl ./libdl.jl:117
  [2] dlopen(s::String, flags::UInt32)
    @ Base.Libc.Libdl ./libdl.jl:116
  [3] macro expansion
    @ ~/.julia/packages/JLLWrappers/pG9bm/src/products/library_generators.jl:63 [inlined]
  [4] __init__()
    @ HDF5_jll ~/.julia/packages/HDF5_jll/3C0GU/src/wrappers/x86_64-linux-gnu-libgfortran5-cxx11-mpi+mpich.jl:15
  [5] run_module_init(mod::Module, i::Int64)
    @ Base ./loading.jl:1128
  [6] register_restored_modules(sv::Core.SimpleVector, pkg::Base.PkgId, path::String)
    @ Base ./loading.jl:1116
  [7] _include_from_serialized(pkg::Base.PkgId, path::String, 
> 
```

### Solution

Before running the R code
```bash
export LD_PRELOAD=${HOME}/.julia/juliaup/julia-1.10.0+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0
```
with the necessary adaptation for the Julia version.

## libhdf5_hl

### Error

```R
Error: Error happens in Julia.
InitError: could not load library "/home/ctroupin/.julia/artifacts/87831472e1d79c45830c3d71850680eb745345fb/lib/libnetcdf.so"
libhdf5_hl.so.310: cannot open shared object file: No such file or directory
Stacktrace:
```

### Solution



## internet routines cannot be loaded

### Error

```R
Error in download.file(dataurl, turtlefile) : 
  internet routines cannot be loaded
In addition: Warning message:
In download.file(dataurl, turtlefile) :
  unable to load shared object '/usr/lib/R/modules//internet.so':
  /home/ctroupin/.julia/juliaup/julia-1.10.0+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: version `CURL_OPENSSL_4' not found (required by /usr/lib/R/modules//internet.so)
```

### Solution

- Don't run the `export LD_PRELOAD` command... or
- Execute `options(download.file.method="wget") # Necessary to download files`

## installation of package ‘terra’ had non-zero exit status

### Error

```R
> install.packages("terra")
Installing package into ‘/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.1’
(as ‘lib’ is unspecified)
trying URL 'https://cloud.r-project.org/src/contrib/terra_1.7-71.tar.gz'
Content type 'application/x-gzip' length 836573 bytes (816 KB)
==================================================
downloaded 816 KB

* installing *source* package ‘terra’ ...
** package ‘terra’ successfully unpacked and MD5 sums checked
** using staged installation
configure: CC: gcc
configure: CXX: g++ -std=gnu++14
checking for gdal-config... no
no
configure: error: gdal-config not found or not executable.
ERROR: configuration failed for package ‘terra’
* removing ‘/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.1/terra’

The downloaded source packages are in
	‘/tmp/Rtmp7j3L7z/downloaded_packages’
Warning message:
In install.packages("terra") :
  installation of package ‘terra’ had non-zero exit status
```

### Solution

```bash
sudo apt-get install libgdal-dev
```


## nghttp2_option_set_no_rfc9113_leading_and_trailing_ws_validation

### Error

```R
> julia_install_package("Statistics")
/usr/lib/R/bin/exec/R: symbol lookup error: /home/ctroupin/.julia/juliaup/julia-1.10.0+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: undefined symbol: nghttp2_option_set_no_rfc9113_leading_and_trailing_ws_validation
```

### Solution

???

## version `CURL_OPENSSL_4' not found

After running a `ggplot` command involving the `sf` library.

### Error

```R
Error in dyn.load(file, DLLpath = DLLpath, ...) : 
  unable to load shared object '/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.3/sf/libs/sf.so':
  /home/ctroupin/.julia/juliaup/julia-1.10.1+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: version `CURL_OPENSSL_4' not found (required by /lib/libgdal.so.30)
```

### Solution

Same as before: don't execute `export LD_PRELOAD` before starting a session in `R`.


## Installing new Julia packages

### Error

```R
> julia_install_package("Statistics")
Error in if (is.na(a)) return(-1L) : argument is of length zero
```

### Solution

???

## Installing `ncdf4` library

### Error 

The command `install.packages("ncdf4")` ends with:

```R
Error: package or namespace load failed for ‘ncdf4’ in dyn.load(file, DLLpath = DLLpath, ...):
 unable to load shared object '/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.3/00LOCK-ncdf4/00new/ncdf4/libs/ncdf4.so':
  /home/ctroupin/.julia/juliaup/julia-1.10.1+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: version `CURL_OPENSSL_4' not found (required by /usr/lib/x86_64-linux-gnu/libnetcdf.so.19)
Error: loading failed
Execution halted
```

### Solution?

Perform the installation in a `R` session where `LD_PRELOAD` has not been set.     
The library is installed by then it cannot be used in a session where `LD_PRELOAD` has been set.

```R
library(ncdf4)
Error: package or namespace load failed for ‘ncdf4’ in dyn.load(file, DLLpath = DLLpath, ...):
 unable to load shared object '/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.3/ncdf4/libs/ncdf4.so':
  /home/ctroupin/.julia/juliaup/julia-1.10.1+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: version `CURL_OPENSSL_4' not found (required by /usr/lib/x86_64-linux-gnu/libnetcdf.so.19)
```

Hence the issue with the shared object libraries seem to be a general issue.

## Using `oce` to make plots

### Error

```R
> plot(coastlineWorld, col = 'grey',
+      projection = "+proj=eck3",
+      longitudelim=range(lon), 
+      latitudelim=range(lat))
Error in dyn.load(file, DLLpath = DLLpath, ...) : 
  unable to load shared object '/home/ctroupin/R/x86_64-pc-linux-gnu-library/4.3/sf/libs/sf.so':
  /home/ctroupin/.julia/juliaup/julia-1.10.1+0.x64.linux.gnu/lib/julia/libcurl.so.4.8.0: version `CURL_OPENSSL_4' not found (required by /usr/lib/x86_64-linux-gnu/libgdal.so.32)
```

### Solution?

Still issue due to library path.