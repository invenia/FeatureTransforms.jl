using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Test
using TimeZones
using Transforms
using Transforms: _try_copy

@testset "Transforms.jl" begin
    include("linear_combination.jl")
    include("power.jl")
    include("temporal.jl")
end
