"""
    Power(exponent) <: Transform

Raise the data by the given `exponent`.
"""
struct Power <: Transform
    exponent::Real
end

_apply(x, P::Power; kwargs...) = x .^ P.exponent
