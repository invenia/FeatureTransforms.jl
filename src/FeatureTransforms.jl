module FeatureTransforms

using Dates: TimeType, Period, Day, hour
using NamedDims: dim
using Statistics: mean, std
using Tables

export HoD, LinearCombination, OneHotEncoding, Periodic, Power
export IdentityScaling, MeanStdScaling, AbstractScaling
export Transform
export is_transformable, transform, transform!

include("utils.jl")
include("transform.jl")
include("apply.jl")

# Transform implementations
include("linear_combination.jl")
include("one_hot_encoding.jl")
include("periodic.jl")
include("power.jl")
include("scaling.jl")
include("temporal.jl")

end
