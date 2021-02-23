using AxisArrays
using AxisKeys
using DataFrames: DataFrame
using Dates
using Transforms
using Transforms: _try_copy, _periodic
using Test
using TimeZones

# TODO - this is needed to make mapslices work with AxisArrays - should be removed.
AxisArrays.reduced_indices(X::Tuple{Vararg{Axis}}, r::UnitRange) = AxisArrays.reduced_indices(X, Tuple(collect(r)))

@testset "Transforms.jl" begin
    include("linear_combination.jl")
    include("one_hot_encoding.jl")
    include("periodic.jl")
    include("power.jl")
    include("scaling.jl")
    include("temporal.jl")
end
