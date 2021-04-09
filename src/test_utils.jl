module TestUtils

using ..FeatureTransforms
using ..FeatureTransforms: OneToOne, OneToMany, ManyToOne, ManyToMany

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

end
