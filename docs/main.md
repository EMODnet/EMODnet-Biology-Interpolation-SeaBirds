---
author:
- C. Troupin
date: 29 January 2025
title: "EMODnet Biology: interpolation of bird observations with DIVAnd"
---

::: frame
:::

::: frame
:::

# Julia and Pluto

::::::: frame
### Introduction

What is Julia?

:::::: columns
:::: column
0.3

::: center
![image](logo_julia.png){width="2cm"}
:::
::::

::: column
0.7 $ \textrm{A}
  \left\{
    \begin{array}{l}
      \textbf{fast}\\
      \textrm{dynamic}\\
      \textrm{high-level}\\
      \textrm{open source}
    \end{array}
  \right\}  \textrm{programming language}$
:::
::::::

Created in 2012\
Used at GHER-ULiège since $\sim$ 2017

 <https://julialang.org/>
:::::::

::::::: frame
### Introduction

What is Pluto?

:::::: columns
:::: column
0.3

::: center
![image](logo_pluto.png){width="3cm"}
:::
::::

::: column
0.7 $ \textrm{A}
  \left\{
    \begin{array}{l}
      \textrm{reactive}\\   
      \textrm{lightweight}\\
      \textrm{simple}\\
      \textbf{reproducible}
    \end{array}
  \right\}  \textrm{notebook environment}$
:::
::::::

Created in $\sim$ 2020\
Used at GHER since $\sim$ 2022

 <https://plutojl.org/>
:::::::

:::: frame
### Introduction

Pluto vs. Jupyter

::: tabular
L.45L.45 ![image](logo_jupyter.png){height="1.5cm"} &
![image](logo_pluto.png){height="1.5cm"}\
&\
Many kernels (languages) available & Julia only\
JSON format & Julia script\
State depending on the order of execution & State updated everytime a
cell is modified\
& Interactive
:::
::::

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
