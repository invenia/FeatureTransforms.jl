using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Transforms
using Transforms: _try_copy, _periodic
using Test
using TimeZones

@testset "Transforms.jl" begin
    include("linear_combination.jl")
    include("one_hot_encoding.jl")
    include("periodic.jl")
    include("power.jl")
    include("temporal.jl")
    include("scaling.jl")
end
