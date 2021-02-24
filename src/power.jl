"""
    Power(exponent) <: Transform

Raise the data by the given `exponent`.
"""
struct Power <: Transform
    exponent::Real
end

function _apply(x::AbstractArray{T}, P::Power; kwargs...) where T <: Real
    return x .^ P.exponent
end
