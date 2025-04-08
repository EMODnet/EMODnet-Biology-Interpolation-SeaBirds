# EMODnet Biology: interpolation of bird observations with DIVAnd
---
##  Julia and Pluto

### What is Julia?

[Julia](https://julialang.org/) is a 
- fast
- dynamic
- high-level and 
- open source
programming language.

It was created in 2012 (and used at GHER-ULiège since 2017).


### What is Pluto?

[Pluto](https://plutojl.org/) is a 
- reactive
- lightweight
- simple and 
- reproducible
notebook environment.

It was created in 2020 (and used at GHER since 2022).


### Pluto vs. Jupyter

| Jupyter    | Pluto |
| -------- | ------- |
| Many kernels (languages) available  | Julia only    |
| JSON format | Julia script     |
| State depending on the order of execution    | State updated everytime a
cell is modified    |
|       |  Interactive |

# Pluto notebooks

:::::: frame
### Anatomy of a Pluto notebook

::::: columns
::: column
0.65

<figure>

</figure>
:::

::: column
0.35

1.  Made up of cells: code, markdown, HTML, ...

2.  Cell visibility can be turned off

3.  Interactivity --  <https://featured.plutojl.org/basic/plutoui.jl>

4.  Reproducibility\
    [see next slide]{style="color: commentcolor"}
:::
:::::
::::::

:::::: frame
### Reproducibility!

::::: columns
::: column
0.6

<figure>

</figure>
:::

::: column
0.4 All the

-   package versions

-   compatibility constraints

are stored in the Julia file\
[(not visible in the web interface)]{style="color: commentcolor"}
:::
:::::
::::::

# Application: creating gridded maps for birds

::: frame
### Application: Pluto notebook to process bird data

<figure>
<p><img src="pluto00.png" alt="image" /> <img src="pluto01.png"
alt="image" /> <img src="pluto02.png" alt="image" /> <img
src="pluto03.png" alt="image" /> <img src="pluto04.png" alt="image" />
<img src="pluto05.png" alt="image" /> <img src="pluto06.png"
alt="image" /> <img src="pluto07.png" alt="image" /> <img
src="pluto08.png" alt="image" /></p>
</figure>
:::

::: frame
### Next developments

1.  Test installation on different O.S.

2.  A bit of cleaning
:::

::: frame
:::
