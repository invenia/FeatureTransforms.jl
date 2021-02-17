module Transforms

using Dates: TimeType, Period, Day, hour
using Statistics
using Tables

export HoD, LinearCombination, OneHotEncoding, Periodic, Power, MeanStdScaling, Transform
export transform, transform!

include("utils.jl")
include("transformers.jl")

# Transform implementations
include("linear_combination.jl")
include("one_hot_encoding.jl")
include("periodic.jl")
include("power.jl")
include("temporal.jl")
include("scaling.jl")

end
