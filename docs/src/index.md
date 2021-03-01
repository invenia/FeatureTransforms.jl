# FeatureTransforms

FeatureTransforms.jl provides utilities for performing feature engineering in machine learning pipelines.
FeatureTransforms supports operations on `AbstractArray`s and [`Table`](https://github.com/JuliaData/Tables.jl)s.

There are three key parts of the Transforms.jl API:

* A [`Transform`](@ref about-transforms) defines a transformation of data, for example normalisation or a periodic function.
* An `apply` method applies a [`Transform`](@ref about-transforms) to data, in a manner determined by the data type and specified dimensions, column names, indices, and other `Transform`-specific parameters.
* The `transform` interface can be used to define a feature engineering pipeline, which comprises a collection of [`Transform`](@ref about-transforms)s to be peformed on some data.

## Getting Started

Here are some resources for getting started with FeatureTransforms.jl:

* Refer to the page on [Transforms](@ref about-transforms) to learn how they are defined and used.
* Consult the [examples](@ref) section for a quick guide to some typical use cases.
