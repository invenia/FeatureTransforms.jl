# FeatureTransforms

FeatureTransforms.jl provides utilities for performing feature engineering in machine learning pipelines.
FeatureTransforms supports operations on `AbstractArray`s and [`Table`](https://github.com/JuliaData/Tables.jl)s.

There are three key parts of the Transforms.jl API:

* Subtypes of [`Transform`](@ref about-transforms) define transformations of data, for example normalization or a periodic function.
* The `apply` and `apply!` methods transform data according to the given [`Transform`](@ref about-transforms), in a manner determined by the data type and specified dimensions, column names, indices, and other `Transform`-specific parameters.
* The `transform`(@ref transform-interface) method should be overloaded to define feature engineering pipelines that include [`Transform`](@ref about-transforms)s.

## Getting Started

Here are some resources for getting started with FeatureTransforms.jl:

* Refer to the page on [Transforms](@ref about-transforms) to learn how they are defined and used.
* Consult the [examples](@ref) section for a quick guide to some typical use cases.
* The [API](@ref) page has the list of all currently supported `Transform`s.
