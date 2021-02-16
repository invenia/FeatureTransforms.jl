module Transforms

using Dates: TimeType, Period, Day
using Statistics
using Tables

export Transform
export HoD, LinearCombination, Periodic, Power
export IdentityScaling, MeanStdScaling
export transform, transform!

include("utils.jl")
include("transformers.jl")

# Transform implementations
include("linear_combination.jl")
include("one_hot_encoding.jl")
include("periodic.jl")
include("power.jl")
include("scaling.jl")

end
