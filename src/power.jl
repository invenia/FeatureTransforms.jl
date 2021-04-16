"""
    Power(exponent) <: Transform

Raise the data by the given `exponent`.
"""
struct Power <: Transform
    exponent::Real
end

cardinality(::Power) = OneToOne()

_apply(x, P::Power; kwargs...) = x .^ P.exponent
