"""
    LogTransform <: Transform

Logarithmically transform the data through: sign(x) * log(|x| + 1).

This allows transformations of all real numbers, not just positive ones.
"""
struct LogTransform <: Transform end
cardinality(::LogTransform) = OneToOne()

_logtransform(x) = sign(x) * log(abs(x) + one(x))
_invlogtransform(x) = sign(x) * (exp(sign(x) * x) - one(x))

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