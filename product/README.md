The netCDF file can be obtained from https://dox.ulg.ac.be/index.php/s/87JgSvf5irbsjiV/download.

A compression was applied in order to reduce its size:
```bash
ncks -7 -L 5 --baa=4 --ppc default=3 seabirds_interp.nc seabirds_interp 
```