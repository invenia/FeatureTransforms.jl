module FeatureTransforms

using Dates: TimeType, Period, Day, hour
using NamedDims: dim
using Statistics: mean, std
using Tables

export Transform, transform, transform!
export HoD, LinearCombination, OneHotEncoding, Periodic, Power
export AbstractScaling, IdentityScaling, MeanStdScaling
export LogTransform, InverseHyperbolicSine

include("utils.jl")
include("traits.jl")
include("transform.jl")
include("apply.jl")

# Transform implementations
include("linear_combination.jl")
include("log.jl")
include("one_hot_encoding.jl")
include("periodic.jl")
include("power.jl")
include("scaling.jl")
include("temporal.jl")

include("test_utils.jl")

# TODO: remove in v0.4 https://github.com/invenia/FeatureTransforms.jl/issues/82
Base.@deprecate_binding is_transformable TestUtils.is_transformable

end
