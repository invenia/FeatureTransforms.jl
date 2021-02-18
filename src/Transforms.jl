module Transforms

using Dates: TimeType, Period, Day, hour
using Statistics: mean, std
using Tables

export HoD, LinearCombination, MeanStdScaling, OneHotEncoding, Periodic, Power, Transform
export transform, transform!

include("utils.jl")
include("transformers.jl")

# Transform implementations
include("linear_combination.jl")
include("one_hot_encoding.jl")
include("periodic.jl")
include("power.jl")
include("scaling.jl")
include("temporal.jl")

end
