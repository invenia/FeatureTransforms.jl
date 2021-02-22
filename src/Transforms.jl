module Transforms

using Dates: TimeType, Period, Day, hour
using Statistics: mean, std
using Tables

export HoD, LinearCombination, OneHotEncoding, Periodic, Power
export IdentityScaling, MeanStdScaling, AbstractScaling
export Transform
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
