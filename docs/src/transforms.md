# [Transforms](@id about-transforms)

A `Transform` defines a transformation of data for feature engineering purposes.
Some examples are scaling, periodic functions, linear combination, and one-hot encoding.

```@meta
DocTestSetup = quote
    using DataFrames
    using Dates
    using FeatureTransforms
end
```

## Defining a transform

A `Transform` often has one or more parameters.
For example, the following defines a squaring operation (i.e. raise to the power of 2):

```julia-repl
julia> p = Power(2);
```

## Methods to apply a transform

Given some data `x`, there are three main methods to apply a transform.
Firstly, it can be applied in a non-mutating fashion using `apply`:

```jldoctest transforms
julia> p = Power(2);

julia> x = [1.0, 2.0, 3.0];

julia> FeatureTransforms.apply(x, p)
3-element Array{Float64,1}:
 1.0
 4.0
 9.0

julia> x
3-element Array{Float64,1}:
 1.0
 2.0
 3.0
```

Equivalently, the `Transform` object can be called directly on the data:

```jldoctest transforms
julia> p(x)
3-element Array{Float64,1}:
 1.0
 4.0
 9.0
```

Alternatively, the data can be mutated using the `apply!` method.

!!! note

    Some `Transform` subtypes do not support mutation, such as those which change the type or dimension of the input.

```jldoctest transforms
julia> FeatureTransforms.apply!(x, p)
3-element Array{Float64,1}:
 1.0
 4.0
 9.0

julia> x
3-element Array{Float64,1}:
 1.0
 4.0
 9.0
```

A single `Transform` instance can be applied to different data types, with support for `AbstractArray`s and [`Table`s](https://github.com/JuliaData/Tables.jl).

!!! note

    Some `Transform` subtypes have restrictions on how they can be applied once constructed.
    For instance, `MeanStdScaling` stores the mean and standard deviation of some data for specified dimensions or column names.
    So `MeanStdScaling` should only be applied to the same data type and for the same dimensions or subset of column names specified in construction.

## Applying to `AbstractArray`

### Default

Without specifying optional arguments, a `Transform` is applied to every element of an `AbstractArray` and in an element-wise fashion:

```jldoctest transforms
julia> M = [2 4; 1 5; 3 6];

julia> p = Power(2);

julia> FeatureTransforms.apply(M, p)
3×2 Array{Int64,2}:
 4  16
 1  25
 9  36
```

### Applying to specific array indices with `inds`

Transforms can be applied to `AbstractArray` data with an `inds` keyword argument.
This will apply the `Transform` to certain indices of an array.
For example, to only square the second column:

```jldoctest transforms
julia> FeatureTransforms.apply(M, p; inds=[4, 5, 6])
3-element Array{Int64,1}:
 16
 25
 36
```

### Applying along dimensions using `dims`

Transforms can be applied to `AbstractArray` data with a `dims` keyword argument.
This will apply the `Transform` to slices of the array along dimensions determined by `dims`.
For example, given a `Matrix`, `dims=1` applies to each column, and `dims=2` applies
to each row.

!!! note

    In general, the `dims` argument uses the convention of `mapslices`, which is called behind the scenes when applying transforms to slices of data.
    In practice, this means that users can expect the `dims` keyword to behave exactly as `mean(A; dims=d)` would; the transformation will be applied to the elements along the dimension `d` and, for operations like `mean` or `sum`, reduce across this dimension.

```jldoctest transforms
julia> M
3×2 Array{Int64,2}:
 2  4
 1  5
 3  6

julia> normalize_cols = MeanStdScaling(M; dims=1);

julia> normalize_cols(M; dims=1)
3×2 Array{Float64,2}:
  0.0  -1.0
 -1.0   0.0
  1.0   1.0

julia> normalize_rows = MeanStdScaling(M; dims=2);

julia> normalize_rows(M; dims=2)
3×2 Array{Float64,2}:
 -0.707107  0.707107
 -0.707107  0.707107
 -0.707107  0.707107
```

### Using `dims` and `inds` together

When using `dims` with `inds`, the `inds` change from being the global indices of the array to the relative indices of each slice.
For example, the following is another way to square the second column of an array, applying to  index 2 of each row:

```jldoctest transforms
julia> FeatureTransforms.apply(M, p; dims=2, inds=[2])
3×1 Array{Int64,2}:
 16
 25
 36
```

## Applying to `Table`

### Default

Without specifying optional arguments, a `Transform` is applied to every column of a `Table` independently:

```jldoctest transforms
julia> nt = (a = [2, 1, 3], b = [4, 5, 6]);

julia> scaling = MeanStdScaling(nt);

julia> FeatureTransforms.apply!(nt, scaling)
(a = [0, -1, 1], b = [-1, 0, 1])
```

!!! note

    The non-mutating `apply` method for `Table` data returns a `Vector` of `Vector`s, one for each column.
    This is so users are free to decide what to name the results of the transformation, whether to append to the original table, etc.

    ```julia-repl
    julia> FeatureTransforms.apply(nt, scaling)
    2-element Array{Array{Float64,1},1}:
    [-2.0, -3.0, -1.0]
    [-6.0, -5.0, -4.0]
    ```

### Applying to specific columns with `cols`

For `Table` data, all `Transform`s support a `cols` keyword argument in their `apply` methods.
This applies the transform to the specified columns.

Using `cols`, we can apply different transformations to different kinds of data from the same table:

```jldoctest transforms
julia> df = DataFrame(
           :time => DateTime(2021, 2, 27, 12):Hour(1):DateTime(2021, 2, 27, 14),
           :temperature_A => [18.1, 19.5, 21.1],
           :temperature_B => [16.2, 17.2, 17.5],
       );

julia> hod = HoD();

julia> lc = LinearCombination([0.5, 0.5]);

julia> feature_df = DataFrame(
           :hour_of_day => hod(df; cols=:time),
           :aggregate_temperature => lc(df; cols=[:temperature_A, :temperature_B])
       )
3×2 DataFrame
 Row │ hour_of_day  aggregate_temperature 
     │ Int64        Float64               
─────┼────────────────────────────────────
   1 │          12                  17.15
   2 │          13                  18.35
   3 │          14                  19.3
```

## Transform-specific keyword arguments

Some transforms have specific keyword arguments that can be passed to `apply`/`apply!`.
For example, `MeanStdScaling` can invert the original scaling using the `inverse` argument:

```jldoctest transforms
julia> nt = (a = [2, 1, 3], b = [4, 5, 6]);

julia> scaling = MeanStdScaling(nt);

julia> FeatureTransforms.apply!(nt, scaling);

julia> nt
(a = [0, -1, 1], b = [-1, 0, 1])

julia> FeatureTransforms.apply!(nt, scaling; inverse=true);

julia> nt
(a = [2, 1, 3], b = [4, 5, 6])
```

```@meta
DocTestSetup = Nothing
```
