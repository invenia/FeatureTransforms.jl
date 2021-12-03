
struct LogTransform <: Transform end
cardinality(::LogTransform) = OneToOne()

_logtransform(x) = sign(x) * log(abs(x) + 1)
_invlogtransform(x) = sign(x) * (exp(sign(x) * x) - 1)

function _apply(A::AbstractArray, transform::LogTransform; inverse=false, kwargs...)
    inverse && return _invlogtransform.(A)
    return _logtransform.(A)
end

# Hyperbolic
struct InverseHyperbolicSine <: Transform end
cardinality(::InverseHyperbolicSine) = OneToOne()

function _apply(A::AbstractArray, transform::InverseHyperbolicSine; inverse=false, kwargs...)
    inverse && return sinh.(A)
    return asinh.(A)
end


