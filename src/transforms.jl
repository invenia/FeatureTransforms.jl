
"""
    Transform

Abstract supertype for all feature Transforms.
"""
abstract type Transform end

# Make Transforms callable types
(t::Transform)(x; kwargs...) = apply(x, t; kwargs...)

"""
    is_transformable(x)

Determine if `x` is both a valid input and output of any [`Transform`](@ref), i. e. that it
follows the [`transform`](@ref) interface.
Currently, all subtypes of `Table`s and `AbstractArray`s are transformable.
"""
is_transformable(::AbstractArray) = true
is_transformable(x) = Tables.istable(x)

"""
    transform(::T, data)

Defines the feature engineering pipeline for some type `T`, which comprises a collection of
[`Transform`](@ref)s and other steps to be peformed on the `data`.

The idea around a "transform interface” is to make feature transformations composable, i.e.
the output of any one `Transform` should be valid input to another.

Feature engineering pipelines should obey the same principle and it should be trivial to
add/remove `Transform` steps that compose the pipeline without it breaking.

`transform` should be overloaded for custom types `T` that require feature engineering.
The only requirement is that the return of `transform `is itself "transformable", i. e.
calling [`is_transformable`](@ref) on the output returns true.
"""
function transform end

"""
    transform!(::T, data)

Mutating version of [`transform`](@ref).
"""
function transform! end
