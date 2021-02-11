module Transforms

using Dates: TimeType, Period, Day, hour
using Tables

export HoD, LinearCombination, Periodic, Power, Transform
export transform, transform!

include("utils.jl")
include("transformers.jl")

# Transform implementations
include("linear_combination.jl")
include("periodic.jl")
include("power.jl")
include("temporal.jl")

end
