using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Documenter: doctest
using FeatureTransforms
using FeatureTransforms: _periodic
using Test
using TimeZones

@testset "FeatureTransforms.jl" begin
    include("appending_apply.jl")  # TODO: break up
    include("linear_combination.jl")
    include("one_hot_encoding.jl")
    include("periodic.jl")
    include("power.jl")
    include("scaling.jl")
    include("temporal.jl")
    include("transform.jl")

    doctest(FeatureTransforms)
end
