# Transforms(@id transforms)

A `Transform` defines a transformation of data, for example scaling, periodic functions, linear combination, one-hot encoding, etc.

```@meta
DocTestSetup = quote
    using DataFrames
    using Dates
    using FeatureTransforms
```

Usually, a `Transform` has one or more parameters. For example, we can define a squaring operation (i.e. raise to the power of 2):

```jldoctest transforms
julia> p = Power(2);
```

This transformation can be applied to data `x` as follows:

```jldoctest transforms
julia> x = [1.0, 2.0, 3.0];

julia> FeatureTransforms.apply(x, p)
3-element Array{Float64,1}:
 1.0
 4.0
 9.0
```

## Applying a `Transform`

There are three main ways to apply a `Transform` - suppose it is called `t`:

* `Transforms.apply(data, t; kwargs...)` is non-mutating, returning the transformed data without modifying the original data.
* `t(data; kwargs...)` is equivalent to `Transforms.apply(data, t; kwargs...)`
* `Transforms.apply!(data, t; kwargs...)` is mutating, returning the modified `data` with the same type.

A single `Transform` can be applied to different data types and in different ways. The two main data types supported are `AbstractArray`s and [`Table`s](https://github.com/JuliaData/Tables.jl).

### `AbstractArray`

For `AbstractArray` data, some `Transform`s support a `dims` keyword argument in their `apply` methods. This will apply the `Transform` to slices of the array along dimensions determined by `dims`. For example, given a `Matrix`, `dims=1` applies to each column, and `dims=2` applies
to each row. This convention is similar to `Statistics.mean(M; dims=2)` returning the mean of each row in matrix `M`.

```jldoctest transforms
julia> M = [0.0 0.0; -0.5 1.0; 0.5 2.0];

julia> scaling = MeanStdScaling(M; dims=1);

julia> FeatureTransforms.apply(M, scaling; dims=1)
3×2 Array{Float64,2}:
  0.0  -1.0
 -1.0   0.0
  1.0   1.0
```

Note that some `Transform`s have restrictions on how they can be applied once constructed. For instance, `MeanStdScaling` stores the mean and standard deviation of some data for specified dimensions (for arrays) or columns (for tables). So `MeanStdScaling` should only be applied to the same data type and along the same dimensions or subset of columns specified in construction.

We can also provide the `inds` keyword to apply the `Transform` to certain indices along the
array slices. For example, to only scale every odd row:

```jldoctest transforms
julia> FeatureTransforms.apply(M, scaling; dims=1, inds=1:2:size(M, 1))
2×2 Array{Float64,2}:
 0.0  -1.0
 1.0   1.0
```

### `Table`

For `Table` data, all `Transform`s support a `cols` keyword argument in their `apply` methods. This applies the transform to the specified columns, or all columns if none are specified. Using `cols`, we can apply different transformations to different kinds of data from the same table. For example:

```jldoctest transforms
julia> df = DataFrame(
           :time => DateTime(2021, 2, 27, 12):Hour(1):DateTime(2021, 2, 27, 14),
           :temperature_A => [18.1, 19.5, 21.1],
           :temperature_B => [16.2, 17.2, 17.5],
       )
3×3 DataFrame
│ Row │ time                │ temperature_A │ temperature_B │
│     │ DateTime            │ Float64       │ Float64       │
├─────┼─────────────────────┼───────────────┼───────────────┤
│ 1   │ 2021-02-27T12:00:00 │ 18.1          │ 16.2          │
│ 2   │ 2021-02-27T13:00:00 │ 19.5          │ 17.2          │
│ 3   │ 2021-02-27T14:00:00 │ 21.1          │ 17.5          │

julia> feature_df = DataFrame(
           :hour_of_day => FeatureTransforms.apply(df, HoD(); cols=:time),
           :aggregate_temperature => FeatureTransforms.apply(df, LinearCombination([0.5, 0.5]); cols=[:temperature_A, :temperature_B])
       )
3×2 DataFrame
│ Row │ hour_of_day │ aggregate_temperature │
│     │ Int64       │ Float64               │
├─────┼─────────────┼───────────────────────┤
│ 1   │ 12          │ 17.15                 │
│ 2   │ 13          │ 18.35                 │
│ 3   │ 14          │ 19.3                  │
```

```@meta
DocTestSetup = Nothing
```
