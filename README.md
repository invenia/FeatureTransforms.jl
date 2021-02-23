# Transforms

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Transforms.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/Transforms.jl/dev)
[![Build Status](https://travis-ci.com/invenia/Transforms.jl.svg?branch=master)](https://travis-ci.com/invenia/Transforms.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

Transforms.jl provides utilities for performing feature engineering in machine learning pipelines.
Transforms supports operations on `AbstractArrays` and [Tables](https://github.com/JuliaData/Tables.jl).

## Installation
```julia
julia> using Pkg; Pkg.add("Transforms")
```

## Quickstart
Load in the dependencies and construct some toy data.
```julia
julia> using DataFrames, Transforms

julia> df = DataFrame(:a=>[1, 2, 3, 4, 5], :b=>[5, 4, 3, 2, 1], :c=>[0, 1, 0, 1, 0])
5×3 DataFrame
 Row │ a      b      c     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      5      0
   2 │     2      4      1
   3 │     3      3      0
   4 │     4      2      1
   5 │     5      1      0
```

We construct the transformations that we want to `apply` to the data, which can be non-mutating (`apply`) or mutating (`apply!`) if supported.
Note that non-mutating transformations do not necessarily return the same type, even when applied to all the elements.
```julia
julia> p = Power(3);

julia> Transforms.apply(df, p; cols=[:a])
1-element Array{Array{Int64,1},1}:
 [1, 8, 27, 64, 125]

julia> Transforms.apply!(df, p; cols=[:a])
5×3 DataFrame
 Row │ a      b      c     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      5      0
   2 │     8      4      1
   3 │    27      3      0
   4 │    64      2      1
   5 │   125      1      0
```

Also note that some transformations, such as those applying a reduction operation, do not support mutation.
But users may append the output to their data if they so wish.
```julia
julia> lc = LinearCombination([1, -10]);

julia> Transforms.apply(df, lc; cols=[:b, :c])
5-element Array{Int64,1}:
  5
 -6
  3
 -8
  1

```
