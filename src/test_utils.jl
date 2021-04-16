"""
    FeatureTransforms.TestUtils

Provides fake [`Transform`](@ref)s and utilities for testing purposes only.

Each fake [`Transform`](@ref) has different a different `cardinality`: `OneToOne`, OneToMany`,
`ManyToOne`, or `ManyToMany`. So when users extend FeatureTransforms.jl for new data types
they only need to test against these 4 fakes to guarantee their type can support any
[`Transform`](@ref) in the package.

Similarly, `is_transformable` is used to check that the output of a `transform` pipeline is
a transformable type.
"""

module TestUtils

using ..FeatureTransforms
using ..FeatureTransforms: OneToOne, OneToMany, ManyToOne, ManyToMany
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
    return ones(size(A))
end

function FeatureTransforms._apply(A, ::FakeOneToManyTransform; kwargs...)
    return hcat(ones(size(A)), ones(size(A)))
end

function FeatureTransforms._apply(A, ::FakeManyToOneTransform; dims, kwargs...)
    return ones(size(first(A)))
end

function FeatureTransforms._apply(A, ::FakeManyToManyTransform; kwargs...)
    return hcat(ones(size(A)), ones(size(A)))
end

"""
    is_transformable(x)

Determine if `x` is both a valid input and output of any [`Transform`](@ref), i.e. that it
follows the [`transform`](@ref) interface.
Currently, all subtypes of `Table`s and `AbstractArray`s are transformable.
"""
is_transformable(::AbstractArray) = true
is_transformable(x) = Tables.istable(x)

end
