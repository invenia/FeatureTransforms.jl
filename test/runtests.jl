using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Transforms
using Transforms: _try_copy
using Test

@testset "Transforms.jl" begin
    include("linear_combination.jl")
    include("power.jl")
end
