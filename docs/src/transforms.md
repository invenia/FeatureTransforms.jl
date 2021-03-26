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
3-element Vector{Float64}:
 1.0
 4.0
 9.0

julia> x
3-element Vector{Float64}:
 1.0
 2.0
 3.0
```

Equivalently, the `Transform` object can be called directly on the data:

```jldoctest transforms
julia> p(x)
3-element Vector{Float64}:
 1.0
 4.0
 9.0
```

Alternatively, the data can be mutated using the `apply!` method.

!!! note

    Some `Transform` subtypes do not support mutation, such as those which change the type or dimension of the input.

```jldoctest transforms
julia> FeatureTransforms.apply!(x, p)
3-element Vector{Float64}:
 1.0
 4.0
 9.0

julia> x
3-element Vector{Float64}:
 1.0
 4.0
 9.0
```

A single `Transform` instance can be applied to different data types, with support for `AbstractArray`s and [`Table`s](https://github.com/JuliaData/Tables.jl).

!!! note

    Some `Transform` subtypes have restrictions on how they can be applied once constructed.
    For instance, `MeanStdScaling` stores the mean and standard deviation of some data, potentially specified via some dimension and column names.
    So `MeanStdScaling` should only be applied to the same data, and for the same dimension and subset of column names, as those used in construction.

## Applying to `AbstractArray`

### Default

Without specifying optional arguments, a `Transform` is applied to every element of an `AbstractArray` and in an element-wise fashion:

```jldoctest transforms
julia> M = [2.0 4.0; 1.0 5.0; 3.0 6.0];

julia> p = Power(2);

julia> FeatureTransforms.apply(M, p)
3×2 Matrix{Float64}:
 4.0  16.0
 1.0  25.0
 9.0  36.0
```

### Applying to specific array indices with `inds`

Transforms can be applied to `AbstractArray` data with an `inds` keyword argument.
This will apply the `Transform` to certain indices of an array.
For example, to only square the second column:

```jldoctest transforms
julia> FeatureTransforms.apply(M, p; inds=[4, 5, 6])
3-element Vector{Float64}:
 16.0
 25.0
 36.0
```

### Applying along dimensions using `dims`

Transforms can be applied to `AbstractArray` data with a `dims` keyword argument.
This will apply the `Transform` to slices of the array along this dimension, which can be selected by the `inds` keyword.
So when `dims` and `inds` are used together, the `inds` change from being the global indices of the array to the relative indices of each slice.

For example, given a `Matrix`, `dims=1` slices the data column-wise and `inds=[2, 3]` selects the 2nd and 3rd rows.

!!! note

    In general, users can expect the `dims` keyword to behave exactly as `mean(A; dims=d)` would; the transformation will be applied to the elements along the dimension `d` and, for operations like `mean` or `sum`, reduce across this dimension.

```jldoctest transforms
julia> M
3×2 Matrix{Float64}:
 2.0  4.0
 1.0  5.0
 3.0  6.0

julia> normalize_row = MeanStdScaling(M; dims=1, inds=[2])
MeanStdScaling(3.0, 2.8284271247461903)

julia> normalize_row(M; dims=1, inds=[2])
1×2 Matrix{Float64}:
 -0.707107  0.707107

julia> normalize_col = MeanStdScaling(M; dims=2, inds=[2])
MeanStdScaling(5.0, 1.0)

julia> normalize_col(M; dims=2, inds=[2])
3×1 Matrix{Float64}:
 -1.0
  0.0
  1.0

```

## Applying to `Table`

### Default

Without specifying optional arguments, a `Transform` will be applied to all the data in a `Table` and return a `Table` of the same type.
One can specify the `header` for the output by passing it as a keyword argument.
If no `header` is given, the default from [`Tables.table`](https://tables.juliadata.org/stable/#Tables.table) is used.
```jldoctest transforms
julia> nt = (a = [2.0, 1.0, 3.0], b = [4.0, 5.0, 6.0]);

julia> scaling = MeanStdScaling(nt);  # compute statistics using all data

julia> FeatureTransforms.apply(nt, scaling; header=[:a_norm, :b_norm])
(a_norm = [-0.8017837257372732, -1.3363062095621219, -0.2672612419124244], b_norm = [0.2672612419124244, 0.8017837257372732, 1.3363062095621219])
```

However, calling the mutating `apply!` will keep the original column names:
```jldoctest transforms
julia> FeatureTransforms.apply!(nt, scaling)
(a = [-0.8017837257372732, -1.3363062095621219, -0.2672612419124244], b = [0.2672612419124244, 0.8017837257372732, 1.3363062095621219])
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

julia> hod_df = hod(df; cols=:time, header=[:hour_of_day]);

julia> lc_df = lc(df; cols=[:temperature_A, :temperature_B], header=[:aggregate_temperature]);

julia> feature_df = hcat(hod_df, lc_df)
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
julia> nt = (a = [2.0, 1.0, 3.0], b = [4.0, 5.0, 6.0]);

julia> scaling = MeanStdScaling(nt);

julia> FeatureTransforms.apply!(nt, scaling);

julia> nt
(a = [-0.8017837257372732, -1.3363062095621219, -0.2672612419124244], b = [0.2672612419124244, 0.8017837257372732, 1.3363062095621219])

julia> FeatureTransforms.apply!(nt, scaling; inverse=true);

julia> nt
(a = [2.0, 1.0, 3.0], b = [4.0, 5.0, 6.0])
```

```@meta
DocTestSetup = Nothing
```
