"""
    FeatureTransforms.TestUtils

Provides fake [`Transform`](@ref)s and utilities for testing purposes only.

Each fake [`Transform`](@ref) has different a different `cardinality`: `OneToOne`, OneToMany`,
`ManyToOne`, or `ManyToMany`. So when users extend FeatureTransforms.jl for new data types
they only need to test against these 4 fakes to guarantee their type can support any
[`Transform`](@ref) in the package.

Similarly, [`is_transformable`](@ref) is used to check that the output of a `transform`
pipeline is a transformable type.
"""

module TestUtils

using ..FeatureTransforms
using ..FeatureTransforms: OneToOne, OneToMany, ManyToOne, ManyToMany
using InteractiveUtils: methodswith
using Tables

export FakeOneToOneTransform, FakeOneToManyTransform
export FakeManyToOneTransform, FakeManyToManyTransform
export is_transformable

for C in (:OneToOne, :OneToMany, :ManyToOne, :ManyToMany)
    FT = Symbol(:Fake, C, :Transform)
    @eval begin
        """
            $($FT) <: Transform

        A fake `$($C)` transform for test purposes. Calling `apply` will return an
        array of ones with a size and dimension matching the `cardinality` of the transform.
        """
        struct $FT <: Transform end
        FeatureTransforms.cardinality(::$FT) = $C()
    end
end

function FeatureTransforms._apply(A, ::FakeOneToOneTransform; kwargs...)
    return replace(one, A)
end

function FeatureTransforms._apply(A, ::FakeOneToManyTransform; kwargs...)
    return hcat(replace(one, A), replace(one, A))
end

function FeatureTransforms._apply(A, ::FakeManyToOneTransform; kwargs...)
    return replace(one, first(A))
end

function FeatureTransforms._apply(A, ::FakeManyToManyTransform; kwargs...)
    return hcat(replace(one, A), replace(one, A))
end

"""
    is_transformable(x)

Determine if `x` is both a valid input and output of any [`Transform`](@ref), i.e. that it
has an `apply` method defined and therefore follows the [`transform`](@ref) interface.
"""
function is_transformable(T::Type)
    Tables.istable(T) && return true  # cannot directly check against the method with no type
    return !isempty(methodswith(T, FeatureTransforms.apply; supertypes=true))
end
is_transformable(::T) where T = is_transformable(T)
# Need this to get around using methodswith, which would otherwise return true
is_transformable(::Type{<:Transform}) = false

end
