"""
    LogTransform <: Transform

Logarithmically transform the data through: sign(x) * log(|x| + 1).

This allows positive domains elements to be transformed. 
"""
struct LogTransform <: Transform end
cardinality(::LogTransform) = OneToOne()

_logtransform(x) = sign(x) * log(abs(x) + 1)
_invlogtransform(x) = sign(x) * (exp(sign(x) * x) - 1)

function _apply(A::AbstractArray, transform::LogTransform; inverse=false, kwargs...)
    inverse && return _invlogtransform.(A)
    return _logtransform.(A)
end


"""
    InverseHyperbolicSine <: Transform

Logarithmically transform the data through: log(x + √(x² + 1)).

This is the inverse hyperbolic sine. 
"""
struct InverseHyperbolicSine <: Transform end
cardinality(::InverseHyperbolicSine) = OneToOne()

function _apply(A::AbstractArray, transform::InverseHyperbolicSine; inverse=false, kwargs...)
    inverse && return sinh.(A)
    return asinh.(A)
end      