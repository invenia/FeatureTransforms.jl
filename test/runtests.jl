using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Documenter: doctest
using FeatureTransforms
using FeatureTransforms: _try_copy, _periodic
using Test
using TimeZones

@testset "FeatureTransforms.jl" begin
    include("linear_combination.jl")
    include("one_hot_encoding.jl")
    include("periodic.jl")
    include("power.jl")
    include("scaling.jl")
    include("temporal.jl")

    doctest(FeatureTransforms)
end
