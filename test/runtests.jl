using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Documenter: doctest
using FeatureTransforms
using FeatureTransforms: _periodic
using FeatureTransforms: cardinality, OneToOne, OneToMany, ManyToOne, ManyToMany
using Test
using TimeZones

@testset "FeatureTransforms.jl" begin
    # The doctests fail unless run on 64bit julia 1.6.x, due to printing differences
    Sys.WORD_SIZE == 64 && v"1.6" <= VERSION < v"1.7" && doctest(FeatureTransforms)

    include("linear_combination.jl")
    include("one_hot_encoding.jl")
    include("periodic.jl")
    include("power.jl")
    include("scaling.jl")
    include("temporal.jl")
    include("traits.jl")
    include("test_utils.jl")
end
