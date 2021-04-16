"""
    FeatureTransforms.TestUtils

Provides fake [`Transform`](@ref)s for testing purposes only.
"""

module TestUtils

using ..FeatureTransforms
using ..FeatureTransforms: OneToOne, OneToMany, ManyToOne, ManyToMany
using Tables

export FakeOneToOneTransform, FakeOneToManyTransform
export FakeManyToOneTransform, FakeManyToManyTransform

for C in (:OneToOne, :OneToMany, :ManyToOne, :ManyToMany)
    FT = Symbol(:Fake, C, :Transform)
    @eval begin
        """
            $($FT) <: Transform

        A fake [`$($C)`](@ref) transform for test purposes.
        Calling `apply` will return an array of ones with the expected size and dimension.
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
