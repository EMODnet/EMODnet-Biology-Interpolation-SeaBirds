# EMODnet-Biology-PhaseV

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![DOI](https://zenodo.org/badge/655615590.svg)](https://doi.org/10.5281/zenodo.15174401)

[`DIVAnd`](https://github.com/gher-uliege/DIVAnd.jl) is a software tool designed to generate gridded maps of continuous variables such as sea water temperature, salinity or oxygen concentration. The acronyms stands for _Data Interpolating Variational Analysis in n dimensions_.

 The main advantages of `DIVAnd` with respect to other interpolation methods are:
* coastlines and physical boundaries are taken into account by the method.
* large datasets (million of data points) can be ingested and processed by the tool.

`DIVAnd` is a multi-dimensional generalization ([Barth et al., 2014](https://dx.doi.org/10.5194/gmd-7-225-2014)), written in the [Julia language](https://julialang.org/), with a new mathematical formulation with respect to the previous [`DIVA`](https://github.com/gher-ulg/DIVA) code.

This directory provides the codes and tools to
1. prepare the gridded fields for a list of sea birds;
2. provide a graphical interface (in [`Pluto`](https://plutojl.org/)) to generate gridded field of sea birds abundance. 