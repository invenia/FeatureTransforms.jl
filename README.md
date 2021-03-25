# FeatureTransforms

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/FeatureTransforms.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/FeatureTransforms.jl/dev)
[![CI](https://github.com/Invenia/FeatureTransforms.jl/workflows/CI/badge.svg)](https://github.com/Invenia/FeatureTransforms.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/invenia/FeatureTransforms.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/FeatureTransforms.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

FeatureTransforms.jl provides utilities for performing feature engineering in machine learning pipelines.
FeatureTransforms supports operations on `AbstractArrays` and [Tables](https://github.com/JuliaData/Tables.jl).

## Installation
```julia
julia> using Pkg; Pkg.add("FeatureTransforms")
```

## Quickstart
Load in the dependencies and construct some toy data.
```julia
julia> using DataFrames, FeatureTransforms

julia> df = DataFrame(:a=>[1, 2, 3, 4, 5], :b=>[5, 4, 3, 2, 1], :c=>[2, 1, 3, 1, 3])
5×3 DataFrame
 Row │ a      b      c     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      5      2
   2 │     2      4      1
   3 │     3      3      3
   4 │     4      2      1
   5 │     5      1      3
```

Next, we construct the `Transform` that we want to `apply` to the data, which can either be non-mutating (`apply`) or mutating (`apply!`).
All `Transforms` support the non-mutating `apply` method any `Transform` that changes the type or dimension of the input does not support mutation.

In either case, the return will be the same type as the input.
So if you provide an `Array` you get back an `Array`, and if you provide a `Table` you will get back a `Table`.
Here we are working with a `DataFrame`, so the return will always be a `DataFrame`:
```julia
julia> p = Power(3);

julia> FeatureTransforms.apply(df, p; cols=[:a], header=[:a3])
5×1 DataFrame
 Row │ a3    
     │ Int64 
─────┼───────
   1 │     1
   2 │     8
   3 │    27
   4 │    64
   5 │   125

julia> FeatureTransforms.apply!(df, p; cols=[:a])
5×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      5      2
   2 │     8      4      1
   3 │    27      3      3
   4 │    64      2      1
   5 │   125      1      3
```


`Transform`s that don't support mutation must be called using `apply` and appended.
To help with this, you can call the `Transform` type directly:
```julia
julia> ohe = OneHotEncoding(1:3);

julia> lc = LinearCombination([1, -10]);

julia> ohe_df = ohe(df; cols=[:c], header=[:cat1, :cat2, :cat3])

julia> lc_df = lc(df; cols=[:a, :b], header=[:ab]);

julia> df = hcat(df, lc_df, ohe_df)
5×7 DataFrame
 Row │ a      b      c      ab     cat1   cat2   cat3  
     │ Int64  Int64  Int64  Int64  Bool   Bool   Bool  
─────┼─────────────────────────────────────────────────
   1 │     1      5      2    -49  false   true  false
   2 │     8      4      1    -32   true  false  false
   3 │    27      3      3     -3  false  false   true
   4 │    64      2      1     44   true  false  false
   5 │   125      1      3    115  false  false   true

```
