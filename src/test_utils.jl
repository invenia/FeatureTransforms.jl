module TestUtils

using ..FeatureTransforms
using ..FeatureTransforms: OneToOne, OneToMany, ManyToOne, ManyToMany

export FakeOneToOneTransform, FakeOneToManyTransform
export FakeManyToOneTransform, FakeManyToManyTransform

struct FakeOneToOneTransform <: Transform end
FeatureTransforms.cardinality(::FakeOneToOneTransform) = OneToOne()
FeatureTransforms._apply(A, ::FakeOneToOneTransform; kwargs...) = ones(size(A))

struct FakeOneToManyTransform <: Transform end
FeatureTransforms.cardinality(::FakeOneToManyTransform) = OneToMany()
FeatureTransforms._apply(A, ::FakeOneToManyTransform; kwargs...) = hcat(ones(size(A)), ones(size(A)))

struct FakeManyToOneTransform <: Transform end
FeatureTransforms.cardinality(::FakeManyToOneTransform) = ManyToOne()
FeatureTransforms._apply(A, ::FakeManyToOneTransform; dims, kwargs...) = ones(size(first(A)))

struct FakeManyToManyTransform <: Transform end
FeatureTransforms.cardinality(::FakeManyToManyTransform) = ManyToMany()
FeatureTransforms._apply(A, ::FakeManyToManyTransform; kwargs...) = hcat(ones(size(A)), ones(size(A)))

end
